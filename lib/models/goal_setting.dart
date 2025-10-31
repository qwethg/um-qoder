import 'package:hive/hive.dart';

part 'goal_setting.g.dart';

/// 目标设定
@HiveType(typeId: 2)
class GoalSetting extends HiveObject {
  @HiveField(0)
  final String abilityId;

  @HiveField(1)
  final Map<int, String> scoreDescriptions; // score -> description (3, 5, 7, 10)

  GoalSetting({
    required this.abilityId,
    required this.scoreDescriptions,
  });

  /// 获取指定分数的描述
  String? getDescription(int score) {
    return scoreDescriptions[score];
  }
}
