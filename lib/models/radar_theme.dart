import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'radar_theme.g.dart';

/// 雷达图主题模型
@JsonSerializable()
class RadarTheme {
  final String id;
  final String name;           // 主题名称
  final bool isCustom;         // 是否自定义
  final bool isDefault;        // 是否默认主题
  
  // 4大类别基础色（存储为RGB值）
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color athleticismColor;  // 身体
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color awarenessColor;    // 意识
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color techniqueColor;    // 技术
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color mindColor;         // 心灵
  
  // 12个子项详细色（可选，自定义高级模式用）
  @JsonKey(fromJson: _colorListFromJson, toJson: _colorListToJson)
  final List<Color>? detailedColors;

  const RadarTheme({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.isDefault = false,
    required this.athleticismColor,
    required this.awarenessColor,
    required this.techniqueColor,
    required this.mindColor,
    this.detailedColors,
  });

  /// 获取类别颜色
  Color getCategoryColor(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return athleticismColor;
      case 1:
        return awarenessColor;
      case 2:
        return techniqueColor;
      case 3:
        return mindColor;
      default:
        return athleticismColor;
    }
  }

  /// 获取类别渐变色（自动生成3个渐变色）
  List<Color> getCategoryGradient(int categoryIndex) {
    final baseColor = getCategoryColor(categoryIndex);
    
    // 如果有详细颜色定义，从详细颜色中提取对应类别的3个颜色
    if (detailedColors != null && detailedColors!.length == 12) {
      final startIndex = categoryIndex * 3;
      return detailedColors!.sublist(startIndex, startIndex + 3);
    }
    
    // 方案C：组合明度调整和色相偏移（增加区分度）
    final hslColor = HSLColor.fromColor(baseColor);
    
    return [
      // 浅色：提高明度，降低饱和度，色相偏移
      hslColor
          .withLightness((hslColor.lightness * 1.2).clamp(0.0, 1.0))
          .withSaturation((hslColor.saturation * 0.8).clamp(0.0, 1.0))
          .withHue((hslColor.hue - 15) % 360)
          .toColor(),
      // 基础色
      baseColor,
      // 深色：降低明度，提高饱和度，色相偏移
      hslColor
          .withLightness((hslColor.lightness * 0.8).clamp(0.0, 1.0))
          .withSaturation((hslColor.saturation * 1.2).clamp(0.0, 1.0))
          .withHue((hslColor.hue + 15) % 360)
          .toColor(),
    ];
  }

  /// 复制并修改主题
  RadarTheme copyWith({
    String? id,
    String? name,
    bool? isCustom,
    bool? isDefault,
    Color? athleticismColor,
    Color? awarenessColor,
    Color? techniqueColor,
    Color? mindColor,
    List<Color>? detailedColors,
  }) {
    return RadarTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      isDefault: isDefault ?? this.isDefault,
      athleticismColor: athleticismColor ?? this.athleticismColor,
      awarenessColor: awarenessColor ?? this.awarenessColor,
      techniqueColor: techniqueColor ?? this.techniqueColor,
      mindColor: mindColor ?? this.mindColor,
      detailedColors: detailedColors ?? this.detailedColors,
    );
  }

  // JSON序列化
  factory RadarTheme.fromJson(Map<String, dynamic> json) => _$RadarThemeFromJson(json);
  Map<String, dynamic> toJson() => _$RadarThemeToJson(this);

  // Color转换辅助函数
  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;
  
  static List<Color>? _colorListFromJson(List<dynamic>? json) {
    if (json == null) return null;
    return json.map((e) => Color(e as int)).toList();
  }
  
  static List<int>? _colorListToJson(List<Color>? colors) {
    if (colors == null) return null;
    return colors.map((c) => c.value).toList();
  }
}

