import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/services/ai_report_storage_service.dart';
import 'package:ultimate_wheel/services/ai_report_validator.dart';
import 'package:ultimate_wheel/services/ai_report_access_control.dart';

/// 增强的 AI 智能分析服务
/// 
/// 集成了智能缓存、持久化存储、有效性验证和访问控制功能
class EnhancedAiService {
  static const String _apiBaseUrl = 'https://api.siliconflow.cn/v1/chat/completions';
  static const String _modelName = 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B';
  static const int _maxRetries = 3;

  final AiReportStorageService _storageService;
  final AiReportAccessControl _accessControl;
  final String _userId; // 用户标识，可以是设备ID

  EnhancedAiService(StorageService storageService, [String? userId])
      : _storageService = storageService.aiReportStorage,
        _accessControl = AiReportAccessControl(),
        _userId = userId ?? 'default_user';

  /// 生成 AI 分析报告（带缓存、存储、验证和访问控制）
  /// 
  /// 参数:
  /// - [currentAssessment]: 当前的评估结果
  /// - [userGoalSettings]: 用户的目标设定（Map&lt;abilityId, GoalSetting&gt;）
  /// - [previousAssessment]: 上一次的评估结果（可选）
  /// - [apiKey]: 用户的 API Key
  /// - [forceRefresh]: 是否强制刷新，忽略缓存
  /// - [cacheExpiry]: 缓存过期时间
  /// 
  /// 返回: AI 分析报告对象
  Future<AiReport> generateAnalysisReport({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
    required String apiKey,
    bool forceRefresh = false,
    Duration? cacheExpiry,
  }) async {
    final startTime = DateTime.now();

    try {
      // 1. 访问控制检查
      final accessResult = _accessControl.checkCreateReportPermission(
        userId: _userId,
        assessment: currentAssessment,
      );
      
      if (!accessResult.allowed) {
        throw EnhancedAiServiceException(
          '访问被拒绝: ${accessResult.reason}',
        );
      }

      // 2. 生成输入哈希值
      final inputHash = AiReportStorageService.generateInputHash(
        currentAssessment: currentAssessment,
        userGoalSettings: userGoalSettings,
        previousAssessment: previousAssessment,
        aiModel: _modelName,
        apiParameters: _getApiParameters(),
      );

      // 3. 检查缓存（如果不强制刷新）
      if (!forceRefresh) {
        final cachedReport = await _storageService.getCachedReport(inputHash);
        if (cachedReport != null) {
          // 验证缓存报告
          final validationResult = AiReportValidator.validateReport(
            cachedReport,
            currentAssessment,
            userGoalSettings,
          );

          if (validationResult.isValid) {
            // 记录访问日志
            _accessControl.logReportAccess(
              userId: _userId,
              reportId: cachedReport.id,
              operation: ReportOperation.read,
            );
            
            return cachedReport;
          } else {
            // 缓存报告无效，删除并重新生成
            await _storageService.deleteReport(cachedReport.id);
          }
        }
      }

      // 3. 生成新报告
      final content = await _generateAnalysisContent(
        currentAssessment: currentAssessment,
        userGoalSettings: userGoalSettings,
        previousAssessment: previousAssessment,
        apiKey: apiKey,
      );

      final report = AiReport.create(
        assessmentId: currentAssessment.id,
        previousAssessmentId: previousAssessment?.id,
        inputHash: inputHash,
        content: content,
        aiModel: _modelName,
        apiParameters: _getApiParameters(),
        generationTimeMs: DateTime.now().difference(startTime).inMilliseconds,
        tags: _generateTags(currentAssessment, userGoalSettings),
        summary: _generateSummary(content),
      );

      // 4. 验证生成的报告
      final validationResult = AiReportValidator.validateReport(
        report,
        currentAssessment,
        userGoalSettings,
      );

      if (!validationResult.isValid && validationResult.hasCriticalIssues) {
        throw EnhancedAiServiceException(
          '生成的报告验证失败: ${validationResult.errors.first.message}',
        );
      }

      // 5. 保存报告
      await _storageService.saveReport(report);

      // 6. 记录访问日志
      _accessControl.logReportAccess(
        userId: _userId,
        reportId: report.id,
        operation: ReportOperation.create,
      );

      return report;
    } catch (e) {
      // 创建失败报告
      final failedReport = AiReport.create(
        assessmentId: currentAssessment.id,
        previousAssessmentId: previousAssessment?.id,
        inputHash: AiReportStorageService.generateInputHash(
          currentAssessment: currentAssessment,
          userGoalSettings: userGoalSettings,
          previousAssessment: previousAssessment,
          aiModel: _modelName,
          apiParameters: _getApiParameters(),
        ),
        content: '报告生成失败: $e',
        aiModel: _modelName,
        apiParameters: _getApiParameters(),
        generationTimeMs: DateTime.now().difference(startTime).inMilliseconds,
      ).copyWith(status: AiReportStatus.failed);

      await _storageService.saveReport(failedReport);
      throw EnhancedAiServiceException('生成分析报告失败: $e');
    }
  }

