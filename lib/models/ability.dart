import 'package:flutter/material.dart';

/// 能力项模型
class Ability {
  final String id;
  final String name;
  final String nameEn;
  final IconData icon;  // 使用Material Icons
  final AbilityCategory category;
  final String description;
  final int order;

  const Ability({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.category,
    required this.description,
    required this.order,
  });
}

/// 能力类别
enum AbilityCategory {
  athleticism, // 身体
  awareness,   // 意识
  technique,   // 技术
  mind,        // 心灵
}

/// 能力类别扩展
extension AbilityCategoryExtension on AbilityCategory {
  String get name {
    switch (this) {
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

  String get nameEn {
    switch (this) {
      case AbilityCategory.athleticism:
        return 'Athleticism';
      case AbilityCategory.awareness:
        return 'Awareness';
      case AbilityCategory.technique:
        return 'Technique';
      case AbilityCategory.mind:
        return 'Mind';
    }
  }

  IconData get icon {
    switch (this) {
      case AbilityCategory.athleticism:
        return Icons.directions_run;
      case AbilityCategory.awareness:
        return Icons.visibility;
      case AbilityCategory.technique:
        return Icons.build;
      case AbilityCategory.mind:
        return Icons.favorite;
    }
  }

  int get colorIndex {
    switch (this) {
      case AbilityCategory.athleticism:
        return 0; // 橙/红色系
      case AbilityCategory.awareness:
        return 1; // 蓝/紫色系
      case AbilityCategory.technique:
        return 2; // 绿/青色系
      case AbilityCategory.mind:
        return 3; // 粉/暖色系
    }
  }
}
