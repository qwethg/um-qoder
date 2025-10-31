import 'package:ultimate_wheel/models/ability.dart';
import 'package:flutter/material.dart';

/// 12项核心能力定义
class AbilityConstants {
  static const List<Ability> abilities = [
    // 身体 (3项)
    Ability(
      id: 'running_jumping',
      name: '跑跳',
      nameEn: 'Running & Jumping',
      icon: Icons.directions_run,
      category: AbilityCategory.athleticism,
      description: '绝对速度、爆发力、弹跳高度',
      order: 0,
    ),
    Ability(
      id: 'agility',
      name: '灵敏',
      nameEn: 'Agility',
      icon: Icons.flash_on,
      category: AbilityCategory.athleticism,
      description: '变向、急停、身体控制和协调能力',
      order: 1,
    ),
    Ability(
      id: 'endurance',
      name: '体力',
      nameEn: 'Endurance',
      icon: Icons.fitness_center,
      category: AbilityCategory.athleticism,
      description: '场上续航、恢复速度、多场次作战能力',
      order: 2,
    ),

    // 意识 (3项)
    Ability(
      id: 'spatial_awareness',
      name: '空间感',
      nameEn: 'Spatial Awareness',
      icon: Icons.location_searching,
      category: AbilityCategory.awareness,
      description: '场上位置感，观察和利用空间的能力',
      order: 3,
    ),
    Ability(
      id: 'timing',
      name: '时机感',
      nameEn: 'Timing',
      icon: Icons.access_time,
      category: AbilityCategory.awareness,
      description: '对盘的飞行、人的跑动时间的预判能力',
      order: 4,
    ),
    Ability(
      id: 'game_iq',
      name: '明智',
      nameEn: 'Game IQ',
      icon: Icons.psychology,
      category: AbilityCategory.awareness,
      description: '战术理解、场上决策能力',
      order: 5,
    ),

    // 技术 (4项)
    Ability(
      id: 'throwing',
      name: '传盘',
      nameEn: 'Throwing',
      icon: Icons.sports_baseball,
      category: AbilityCategory.technique,
      description: '各式传盘的精准度、力度和旋转控制',
      order: 6,
    ),
    Ability(
      id: 'catching',
      name: '接盘/读盘',
      nameEn: 'Catching/Reading',
      icon: Icons.pan_tool,
      category: AbilityCategory.technique,
      description: '阅读飞行轨迹、稳定接盘、极限接盘的能力',
      order: 7,
    ),
    Ability(
      id: 'marking',
      name: '盯防',
      nameEn: 'Marking',
      icon: Icons.shield,
      category: AbilityCategory.technique,
      description: '限制对手传盘的能力，包括站位、脚步、反应速度和有效的干扰',
      order: 8,
    ),
    Ability(
      id: 'defending',
      name: '跟防',
      nameEn: 'Defending',
      icon: Icons.security,
      category: AbilityCategory.technique,
      description: '通过跑位、预判、起跳或飞扑（Layout）来获得防守得分（Block）的能力',
      order: 9,
    ),

    // 心灵 (2项)
    Ability(
      id: 'teamwork',
      name: '团队',
      nameEn: 'Teamwork',
      icon: Icons.groups,
      category: AbilityCategory.mind,
      description: '沟通、鼓励、融入体系、化学反应',
      order: 10,
    ),
    Ability(
      id: 'mentality',
      name: '心态',
      nameEn: 'Mentality',
      icon: Icons.self_improvement,
      category: AbilityCategory.mind,
      description: '专注度、抗压能力、情绪控制、飞盘精神',
      order: 11,
    ),
  ];

  /// 根据类别获取能力列表
  static List<Ability> getAbilitiesByCategory(AbilityCategory category) {
    return abilities.where((a) => a.category == category).toList();
  }

  /// 根据ID获取能力
  static Ability? getAbilityById(String id) {
    try {
      return abilities.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有类别
  static List<AbilityCategory> get categories => AbilityCategory.values;
}

/// 默认目标设定文本
class DefaultGoalTexts {
  static const Map<String, Map<int, String>> defaults = {
    // 身体
    'running_jumping': {
      3: '能够跟上场上的节奏，有基本的速度和跳跃能力',
      5: '在跑动和起跳时表现稳定，速度中等偏上',
      7: '拥有出色的爆发力，能在关键时刻展现速度优势',
      10: '场上最快的选手之一，跳跃和冲刺能力顶尖',
    },
    'agility': {
      3: '能够完成基本的变向动作，身体协调性尚可',
      5: '变向和急停比较流畅，很少失去平衡',
      7: '拥有出色的身体控制能力，变向敏捷且精准',
      10: '如同芭蕾舞者般的身体控制，任何动作都流畅自如',
    },
    'endurance': {
      3: '能打完一场比赛，但后程明显体力下降',
      5: '可以完整打完比赛，恢复速度正常',
      7: '能打满全场高强度比赛，第二天依然精力充沛',
      10: '体力似乎永不枯竭，可以连续多场高强度作战',
    },

    // 意识
    'spatial_awareness': {
      3: '对场上位置有基本认知，偶尔会站位不佳',
      5: '较好的空间感，能找到合理位置',
      7: '优秀的场上视野，总能出现在该出现的位置',
      10: '如同开了上帝视角，场上空间利用炉火纯青',
    },
    'timing': {
      3: '对时机把握不够准确，偶尔会提前或延后',
      5: '时机感良好，大多数情况能准确预判',
      7: '出色的预判能力，时机把握精准',
      10: '仿佛能预见未来，时机把握完美无瑕',
    },
    'game_iq': {
      3: '了解基本战术，能执行简单指令',
      5: '理解战术体系，能做出合理决策',
      7: '战术理解深刻，场上决策明智且果断',
      10: '战术大师，能洞察全局并引领团队',
    },

    // 技术
    'throwing': {
      3: '能完成基本传盘，准确率有待提高',
      5: '传盘稳定，掌握2-3种常用传盘方式',
      7: '传盘精准且多样化，能应对各种场景',
      10: '传盘如同艺术，精准度、力度、旋转控制完美',
    },
    'catching': {
      3: '能接住大部分常规传盘，偶尔掉盘',
      5: '接盘稳定，能读懂大部分飞行轨迹',
      7: '接盘能力出色，能完成一些高难度接盘',
      10: '仿佛飞盘有磁性，任何盘都能稳稳接住',
    },
    'marking': {
      3: '了解盯防基本原则，能给予一定压力',
      5: '盯防积极，能有效限制对手部分传盘选择',
      7: '盯防技术精湛，站位和时机把握到位',
      10: '防守大师，让对手感到窒息般的压迫',
    },
    'defending': {
      3: '跟防时能跟上对手，偶尔能形成干扰',
      5: '跟防稳定，有一定的预判和协防意识',
      7: '跟防能力强，经常能完成Block',
      10: '防守如影随形，Block率极高',
    },

    // 心灵
    'teamwork': {
      3: '能与队友基本配合，沟通略显不足',
      5: '团队协作良好，沟通积极',
      7: '团队核心成员，善于鼓励和融合团队',
      10: '团队灵魂，化学反应完美，让队友变得更好',
    },
    'mentality': {
      3: '比赛中偶尔情绪波动，专注度不稳定',
      5: '心态较稳定，能保持基本专注',
      7: '心态成熟，抗压能力强，飞盘精神良好',
      10: '心如止水，任何情况下都保持冷静和专注',
    },
  };

  /// 获取指定能力和分数的默认文本
  static String? getDefault(String abilityId, int score) {
    return defaults[abilityId]?[score];
  }
}
