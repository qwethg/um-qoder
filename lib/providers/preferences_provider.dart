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

  bool get isFirstLaunch => _isFirstLaunch;
  ThemeMode get themeMode => _themeMode;
  String get radarChartStyle => _radarChartStyle;

  void _loadPreferences() {
    _isFirstLaunch = _storageService.isFirstLaunch;
    _themeMode = _parseThemeMode(_storageService.themeMode);
    _radarChartStyle = _storageService.radarChartStyle;
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