  /// 检查是否存在缓存报告
  Future<bool> hasCachedReport({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
  }) async {
    final inputHash = AiReportStorageService.generateInputHash(
      currentAssessment: currentAssessment,
      userGoalSettings: userGoalSettings,
      previousAssessment: previousAssessment,
      aiModel: _modelName,
      apiParameters: _getApiParameters(),
    );
    return _storageService.hasReportForInput(inputHash);
  }

  /// 获取缓存报告
  Future<AiReport?> getCachedReport({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
  }) async {
    final inputHash = AiReportStorageService.generateInputHash(
      currentAssessment: currentAssessment,
      userGoalSettings: userGoalSettings,
      previousAssessment: previousAssessment,
      aiModel: _modelName,
      apiParameters: _getApiParameters(),
    );
    final cachedReport = await _storageService.getCachedReport(inputHash);

    if (cachedReport != null) {
      // 检查访问权限
      final accessResult = _accessControl.checkReportAccess(
        userId: _userId,
        reportId: cachedReport.id,
        report: cachedReport,
      );

      if (accessResult.allowed) {
        // 记录访问日志
        _accessControl.logReportAccess(
          userId: _userId,
          reportId: cachedReport.id,
          operation: ReportOperation.read,
        );
        return cachedReport;
      }
    }

    return null;
  }

  /// 获取评估相关的所有报告
  List<AiReport> getReportsForAssessment(String assessmentId) {
    return _storageService.getReportsByAssessmentId(assessmentId);
  }

  /// 获取报告统计信息
  AiReportStats getReportStats() {
    return _storageService.getStats();
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    await _storageService.cleanupExpiredCache();
  }

  /// 删除报告（带访问控制）
  Future<void> deleteReport(String reportId) async {
    final report = _storageService.getReport(reportId);
    if (report != null) {
      final accessResult = _accessControl.checkReportAccess(
        userId: _userId,
        reportId: reportId,
        report: report,
      );

      if (accessResult.allowed) {
        await _storageService.deleteReport(reportId);
        _accessControl.logReportAccess(
          userId: _userId,
          reportId: reportId,
          operation: ReportOperation.delete,
        );
      } else {
        throw EnhancedAiServiceException('无权删除此报告: ${accessResult.reason}');
      }
    }
  }

  /// 查询报告
  List<AiReport> queryReports(AiReportQuery query) {
    return _storageService.queryReports(query);
  }

  /// 获取用户访问统计
  UserAccessStats getUserAccessStats() {
    return _accessControl.getUserAccessStats(_userId);
  }

  /// 生成分析内容（核心AI调用逻辑）
  Future<String> _generateAnalysisContent({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
    required String apiKey,
  }) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        // 构建消息列表
        final messages = _buildMessagesList(
          currentAssessment: currentAssessment,
          userGoalSettings: userGoalSettings,
          previousAssessment: previousAssessment,
        );

        // 构建请求体
        final requestBody = {
          'model': _modelName,
          'messages': messages,
          'stream': false,
          ..._getApiParameters(),
        };

        // 发起 API 请求
        final response = await http.post(
          Uri.parse(_apiBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        );

        // 检查响应状态
        if (response.statusCode != 200) {
          throw EnhancedAiServiceException(
            '请求失败: ${response.statusCode}\n${response.body}',
          );
        }

        // 解析响应
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (responseData['choices'] == null || 
            responseData['choices'].isEmpty) {
          throw EnhancedAiServiceException('API 返回数据格式错误');
        }

        final content = responseData['choices'][0]['message']['content'] as String?;
        
        if (content == null || content.isEmpty) {
          throw EnhancedAiServiceException('AI 返回内容为空');
        }

        // 验证内容质量
        _validateReportContent(content);

        return content;
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          rethrow;
        }
        
