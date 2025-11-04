import 'package:flutter/material.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// 应用设置状态管理
class PreferencesProvider extends ChangeNotifier {
  final StorageService _storageService;

  PreferencesProvider(this._storageService) {
    _loadPreferences();
  }

  bool _isFirstLaunch = true;
  ThemeMode _themeMode = ThemeMode.system;
  String _radarChartStyle = 'default';
  String _apiKey = '';
  String _aiModel = 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B';
  String _aiPrompt = '';

  bool get isFirstLaunch => _isFirstLaunch;
  ThemeMode get themeMode => _themeMode;
  String get radarChartStyle => _radarChartStyle;
  String get apiKey => _apiKey;
  String get aiModel => _aiModel;
  String get aiPrompt => _aiPrompt;

  void _loadPreferences() {
    _isFirstLaunch = _storageService.isFirstLaunch;
    _themeMode = _parseThemeMode(_storageService.themeMode);
    _radarChartStyle = _storageService.radarChartStyle;
    _apiKey = _storageService.apiKey;
    _aiModel = _storageService.aiModel;
    _aiPrompt = _storageService.aiPrompt;
    notifyListeners();
  }

  /// 标记首次启动完成
  Future<void> completeFirstLaunch() async {
    await _storageService.setFirstLaunchDone();
    _isFirstLaunch = false;
    notifyListeners();
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    await _storageService.setThemeMode(_themeModeToString(mode));
    _themeMode = mode;
    notifyListeners();
  }

  /// 设置雷达图样式
  Future<void> setRadarChartStyle(String style) async {
    await _storageService.setRadarChartStyle(style);
    _radarChartStyle = style;
    notifyListeners();
  }

  /// 更新 API Key
  Future<void> updateApiKey(String newKey) async {
    await _storageService.setApiKey(newKey);
    _apiKey = newKey;
    notifyListeners();
  }

  /// 更新 AI 模型名称
  Future<void> updateAiModel(String newModel) async {
    await _storageService.setAiModel(newModel);
    _aiModel = newModel;
    notifyListeners();
  }

  /// 更新 AI 提示词
  Future<void> updateAiPrompt(String newPrompt) async {
    await _storageService.setAiPrompt(newPrompt);
    _aiPrompt = newPrompt;
    notifyListeners();
  }

  /// 恢复默认 AI 设置
  Future<void> restoreDefaultAiSettings() async {
    await _storageService.setAiModel('deepseek-ai/DeepSeek-R1-0528-Qwen3-8B');
    await _storageService.setAiPrompt('''你是一名顶级的极限飞盘教练和运动心理学家。你的任务是基于用户提供的自我评估数据，给出专业、鼓励性且可执行的分析和建议。

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
''');
    _loadPreferences(); // 重新加载以确保状态同步
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
