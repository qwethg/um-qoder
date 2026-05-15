import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/services/ai_report_access_control.dart';
import 'package:ultimate_wheel/services/ai_report_storage_service.dart';
import 'package:ultimate_wheel/services/ai_report_validator.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/utils/opt.dart';
import 'package:uuid/uuid.dart';

/// AI 分析服务 - 增强版
///
/// 特性:
/// - 完整的报告生成流程，包括权限检查、缓存、API调用、内容验证和存储
/// - 支持流式响应，实时反馈生成进度
/// - 详细的错误处理和状态管理
/// - 速率限制和使用统计
/// - 报告内容校验与修复
class EnhancedAiService {
  final String apiKey;
  final StorageService storageService;
  final String modelName;
  final String prompt;
  final double temperature;
  final int maxTokens;
  final AiReportAccessControl _accessControl = AiReportAccessControl();

  /// 构造函数
  EnhancedAiService({
    required this.apiKey,
    required this.storageService,
    required this.modelName,
    required this.prompt,
    double? temperature,
    int? maxTokens,
  })  : temperature = temperature ?? 0.7,
        maxTokens = maxTokens ?? 2048;

  String _calculateInputHash(
    Assessment assessment,
    Map<String, GoalSetting> goalSettings,
  ) {
    // Simple and stable serialization for hashing
    final assessmentData = assessment.scores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final goalData = goalSettings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final dataToHash = {
      'assessment_scores': Map.fromEntries(assessmentData),
      'assessment_type': assessment.type.toString(),
      'goal_settings': goalData.map((e) => e.value.scoreDescriptions).toString(),
    };

    final jsonString = jsonEncode(dataToHash);
    final bytes = utf8.encode(jsonString);
    return sha256.convert(bytes).toString();
  }

  /// 生成 AI 分析报告 (流式)
  ///
  /// 返回一个流，实时产出 [AiReport] 对象，反映报告生成的状态
  Stream<AiReport> generateReport({
    required Assessment assessment,
    required Map<String, GoalSetting> goalSettings,
    bool forceRefresh = false,
  }) async* {
    final userId = assessment.id; // 使用评估ID作为用户标识
    final reportId = const Uuid().v4();
    final inputHash = _calculateInputHash(assessment, goalSettings);

    // 1. 权限检查
    final permissionResult = _accessControl.checkCreateReportPermission(
      userId: userId,
      assessment: assessment,
    );

    if (!permissionResult.allowed) {
      yield AiReport.failed(
        id: reportId,
        assessmentId: assessment.id,
        inputHash: inputHash,
        error: permissionResult.reason ?? '无权限创建报告',
      );
      return;
    }

    // 2. 尝试从缓存获取报告
    if (!forceRefresh) {
      final cachedReport =
          await storageService.aiReportStorage.getCachedReport(inputHash);
      if (cachedReport != null && cachedReport.isValid) {
        yield cachedReport.copyAsCached();
        _accessControl.logReportAccess(
          userId: userId,
          reportId: cachedReport.id,
          operation: ReportOperation.read,
        );
        return;
      }
    }

    // 3. 开始生成报告
    final startTime = DateTime.now();
    final inProgressReport = AiReport.inProgress(
      id: reportId,
      assessmentId: assessment.id,
      inputHash: inputHash,
      aiModel: modelName,
      apiParameters: _getApiParameters(),
    );
    yield inProgressReport;

    try {
      // 4. 调用 AI 模型 API (流式)
      final reportStream = _generateReportContent(
        assessment: assessment,
        goalSettings: goalSettings,
        modelName: modelName,
        systemPrompt: prompt,
      );

      String content = '';
      AiReport currentReportState = inProgressReport;

      await for (final chunk in reportStream) {
        content += chunk;
        currentReportState = currentReportState.copyWith(content: content);
        yield currentReportState;
      }

      // 5. 内容验证和修复
      final validationResult =
          AiReportValidator.validateReport(currentReportState, assessment, goalSettings);

      if (!validationResult.isValid) {
        yield AiReport.failed(
          id: reportId,
          assessmentId: assessment.id,
          inputHash: inputHash,
          error: '报告内容验证失败: ${validationResult.issues.join(', ')}',
          apiParameters: _getApiParameters(),
        );
        return;
      }

      // 6. 创建最终报告
      final generationTimeMs = DateTime.now().difference(startTime).inMilliseconds;
      final finalReport = AiReport.create(
        id: reportId,
        assessmentId: assessment.id,
        inputHash: inputHash,
        content: content,
        aiModel: modelName,
        apiParameters: _getApiParameters(),
        generationTimeMs: generationTimeMs,
        tags: _generateTags(assessment, goalSettings),
      );

      // 7. 保存最终报告并确保同评估仅保留一个报告
      await storageService.aiReportStorage.saveUniqueReportForAssessment(finalReport);

      // 8. 记录操作
      _accessControl.logReportAccess(
        userId: userId,
        reportId: finalReport.id,
        operation: ReportOperation.create,
      );

      yield finalReport;
    } catch (e, s) {
      yield AiReport.failed(
        id: reportId,
        assessmentId: assessment.id,
        inputHash: inputHash,
        error: '生成报告时发生未知错误: $e\n$s',
        apiParameters: _getApiParameters(),
      );
    }
  }

