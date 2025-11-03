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

  @HiveField(6)
  final String? aiAnalysisContent; // AI分析报告完整内容

  @HiveField(7)
  final DateTime? aiAnalysisGeneratedAt; // AI分析生成时间

  @HiveField(8)
  final String? aiAnalysisSummary; // AI分析摘要（用于折叠显示）

  Assessment({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.scores,
    this.notes = const {},
    this.overallNote,
    this.aiAnalysisContent,
    this.aiAnalysisGeneratedAt,
    this.aiAnalysisSummary,
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

  /// 创建副本并更新指定字段
  Assessment copyWith({
    String? id,
    DateTime? createdAt,
    AssessmentType? type,
    Map<String, double>? scores,
    Map<String, String>? notes,
    String? overallNote,
    String? aiAnalysisContent,
    DateTime? aiAnalysisGeneratedAt,
    String? aiAnalysisSummary,
  }) {
    return Assessment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      scores: scores ?? this.scores,
      notes: notes ?? this.notes,
      overallNote: overallNote ?? this.overallNote,
      aiAnalysisContent: aiAnalysisContent ?? this.aiAnalysisContent,
      aiAnalysisGeneratedAt: aiAnalysisGeneratedAt ?? this.aiAnalysisGeneratedAt,
      aiAnalysisSummary: aiAnalysisSummary ?? this.aiAnalysisSummary,
    );
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
