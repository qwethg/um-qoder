import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:uuid/uuid.dart';

/// 雷达图主题管理Provider
class RadarThemeProvider extends ChangeNotifier {
  static const String _boxName = 'radar_theme_box';
  static const String _currentThemeKey = 'current_theme_id';
  static const String _customThemesKey = 'custom_themes';
  static const int _maxCustomThemes = 5; // 最多保存5个自定义主题
  
  late Box _box;
  RadarTheme _currentTheme = PresetRadarThemes.defaultTheme;
  List<RadarTheme> _customThemes = [];
  
  /// 当前激活的主题
  RadarTheme get currentTheme => _currentTheme;
  
  /// 所有预设主题
  List<RadarTheme> get presetThemes => PresetRadarThemes.presets;
  
  /// 自定义主题列表
  List<RadarTheme> get customThemes => _customThemes;
  
  /// 所有主题（预设 + 自定义）
  List<RadarTheme> get allThemes => [...presetThemes, ..._customThemes];
  
  /// 是否可以创建更多自定义主题
  bool get canCreateMoreCustomThemes => _customThemes.length < _maxCustomThemes;
  
  /// 初始化
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    await _loadThemes();
  }
  
  /// 加载主题
  Future<void> _loadThemes() async {
    // 加载当前主题ID
    final currentThemeId = _box.get(_currentThemeKey, defaultValue: 'preset_1') as String;
    
    // 加载自定义主题
    final customThemesData = _box.get(_customThemesKey, defaultValue: []) as List;
    _customThemes = customThemesData
        .map((data) => RadarTheme.fromJson(Map<String, dynamic>.from(data as Map)))
        .toList();
    
    // 设置当前主题
    _currentTheme = allThemes.firstWhere(
      (theme) => theme.id == currentThemeId,
      orElse: () => PresetRadarThemes.defaultTheme,
    );
    
    notifyListeners();
  }
  
  /// 切换主题
  Future<void> setTheme(RadarTheme theme) async {
    _currentTheme = theme;
    await _box.put(_currentThemeKey, theme.id);
    notifyListeners();
  }
  
  /// 创建自定义主题（基础模式）
  Future<RadarTheme?> createBasicCustomTheme({
    required String name,
    required Color athleticismColor,
    required Color awarenessColor,
    required Color techniqueColor,
    required Color mindColor,
  }) async {
    if (!canCreateMoreCustomThemes) {
      return null; // 已达到上限
    }
    
    final theme = RadarTheme(
      id: 'custom_${const Uuid().v4()}',
      name: name,
      isCustom: true,
      athleticismColor: athleticismColor,
      awarenessColor: awarenessColor,
      techniqueColor: techniqueColor,
      mindColor: mindColor,
    );
    
    await _saveCustomTheme(theme);
    return theme;
  }
  
  /// 创建自定义主题（高级模式）
  Future<RadarTheme?> createAdvancedCustomTheme({
    required String name,
    required List<Color> detailedColors, // 必须是12个颜色
  }) async {
    if (!canCreateMoreCustomThemes || detailedColors.length != 12) {
      return null;
    }
    
    final theme = RadarTheme(
      id: 'custom_${const Uuid().v4()}',
      name: name,
      isCustom: true,
      // 基础色从详细色中提取（每3个代表一个类别）
      athleticismColor: detailedColors[1], // 取中间色
      awarenessColor: detailedColors[4],
      techniqueColor: detailedColors[7],
      mindColor: detailedColors[10],
      detailedColors: detailedColors,
    );
    
    await _saveCustomTheme(theme);
    return theme;
  }
  
  /// 更新自定义主题
  Future<bool> updateCustomTheme(RadarTheme theme) async {
    if (!theme.isCustom) return false;
    
    final index = _customThemes.indexWhere((t) => t.id == theme.id);
    if (index == -1) return false;
    
    _customThemes[index] = theme;
    await _saveAllCustomThemes();
    
    // 如果更新的是当前主题，也更新当前主题
    if (_currentTheme.id == theme.id) {
      _currentTheme = theme;
    }
    
    notifyListeners();
    return true;
  }
  
  /// 删除自定义主题
  Future<bool> deleteCustomTheme(String themeId) async {
    final index = _customThemes.indexWhere((t) => t.id == themeId);
    if (index == -1) return false;
    
    _customThemes.removeAt(index);
    await _saveAllCustomThemes();
    
    // 如果删除的是当前主题，切换到默认主题
    if (_currentTheme.id == themeId) {
      await setTheme(PresetRadarThemes.defaultTheme);
    }
    
    notifyListeners();
    return true;
  }
  
  /// 保存单个自定义主题
  Future<void> _saveCustomTheme(RadarTheme theme) async {
    _customThemes.add(theme);
    await _saveAllCustomThemes();
    notifyListeners();
  }
  
  /// 保存所有自定义主题
  Future<void> _saveAllCustomThemes() async {
    final data = _customThemes.map((theme) => theme.toJson()).toList();
    await _box.put(_customThemesKey, data);
  }
  
  /// 根据ID查找主题
  RadarTheme? getThemeById(String id) {
    try {
      return allThemes.firstWhere((theme) => theme.id == id);
    } catch (_) {
      return null;
    }
  }
}