  /// 调用 AI 模型 API (流式)
  Stream<String> _generateReportContent({
    required Assessment assessment,
    required Map<String, GoalSetting> goalSettings,
    required String modelName,
    required String systemPrompt,
  }) async* {
    final messages = _buildMessagesList(
      assessment: assessment,
      goalSettings: goalSettings,
      systemPrompt: systemPrompt,
    );

    final request = http.Request(
      'POST',
      Uri.parse('https://api.siliconflow.cn/v1/chat/completions'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });

    request.body = jsonEncode({
      'model': modelName,
      'messages': messages,
      'stream': true, // 启用流式响应
    });

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));

    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw EnhancedAiServiceException(
        'API 请求失败: ${streamedResponse.statusCode}\n$errorBody',
      );
    }

    final stream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.startsWith('data:')) {
        final data = line.substring(5).trim();
        if (data == '[DONE]') {
          break;
        }
        try {
          final decoded = jsonDecode(data);
          final delta = decoded['choices'][0]['delta']['content'] as String?;
          if (delta != null) {
            yield delta;
          }
        } catch (e) {
          // 忽略无法解析的行
          if (kDebugMode) {
            print('无法解析流中的数据行: $line');
          }
        }
      }
    }
  }

  /// 获取API参数
  Map<String, dynamic> _getApiParameters() {
    return {
      'max_tokens': maxTokens,
      'temperature': temperature,
    };
  }

  /// 生成报告标签
  List<String> _generateTags(
      Assessment assessment, Map<String, GoalSetting> goalSettings) {
    final tags = <String>[];

    // 评估类型标签
    tags.add(assessment.type == AssessmentType.deep
        ? 'deep_assessment'
        : 'quick_assessment');

    // 分数范围标签
    final avgScore = assessment.averageScore;
    if (avgScore >= 8.0) {
      tags.add('high_performance');
    } else if (avgScore >= 6.0) {
      tags.add('good_performance');
    } else if (avgScore >= 4.0) {
      tags.add('average_performance');
    } else {
      tags.add('needs_improvement');
    }

    // 目标设定标签
    if (goalSettings.isNotEmpty) {
      tags.add('has_goals');
    }

    // 时间标签
    final now = DateTime.now();
    tags.add('${now.year}_${now.month.toString().padLeft(2, '0')}');

    return tags;
  }

  /// 生成报告摘要
  String? _generateSummary(String content) {
    // 提取总体评价部分作为摘要
    final lines = content.split('\n');
    final summaryLines = <String>[];
    bool inSummarySection = false;

    for (final line in lines) {
      if (line.contains('## 📊 总体评价')) {
        inSummarySection = true;
        continue;
      }

      if (inSummarySection) {
        if (line.startsWith('##')) {
          break;
        }
        if (line.trim().isNotEmpty && !line.startsWith('-')) {
          summaryLines.add(line.trim());
        }
      }
    }

    return summaryLines.isEmpty ? null : summaryLines.join(' ');
  }

  /// 验证报告内容质量
  void _validateReportContent(String content) {
    // 检查内容长度
    if (content.length < 500) {
      throw EnhancedAiServiceException('报告内容过短，可能生成不完整');
    }

    // 检查必要的章节
    final requiredSections = ['总体评价', '分项评价', '行动计划'];
    for (final section in requiredSections) {
      if (!content.contains(section)) {
        throw EnhancedAiServiceException('报告缺少必要章节: $section');
      }
    }
  }

  /// 构建发送给 AI 的消息列表
  List<Map<String, dynamic>> _buildMessagesList({
    required Assessment assessment,
    required Map<String, GoalSetting> goalSettings,
    required String systemPrompt,
  }) {
    final userContent = _formatUserContent(assessment, goalSettings);

    return [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userContent},
    ];
  }

  /// 格式化用户提供的数据
  String _formatUserContent(
      Assessment assessment, Map<String, GoalSetting> goalSettings) {
    final userMessageBuffer = StringBuffer();

    // 1. 当前评估数据
    userMessageBuffer.writeln('# 当前评估数据');
    userMessageBuffer
        .writeln('**评估时间**: ${_formatDateTime(assessment.createdAt)}');
    userMessageBuffer.writeln(
        '**评估类型**: ${assessment.type == AssessmentType.deep ? '深度评估' : '快速评估'}');
    userMessageBuffer
        .writeln('**总分**: ${assessment.totalScore.toStringAsFixed(1)}/120');
    userMessageBuffer.writeln();

    // 2. 各能力项得分
    userMessageBuffer.writeln('## 各能力项得分');
    for (final category in AbilityCategory.values) {
      final abilities = AbilityConstants.getAbilitiesByCategory(category);
      userMessageBuffer.writeln('### ${_getCategoryName(category)}');

      for (final ability in abilities) {
        final score = assessment.scores[ability.id] ?? 0.0;
        final note = assessment.notes[ability.id];

        userMessageBuffer.write('- **${ability.name}**: ${score.toStringAsFixed(1)}/10');
        if (note != null && note.isNotEmpty) {
          userMessageBuffer.write(' (备注: $note)');
        }
        userMessageBuffer.writeln();
      }
      userMessageBuffer.writeln();
    }

    // 3. 用户目标设定
    if (goalSettings.isNotEmpty) {
      userMessageBuffer.writeln('## 用户个人目标');
      for (final category in AbilityCategory.values) {
        final abilities = AbilityConstants.getAbilitiesByCategory(category);
        bool hasCategoryGoals = false;

        for (final ability in abilities) {
          final goalSetting = goalSettings[ability.id];
          if (goalSetting != null) {
            if (!hasCategoryGoals) {
              userMessageBuffer.writeln('### ${_getCategoryName(category)}');
              hasCategoryGoals = true;
            }

            userMessageBuffer.writeln('**${ability.name}**:');
            final descriptions = goalSetting.scoreDescriptions;
            if (descriptions[3] != null) {
              userMessageBuffer.writeln('  - 3分目标: ${descriptions[3]}');
            }
            if (descriptions[5] != null) {
              userMessageBuffer.writeln('  - 5分目标: ${descriptions[5]}');
            }
            if (descriptions[7] != null) {
              userMessageBuffer.writeln('  - 7分目标: ${descriptions[7]}');
            }
            if (descriptions[10] != null) {
              userMessageBuffer.writeln('  - 10分目标: ${descriptions[10]}');
            }
          }
        }
        if (hasCategoryGoals) {
          userMessageBuffer.writeln();
        }
      }
    }

    // 4. 整体备注（如果有）
    if (assessment.overallNote != null && assessment.overallNote!.isNotEmpty) {
      userMessageBuffer.writeln('## 用户整体感受');
      userMessageBuffer.writeln(assessment.overallNote);
      userMessageBuffer.writeln();
    }

    return userMessageBuffer.toString();
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'
        ' ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化分数差异
  String _formatScoreDiff(double diff) {
    if (diff > 0) {
      return '+${diff.toStringAsFixed(1)}';
    } else if (diff < 0) {
      return diff.toStringAsFixed(1);
    } else {
      return '±0.0';
    }
  }

  /// 获取类别名称
  String _getCategoryName(AbilityCategory category) {
    switch (category) {
      case AbilityCategory.athleticism:
        return '身体';
      case AbilityCategory.awareness:
        return '意识';
      case AbilityCategory.technique:
        return '技术';
      case AbilityCategory.mind:
        return '心灵';
    }
  }
}

/// 增强 AI 服务异常
class EnhancedAiServiceException implements Exception {
  final String message;

  EnhancedAiServiceException(this.message);

  @override
  String toString() => message;
}
