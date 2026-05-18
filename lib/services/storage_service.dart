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
    final ttlDays = _preferencesBox.get('ai_cache_ttl_days', defaultValue: 30) as int;
    _aiReportStorage.setCacheTtlDays(ttlDays);
  }

  // ============ Assessment 相关 ============

  /// 保存评估记录
  Future<void> saveAssessment(Assessment assessment) async {
    await _assessmentBox.put(assessment.id, assessment);
  }

  /// 获取所有评估记录
  List<Assessment> getAllAssessments() {
    try {
      final list = <Assessment>[];
      for (var key in _assessmentBox.keys) {
        try {
          final value = _assessmentBox.get(key);
          if (value is Assessment) {
            list.add(value);
          } else {
            print('Warning: Found non-Assessment value in assessmentBox for key: $key');
            _assessmentBox.delete(key);
          }
        } catch (e) {
          print('Error reading assessment with key $key: $e');
          _assessmentBox.delete(key);
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 按时间倒序
      return list;
    } catch (e) {
      print('Critical error in getAllAssessments: $e');
      return [];
    }
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

  /// 获取语言设置
  String get language => _preferencesBox.get('language', defaultValue: 'zh') as String;

  /// 设置语言
  Future<void> setLanguage(String language) async {
    await _preferencesBox.put('language', language);
  }

  Future<void> put(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    return _preferencesBox.get(key, defaultValue: defaultValue);
  }

  Future<void> setCacheTtlDays(int days) async {
    await _preferencesBox.put('ai_cache_ttl_days', days);
    _aiReportStorage.setCacheTtlDays(days);
  }

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