        // 等待后重试
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    
    throw EnhancedAiServiceException('达到最大重试次数，生成失败');
  }

  /// 获取API参数
  Map<String, dynamic> _getApiParameters() {
    return {
      'max_tokens': 2048,
      'temperature': 0.7,
    };
  }

  /// 生成报告标签
  List<String> _generateTags(Assessment assessment, Map<String, GoalSetting> goalSettings) {
    final tags = <String>[];
    
    // 评估类型标签
    tags.add(assessment.type == AssessmentType.deep ? 'deep_assessment' : 'quick_assessment');
    
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
  List<Map<String, String>> _buildMessagesList({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
  }) {
    final messages = <Map<String, String>>[];

    // System Message: 角色设定
    messages.add({
      'role': 'system',
      'content': '''你是一名顶级的极限飞盘教练和运动心理学家。你的任务是基于用户提供的自我评估数据，给出专业、鼓励性且可执行的分析和建议。

请按照以下结构输出你的分析（使用 Markdown 格式）：

## 📊 总体评价
- 对用户当前整体能力水平的综合评价（2-3句话）
- 指出最突出的优势领域
- 点明需要重点关注的薄弱环节

## 🎯 分项评价与建议

### 💪 身体 (Athleticism)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🧠 意识 (Awareness)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🎨 技术 (Technique)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

### 🌟 心灵 (Mind)
- 当前水平总结
- 具体建议（至少2-3条可执行的训练建议）

## 💡 下一步行动计划
基于用户设定的目标，给出3-5条优先级最高的训练建议。

注意事项：
1. 语气要专业但温暖，充满鼓励
2. 建议要具体可执行，避免空泛的鼓励话语
3. 如果有历史对比数据，要指出进步或退步的地方
4. 考虑用户设定的个人目标
5. 使用合适的 emoji 让内容更生动
''',
    });

    // User Message: 用户数据
    final userMessageBuffer = StringBuffer();
    
    // 1. 当前评估数据
    userMessageBuffer.writeln('# 当前评估数据');
    userMessageBuffer.writeln('**评估时间**: ${_formatDateTime(currentAssessment.createdAt)}');
    userMessageBuffer.writeln('**评估类型**: ${currentAssessment.type == AssessmentType.deep ? '深度评估' : '快速评估'}');
    userMessageBuffer.writeln('**总分**: ${currentAssessment.totalScore.toStringAsFixed(1)}/120');
    userMessageBuffer.writeln();

    // 2. 各能力项得分
    userMessageBuffer.writeln('## 各能力项得分');
    for (final category in AbilityCategory.values) {
      final abilities = AbilityConstants.getAbilitiesByCategory(category);
      userMessageBuffer.writeln('### ${_getCategoryName(category)}');
      
      for (final ability in abilities) {
        final score = currentAssessment.scores[ability.id] ?? 0.0;
        final note = currentAssessment.notes[ability.id];
        
        userMessageBuffer.write('- **${ability.name}**: ${score.toStringAsFixed(1)}/10');
        if (note != null && note.isNotEmpty) {
          userMessageBuffer.write(' (备注: $note)');
        }
        userMessageBuffer.writeln();
      }
      userMessageBuffer.writeln();
    }

    // 3. 用户目标设定
    if (userGoalSettings.isNotEmpty) {
      userMessageBuffer.writeln('## 用户个人目标');
      for (final category in AbilityCategory.values) {
        final abilities = AbilityConstants.getAbilitiesByCategory(category);
        bool hasCategoryGoals = false;
        
        for (final ability in abilities) {
          final goalSetting = userGoalSettings[ability.id];
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

    // 4. 历史对比（如果有）
    if (previousAssessment != null) {
      userMessageBuffer.writeln('## 与上次评估对比');
      userMessageBuffer.writeln('**上次评估时间**: ${_formatDateTime(previousAssessment.createdAt)}');
      userMessageBuffer.writeln('**总分变化**: ${currentAssessment.totalScore.toStringAsFixed(1)} (${_formatScoreDiff(currentAssessment.totalScore - previousAssessment.totalScore)})');
      userMessageBuffer.writeln();
      
      userMessageBuffer.writeln('### 各能力项变化');
      for (final ability in AbilityConstants.abilities) {
        final currentScore = currentAssessment.scores[ability.id] ?? 0.0;
        final previousScore = previousAssessment.scores[ability.id] ?? 0.0;
        final diff = currentScore - previousScore;
        
        if (diff.abs() >= 0.5) {  // 只显示有明显变化的项
          userMessageBuffer.writeln('- **${ability.name}**: ${currentScore.toStringAsFixed(1)} (${_formatScoreDiff(diff)})');
        }
      }
      userMessageBuffer.writeln();
    }

    // 5. 整体备注（如果有）
    if (currentAssessment.overallNote != null && currentAssessment.overallNote!.isNotEmpty) {
      userMessageBuffer.writeln('## 用户整体感受');
      userMessageBuffer.writeln(currentAssessment.overallNote);
      userMessageBuffer.writeln();
    }

    messages.add({
      'role': 'user',
      'content': userMessageBuffer.toString(),
    });

    return messages;
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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