/// 预设主题常量
class PresetRadarThemes {
  static const List<RadarTheme> presets = [
    // 1. 古雅石庭
    RadarTheme(
      id: 'preset_1',
      name: '古雅石庭',
      isDefault: true,
      athleticismColor: Color(0xFF867468),
      awarenessColor: Color(0xFFD9D6CC),
      techniqueColor: Color(0xFF77796F),
      mindColor: Color(0xFFB45253),
    ),
    // 2. 烟雨江南
    RadarTheme(
      id: 'preset_2',
      name: '烟雨江南',
      athleticismColor: Color(0xFF877A51),
      awarenessColor: Color(0xFFAEC5BF),
      techniqueColor: Color(0xFF669890),
      mindColor: Color(0xFF9F81AA),
    ),
    // 3. 桃花春酿
    RadarTheme(
      id: 'preset_3',
      name: '桃花春酿',
      athleticismColor: Color(0xFF9E6582),
      awarenessColor: Color(0xFFD07C94),
      techniqueColor: Color(0xFFE4B3C0),
      mindColor: Color(0xFFF3D4E3),
    ),
    // 5. 暮夜星辰
    RadarTheme(
      id: 'preset_5',
      name: '暮夜星辰',
      athleticismColor: Color(0xFF2C2E3A),
      awarenessColor: Color(0xFF45455B),
      techniqueColor: Color(0xFF6D798C),
      mindColor: Color(0xFF9CA7AF),
    ),
    // 6. 秋柿晚照
    RadarTheme(
      id: 'preset_6',
      name: '秋柿晚照',
      athleticismColor: Color(0xFFE68E46),
      awarenessColor: Color(0xFF2F504C),
      techniqueColor: Color(0xFF563437),
      mindColor: Color(0xFFE7BEBE),
    ),
    // 8. 碧海青山
    RadarTheme(
      id: 'preset_8',
      name: '碧海青山',
      athleticismColor: Color(0xFF3C9A7F),
      awarenessColor: Color(0xFF2E89B6),
      techniqueColor: Color(0xFFA0A495),
      mindColor: Color(0xFFCDB39A),
    ),
    // 9. 蒙德里安·绿野
    RadarTheme(
      id: 'preset_9',
      name: '蒙德里安·绿野',
      athleticismColor: Color(0xFF019E51),
      awarenessColor: Color(0xFFF38E00),
      techniqueColor: Color(0xFFE93F28),
      mindColor: Color(0xFF007EC8),
    ),
    // 10. 蒙德里安·晴空
    RadarTheme(
      id: 'preset_10',
      name: '蒙德里安·晴空',
      athleticismColor: Color(0xFF00CDF7),
      awarenessColor: Color(0xFF194790),
      techniqueColor: Color(0xFFFFDB00),
      mindColor: Color(0xFFFF5231),
    ),
    // 12. 马蒂斯·紫韵
    RadarTheme(
      id: 'preset_12',
      name: '马蒂斯·紫韵',
      athleticismColor: Color(0xFFB982BD),
      awarenessColor: Color(0xFF26AC55),
      techniqueColor: Color(0xFF2896BD),
      mindColor: Color(0xFF444AB1),
    ),
    // 13. 马蒂斯·深海
    RadarTheme(
      id: 'preset_13',
      name: '马蒂斯·深海',
      athleticismColor: Color(0xFF198F9B),
      awarenessColor: Color(0xFFF1521A),
      techniqueColor: Color(0xFF1D36AC),
      mindColor: Color(0xFF690813),
    ),
    // 14. 马蒂斯·活力
    RadarTheme(
      id: 'preset_14',
      name: '马蒂斯·活力',
      athleticismColor: Color(0xFF7AB206),
      awarenessColor: Color(0xFFF68703),
      techniqueColor: Color(0xFF1E59D0),
      mindColor: Color(0xFFBF1413),
    ),
    // 15. 暮色霞光
    RadarTheme(
      id: 'preset_15',
      name: '暮色霞光',
      athleticismColor: Color(0xFF5B2C37),
      awarenessColor: Color(0xFFAD6C29),
      techniqueColor: Color(0xFF495D34),
      mindColor: Color(0xFF6C559B),
    ),
    // 16. 律动霓虹
    RadarTheme(
      id: 'preset_16',
      name: '律动霓虹',
      athleticismColor: Color(0xFF4100F5),
      awarenessColor: Color(0xFFCDF564),
      techniqueColor: Color(0xFF9BF0E1),
      mindColor: Color(0xFFF037A5),
    ),
  ];

  /// 获取默认主题
  static RadarTheme get defaultTheme => presets.first;
}
