// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radar_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarTheme _$RadarThemeFromJson(Map<String, dynamic> json) => RadarTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      athleticismColor:
          RadarTheme._colorFromJson((json['athleticismColor'] as num).toInt()),
      awarenessColor:
          RadarTheme._colorFromJson((json['awarenessColor'] as num).toInt()),
      techniqueColor:
          RadarTheme._colorFromJson((json['techniqueColor'] as num).toInt()),
      mindColor: RadarTheme._colorFromJson((json['mindColor'] as num).toInt()),
      detailedColors:
          RadarTheme._colorListFromJson(json['detailedColors'] as List?),
    );

Map<String, dynamic> _$RadarThemeToJson(RadarTheme instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isCustom': instance.isCustom,
      'isDefault': instance.isDefault,
      'athleticismColor': RadarTheme._colorToJson(instance.athleticismColor),
      'awarenessColor': RadarTheme._colorToJson(instance.awarenessColor),
      'techniqueColor': RadarTheme._colorToJson(instance.techniqueColor),
      'mindColor': RadarTheme._colorToJson(instance.mindColor),
      'detailedColors': RadarTheme._colorListToJson(instance.detailedColors),
    };
