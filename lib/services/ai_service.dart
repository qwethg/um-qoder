import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/config/constants.dart';

/// AI 智能分析服务
class AiService {
  static const String _apiBaseUrl = 'https://api.siliconflow.cn/v1/chat/completions';
  static const String _modelName = 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B';

  /// 生成 AI 分析报告
  /// 
  /// 参数:
  /// - [currentAssessment]: 当前的评估结果
  /// - [userGoalSettings]: 用户的目标设定（Map&lt;abilityId, GoalSetting&gt;）
  /// - [previousAssessment]: 上一次的评估结果（可选）
  /// - [apiKey]: 用户的 API Key
  /// 
  /// 返回: Markdown 格式的分析报告
  Future<String> generateAnalysis({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
    required String apiKey,
  }) async {
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
        'max_tokens': 2048,
        'temperature': 0.7,
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
        throw AiServiceException(
          '请求失败: ${response.statusCode}\n${response.body}',
        );
      }

      // 解析响应
      final responseData = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (responseData['choices'] == null || 
          responseData['choices'].isEmpty) {
        throw AiServiceException('API 返回数据格式错误');
      }

      final content = responseData['choices'][0]['message']['content'] as String?;
      
      if (content == null || content.isEmpty) {
        throw AiServiceException('AI 返回内容为空');
      }

      return content;
    } on AiServiceException {
      rethrow;
    } catch (e) {
      throw AiServiceException('生成分析时出错: $e');
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

/// AI 服务异常
class AiServiceException implements Exception {
  final String message;

  AiServiceException(this.message);

  @override
  String toString() => message;
}
