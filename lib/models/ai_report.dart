import 'package:hive/hive.dart';
import '../utils/opt.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';

part 'ai_report.g.dart';

/// AI 分析报告
@HiveType(typeId: 3)
class AiReport extends HiveObject {
  static const int currentVersion = 1;

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

  /// 输入数据哈希值（用于缓存判断）
  @HiveField(5)
  final String inputHash;

  /// AI 生成的报告内容（Markdown格式）
  @HiveField(6)
  final String? content;

  /// 报告状态
  @HiveField(7)
  final AiReportStatus status;

  /// 错误信息 (如果报告失败)
  @HiveField(8)
  final String? error;

  /// 生成报告时使用的AI模型
  @HiveField(9)
  final String aiModel;

  /// 生成报告时的API参数
  @HiveField(10)
  final Map<String, dynamic> apiParameters;

  /// 报告生成耗时 (毫秒)
  @HiveField(11)
  final int? generationTimeMs;

  /// 标签
  @HiveField(12)
  final List<String> tags;

  /// 是否为缓存报告
  @HiveField(13)
  final bool isCached;

  /// 缓存时间
  @HiveField(14)
  final DateTime? cachedAt;

  /// 缓存有效期 (默认30天)
  static const Duration cacheDuration = Duration(days: 30);

  AiReport({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.assessmentId,
    required this.inputHash,
    this.content,
    required this.status,
    this.error,
    required this.aiModel,
    this.generationTimeMs,
    this.apiParameters = const {},
    this.tags = const [],
    this.isCached = false,
    this.cachedAt,
  });

  /// 创建一个进行中的报告
  factory AiReport.inProgress({
    required String id,
    required String assessmentId,
    required String inputHash,
    required String aiModel,
    Map<String, dynamic> apiParameters = const {},
  }) {
    return AiReport(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: AiReport.currentVersion,
      assessmentId: assessmentId,
      inputHash: inputHash,
      status: AiReportStatus.generating,
      aiModel: aiModel,
      apiParameters: apiParameters,
    );
  }

  /// 创建一个失败的报告
  factory AiReport.failed({
    required String id,
    required String assessmentId,
    required String inputHash,
    String? error,
    Map<String, dynamic> apiParameters = const {},
  }) {
    return AiReport(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: AiReport.currentVersion,
      assessmentId: assessmentId,
      inputHash: inputHash,
      status: AiReportStatus.failed,
      error: error,
      aiModel: apiParameters['model'] ?? 'unknown',
      apiParameters: apiParameters,
    );
  }

  /// 创建一个完整的、成功的报告
  factory AiReport.create({
    required String id,
    required String assessmentId,
    required String inputHash,
    required String content,
    required String aiModel,
    AiReportStatus status = AiReportStatus.completed,
    int? generationTimeMs,
    Map<String, dynamic> apiParameters = const {},
    List<String> tags = const [],
  }) {
    return AiReport(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: AiReport.currentVersion,
      assessmentId: assessmentId,
      inputHash: inputHash,
      content: content,
      status: status,
      aiModel: aiModel,
      generationTimeMs: generationTimeMs,
      apiParameters: apiParameters,
      tags: tags,
    );
  }

  /// 复制当前报告并标记为已缓存
  AiReport copyAsCached() {
    return copyWith(
      isCached: true,
      cachedAt: DateTime.now(),
    );
  }

  AiReport copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? assessmentId,
    String? inputHash,
    String? content,
    AiReportStatus? status,
    String? error,
    String? aiModel,
    int? generationTimeMs,
    Map<String, dynamic>? apiParameters,
    List<String>? tags,
    bool? isCached,
    DateTime? cachedAt,
  }) {
    return AiReport(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      assessmentId: assessmentId ?? this.assessmentId,
      inputHash: inputHash ?? this.inputHash,
      content: content ?? this.content,
      status: status ?? this.status,
      error: error ?? this.error,
      aiModel: aiModel ?? this.aiModel,
      generationTimeMs: generationTimeMs ?? this.generationTimeMs,
      apiParameters: apiParameters ?? this.apiParameters,
      tags: tags ?? this.tags,
      isCached: isCached ?? this.isCached,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// 检查缓存是否过期
  bool get isCacheExpired {
    if (!isCached || cachedAt == null) return false;
    return DateTime.now().isAfter(cachedAt!.add(cacheDuration));
  }

  /// 检查报告是否有效
  bool get isValid {
    return status == AiReportStatus.completed &&
        content != null &&
        content!.isNotEmpty &&
        (!isCached || !isCacheExpired);
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