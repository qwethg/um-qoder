import 'package:flutter/foundation.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// 目标设定状态管理
class GoalSettingProvider extends ChangeNotifier {
  final StorageService _storageService;

  GoalSettingProvider(this._storageService) {
    _loadGoalSettings();
  }

  // 所有目标设定 (abilityId -> GoalSetting)
  Map<String, GoalSetting> _goalSettings = {};

  /// 获取指定能力的目标设定
  GoalSetting? getGoalSetting(String abilityId) {
    return _goalSettings[abilityId];
  }

  /// 获取指定能力和分数的描述（优先使用自定义，否则使用默认）
  String getDescription(String abilityId, int score) {
    // 先尝试从自定义设定获取
    final customSetting = _goalSettings[abilityId];
    final customDescription = customSetting?.getDescription(score);
    if (customDescription != null && customDescription.isNotEmpty) {
      return customDescription;
    }

    // 使用默认文本
    return DefaultGoalTexts.getDefault(abilityId, score) ?? '';
  }

  /// 检查是否使用了自定义设定
  bool hasCustomSettings() {
    return _goalSettings.isNotEmpty;
  }

  /// 检查指定能力是否有自定义设定
  bool hasCustomSetting(String abilityId) {
    return _goalSettings.containsKey(abilityId);
  }

  // 加载目标设定
  void _loadGoalSettings() {
    _goalSettings = _storageService.getAllGoalSettings();
    notifyListeners();
  }

  /// 保存单个目标设定
  Future<void> saveGoalSetting(String abilityId, Map<int, String> descriptions) async {
    final setting = GoalSetting(
      abilityId: abilityId,
      scoreDescriptions: descriptions,
    );
    await _storageService.saveGoalSetting(setting);
    _loadGoalSettings();
  }

  /// 批量保存目标设定
  Future<void> saveAllGoalSettings(Map<String, Map<int, String>> settingsMap) async {
    final settings = settingsMap.entries.map((entry) {
      return GoalSetting(
        abilityId: entry.key,
        scoreDescriptions: entry.value,
      );
    }).toList();

    await _storageService.saveGoalSettings(settings);
    _loadGoalSettings();
  }

  /// 恢复默认设定（删除所有自定义）
  Future<void> resetToDefault() async {
    await _storageService.resetGoalSettings();
    _loadGoalSettings();
  }

  /// 获取默认描述（用于UI显示）
  Map<int, String> getDefaultDescriptions(String abilityId) {
    return {
      3: DefaultGoalTexts.getDefault(abilityId, 3) ?? '',
      5: DefaultGoalTexts.getDefault(abilityId, 5) ?? '',
      7: DefaultGoalTexts.getDefault(abilityId, 7) ?? '',
      10: DefaultGoalTexts.getDefault(abilityId, 10) ?? '',
    };
  }
}
