import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;

  static const String _modelNameKey = 'ai_model_name';
  static const String _promptKey = 'ai_prompt';

  static const String _defaultModelName = 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B';
  static const String _defaultPrompt = ''';
  你是一位专业的飞盘教练，拥有超过 10 年的飞盘教学和比赛经验。你的教学风格严谨、专业、循循善诱，擅长根据学员的个人情况，提供有针对性的、可执行的、个性化的训练建议。

你的任务是，根据用户提供的个人能力评估数据和目标设定，生成一份专业的、个性化的飞盘能力分析报告。

这份报告需要包含以下几个部分：

1.  **总体评价**：对用户的整体能力水平进行一个简明扼要的总结，点出其核心优势和主要短板。
2.  **各项能力分析**：
    *   **身体**：跑跳、灵敏、体力
    *   **技术**：传盘、接盘/读盘、盯防、跟防
    *   **意识**：空间感、时机感
    *   **心灵**：团队、心态
    *   针对以上每个细分项，结合用户的自评分数和目标设定，给出具体的分析。分数高的要予以肯定，并提出进阶建议；分数低的要分析可能的原因，并提供具体的、可操作的训练方法。
3.  **核心优势**：识别并重点分析用户的 1-2 项核心优势，说明这些优势在比赛中的价值，并给出如何进一步发挥这些优势的建议。
4.  **待办改进项**：识别并重点分析用户的 1-2 项核心短板，说明这些短板对比赛表现的负面影响，并提供一套循序渐进的、结构化的改进计划。
5.  **训练建议**：根据前面的分析，为用户量身定制一套综合性的训练方案，包括但不限于：
    *   **短期（1-2周）**：可以快速见效的练习。
    *   **中期（1-3月）**：需要持续投入才能看到效果的系统性训练。
    *   **长期（3个月以上）**：关于比赛策略、意识培养等方面的宏观建议。

**报告风格要求**：

*   **专业严谨**：使用飞盘领域的专业术语，分析要深入、有理有据。
*   **鼓励性**：在指出问题的同时，要给予用户信心和鼓励，激发其训练热情。
*   **结构清晰**：使用 Markdown 格式，合理运用标题、列表、粗体等，使报告易于阅读。
*   **个性化**：报告内容必须紧密结合用户的个人数据，避免宽泛、模板化的套话。

请根据以下用户数据，生成分析报告：
''';

  String _modelName = _defaultModelName;
  String _prompt = _defaultPrompt;

  String get modelName => _modelName;
  String get prompt => _prompt;

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _modelName = await _storageService.get(_modelNameKey, defaultValue: _defaultModelName);
    _prompt = await _storageService.get(_promptKey, defaultValue: _defaultPrompt);
    notifyListeners();
  }

  Future<void> setModelName(String newName) async {
    _modelName = newName;
    await _storageService.put(_modelNameKey, newName);
    notifyListeners();
  }

  Future<void> setPrompt(String newPrompt) async {
    _prompt = newPrompt;
    await _storageService.put(_promptKey, newPrompt);
    notifyListeners();
  }

  Future<void> restoreDefaultModelName() async {
    await setModelName(_defaultModelName);
  }

  Future<void> restoreDefaultPrompt() async {
    await setPrompt(_defaultPrompt);
  }
}