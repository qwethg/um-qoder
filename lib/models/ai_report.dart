import 'package:hive/hive.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';

part 'ai_report.g.dart';

/// AI 分析报告
@HiveType(typeId: 3)
class AiReport extends HiveObject {
  /// 报告唯一标识符
  @HiveField(0)
  final String id;

  /// 报告创建时间
  @HiveField(1)
  final DateTime createdAt;

  /// 报告更新时间
  @HiveField(2)
  final DateTime updatedAt;

  /// 报告版本号
  @HiveField(3)
  final int version;

  /// 关联的评估记录ID
  @HiveField(4)
  final String assessmentId;

  /// 上一次评估记录ID（用于对比分析）
  @HiveField(5)
  final String? previousAssessmentId;

  /// 输入数据哈希值（用于缓存判断）
  @HiveField(6)
  final String inputHash;

  /// AI 生成的报告内容（Markdown格式）
  @HiveField(7)
  final String content;

  /// 报告状态
  @HiveField(8)
  final AiReportStatus status;

  /// 生成报告时使用的AI模型
  @HiveField(9)
  final String aiModel;

  /// 生成报告时的API参数
  @HiveField(10)
  final Map<String, dynamic> apiParameters;

  /// 报告生成耗时（毫秒）
  @HiveField(11)
  final int? generationTimeMs;

  /// 报告标签（用于分类和检索）
  @HiveField(12)
  final List<String> tags;

  /// 用户评分（1-5星）
  @HiveField(13)
  final int? userRating;

  /// 用户反馈
  @HiveField(14)
  final String? userFeedback;

  /// 报告摘要（用于快速预览）
  @HiveField(15)
  final String? summary;

  /// 是否为缓存报告
  @HiveField(16)
  final bool isCached;

  /// 缓存过期时间
  @HiveField(17)
  final DateTime? cacheExpiresAt;

  AiReport({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.assessmentId,
    this.previousAssessmentId,
    required this.inputHash,
    required this.content,
    required this.status,
    required this.aiModel,
    required this.apiParameters,
    this.generationTimeMs,
    this.tags = const [],
    this.userRating,
    this.userFeedback,
    this.summary,
    this.isCached = false,
    this.cacheExpiresAt,
  });

  /// 创建新报告
  factory AiReport.create({
    required String assessmentId,
    String? previousAssessmentId,
    required String inputHash,
    required String content,
    required String aiModel,
    required Map<String, dynamic> apiParameters,
    int? generationTimeMs,
    List<String> tags = const [],
    String? summary,
    bool isCached = false,
    DateTime? cacheExpiresAt,
  }) {
    final now = DateTime.now();
    return AiReport(
      id: _generateId(),
      createdAt: now,
      updatedAt: now,
      version: 1,
      assessmentId: assessmentId,
      previousAssessmentId: previousAssessmentId,
      inputHash: inputHash,
      content: content,
      status: AiReportStatus.completed,
      aiModel: aiModel,
      apiParameters: apiParameters,
      generationTimeMs: generationTimeMs,
      tags: tags,
      summary: summary,
      isCached: isCached,
      cacheExpiresAt: cacheExpiresAt,
    );
  }

  /// 创建缓存报告副本
  AiReport copyAsCached({
    DateTime? cacheExpiresAt,
  }) {
    return AiReport(
      id: _generateId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: version,
      assessmentId: assessmentId,
      previousAssessmentId: previousAssessmentId,
      inputHash: inputHash,
      content: content,
      status: status,
      aiModel: aiModel,
      apiParameters: apiParameters,
      generationTimeMs: generationTimeMs,
      tags: tags,
      userRating: userRating,
      userFeedback: userFeedback,
      summary: summary,
      isCached: true,
      cacheExpiresAt: cacheExpiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );
  }

  /// 更新报告内容
  AiReport copyWith({
    String? content,
    AiReportStatus? status,
    int? userRating,
    String? userFeedback,
    String? summary,
    List<String>? tags,
  }) {
    return AiReport(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      version: version + 1,
      assessmentId: assessmentId,
      previousAssessmentId: previousAssessmentId,
      inputHash: inputHash,
      content: content ?? this.content,
      status: status ?? this.status,
      aiModel: aiModel,
      apiParameters: apiParameters,
      generationTimeMs: generationTimeMs,
      tags: tags ?? this.tags,
      userRating: userRating ?? this.userRating,
      userFeedback: userFeedback ?? this.userFeedback,
      summary: summary ?? this.summary,
      isCached: isCached,
      cacheExpiresAt: cacheExpiresAt,
    );
  }

  /// 检查缓存是否过期
  bool get isCacheExpired {
    if (!isCached || cacheExpiresAt == null) return false;
    return DateTime.now().isAfter(cacheExpiresAt!);
  }

  /// 检查报告是否有效
  bool get isValid {
    return status == AiReportStatus.completed && 
           content.isNotEmpty && 
           (!isCached || !isCacheExpired);
  }

  /// 生成报告ID
  static String _generateId() {
    return 'ai_report_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  @override
  String toString() {
    return 'AiReport(id: $id, assessmentId: $assessmentId, status: $status, version: $version)';
  }
}

/// AI 报告状态
@HiveType(typeId: 4)
enum AiReportStatus {
  /// 生成中
  @HiveField(0)
  generating,

  /// 已完成
  @HiveField(1)
  completed,

  /// 生成失败
  @HiveField(2)
  failed,

  /// 已过期
  @HiveField(3)
  expired,
}

/// 报告查询条件
class AiReportQuery {
  final String? assessmentId;
  final String? inputHash;
  final List<String>? tags;
  final AiReportStatus? status;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final bool? isCached;
  final bool? includeExpired;
  final int? limit;
  final int? offset;

  const AiReportQuery({
    this.assessmentId,
    this.inputHash,
    this.tags,
    this.status,
    this.createdAfter,
    this.createdBefore,
    this.isCached,
    this.includeExpired,
    this.limit,
    this.offset,
  });
}

/// 报告统计信息
class AiReportStats {
  final int totalReports;
  final int cachedReports;
  final int expiredReports;
  final double averageGenerationTime;
  final Map<AiReportStatus, int> statusCounts;
  final Map<String, int> tagCounts;

  const AiReportStats({
    required this.totalReports,
    required this.cachedReports,
    required this.expiredReports,
    required this.averageGenerationTime,
    required this.statusCounts,
    required this.tagCounts,
  });
}