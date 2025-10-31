import 'package:hive/hive.dart';

part 'assessment.g.dart';

/// 评估记录
@HiveType(typeId: 0)
class Assessment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final AssessmentType type;

  @HiveField(3)
  final Map<String, double> scores; // abilityId -> score (0-10, 0.5刻度)

  @HiveField(4)
  final Map<String, String> notes; // abilityId -> note

  @HiveField(5)
  final String? overallNote;

  Assessment({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.scores,
    this.notes = const {},
    this.overallNote,
  });

  /// 计算总分
  double get totalScore {
    if (scores.isEmpty) return 0.0;
    return scores.values.reduce((a, b) => a + b);
  }

  /// 计算平均分
  double get averageScore {
    if (scores.isEmpty) return 0.0;
    return totalScore / scores.length;
  }

  /// 计算某个类别的平均分
  double getCategoryScore(List<String> abilityIds) {
    final categoryScores = scores.entries
        .where((entry) => abilityIds.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    
    if (categoryScores.isEmpty) return 0.0;
    return categoryScores.reduce((a, b) => a + b) / categoryScores.length;
  }
}

/// 评估类型
@HiveType(typeId: 1)
enum AssessmentType {
  @HiveField(0)
  deep,    // 深度评估
  
  @HiveField(1)
  quick,   // 快速评估
}
