import 'package:hive_flutter/hive_flutter.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/services/ai_report_storage_service.dart';

/// 本地存储服务
class StorageService {
  static const String _assessmentBoxName = 'assessments';
  static const String _goalSettingBoxName = 'goal_settings';
  static const String _preferencesBoxName = 'preferences';

  late Box<Assessment> _assessmentBox;
  late Box<GoalSetting> _goalSettingBox;
  late Box _preferencesBox;
  late AiReportStorageService _aiReportStorage;

  /// 初始化存储服务
  Future<void> initialize() async {
    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AssessmentAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AssessmentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GoalSettingAdapter());
    }

    // 打开boxes
    _assessmentBox = await Hive.openBox<Assessment>(_assessmentBoxName);
    _goalSettingBox = await Hive.openBox<GoalSetting>(_goalSettingBoxName);
    _preferencesBox = await Hive.openBox(_preferencesBoxName);

    // 初始化AI报告存储服务
    _aiReportStorage = AiReportStorageService();
    await _aiReportStorage.initialize();
  }

  // ============ Assessment 相关 ============

  /// 保存评估记录
  Future<void> saveAssessment(Assessment assessment) async {
    await _assessmentBox.put(assessment.id, assessment);
  }

  /// 获取所有评估记录
  List<Assessment> getAllAssessments() {
    return _assessmentBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 按时间倒序
  }

  /// 根据ID获取评估记录
  Assessment? getAssessment(String id) {
    return _assessmentBox.get(id);
  }

  /// 获取最新的评估记录
  Assessment? getLatestAssessment() {
    final assessments = getAllAssessments();
    return assessments.isEmpty ? null : assessments.first;
  }

  /// 删除评估记录
  Future<void> deleteAssessment(String id) async {
    await _assessmentBox.delete(id);
  }

  /// 清空所有评估记录
  Future<void> clearAllAssessments() async {
    await _assessmentBox.clear();
  }

  // ============ GoalSetting 相关 ============

  /// 保存目标设定
  Future<void> saveGoalSetting(GoalSetting goalSetting) async {
    await _goalSettingBox.put(goalSetting.abilityId, goalSetting);
  }

  /// 批量保存目标设定
  Future<void> saveGoalSettings(List<GoalSetting> goalSettings) async {
    for (final setting in goalSettings) {
      await saveGoalSetting(setting);
    }
  }

  /// 获取指定能力的目标设定
  GoalSetting? getGoalSetting(String abilityId) {
    return _goalSettingBox.get(abilityId);
  }

  /// 获取所有目标设定
  Map<String, GoalSetting> getAllGoalSettings() {
    final map = <String, GoalSetting>{};
    for (final key in _goalSettingBox.keys) {
      final setting = _goalSettingBox.get(key);
      if (setting != null) {
        map[key as String] = setting;
      }
    }
    return map;
  }

  /// 恢复默认目标设定（删除自定义设定）
  Future<void> resetGoalSettings() async {
    await _goalSettingBox.clear();
  }

  // ============ Preferences 相关 ============

  /// 获取首次启动标志
  bool get isFirstLaunch {
    return _preferencesBox.get('isFirstLaunch', defaultValue: true) as bool;
  }

  /// 设置首次启动标志
  Future<void> setFirstLaunchDone() async {
    await _preferencesBox.put('isFirstLaunch', false);
  }

  /// 获取主题模式 (system, light, dark)
  String get themeMode {
    return _preferencesBox.get('themeMode', defaultValue: 'system') as String;
  }

  /// 设置主题模式
  Future<void> setThemeMode(String mode) async {
    await _preferencesBox.put('themeMode', mode);
  }

  /// 获取雷达图样式
  String get radarChartStyle {
    return _preferencesBox.get('radarChartStyle', defaultValue: 'default') as String;
  }

  /// 设置雷达图样式
  Future<void> setRadarChartStyle(String style) async {
    await _preferencesBox.put('radarChartStyle', style);
  }

  /// 获取 AI API Key
  String get apiKey {
    return _preferencesBox.get('apiKey', defaultValue: '') as String;
  }

  /// 设置 AI API Key
  Future<void> setApiKey(String key) async {
    await _preferencesBox.put('apiKey', key);
  }

  /// 获取 AI 模型名称
  String get aiModel {
    return _preferencesBox.get('aiModel', defaultValue: 'deepseek-ai/DeepSeek-R1-0528-Qwen3-8B') as String;
  }

  /// 设置 AI 模型名称
  Future<void> setAiModel(String model) async {
    await _preferencesBox.put('aiModel', model);
  }

  /// 获取 AI 提示词
  String get aiPrompt {
    return _preferencesBox.get('aiPrompt', defaultValue: '''你是一名顶级的极限飞盘教练和运动心理学家。你的任务是基于用户提供的自我评估数据，给出专业、鼓励性且可执行的分析和建议。

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
''') as String;
  }

  /// 设置 AI 提示词
  Future<void> setAiPrompt(String prompt) async {
    await _preferencesBox.put('aiPrompt', prompt);
  }

  /// 关闭所有boxes
  Future<void> close() async {
    await _assessmentBox.close();
    await _goalSettingBox.close();
    await _preferencesBox.close();
    await _aiReportStorage.close();
  }

  // ============ AI 报告相关 ============

  /// 获取AI报告存储服务
  AiReportStorageService get aiReportStorage => _aiReportStorage;
}
