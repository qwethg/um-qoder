import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';

/// AI 报告存储服务
class AiReportStorageService {
  static const String _reportBoxName = 'ai_reports';
  static const String _cacheIndexBoxName = 'ai_report_cache_index';
  
  late Box<AiReport> _reportBox;
  late Box _cacheIndexBox;

  /// 初始化存储服务
  Future<void> initialize() async {
    // 注册适配器
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AiReportAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AiReportStatusAdapter());
    }

    // 打开boxes
    _reportBox = await Hive.openBox<AiReport>(_reportBoxName);
    _cacheIndexBox = await Hive.openBox(_cacheIndexBoxName);

    // 清理过期缓存
    await _cleanupExpiredCache();
  }

  /// 保存AI报告
  Future<void> saveReport(AiReport report) async {
    await _reportBox.put(report.id, report);
    
    // 如果是缓存报告，更新缓存索引
    if (report.isCached) {
      await _updateCacheIndex(report);
    }
  }

  /// 根据输入哈希查找缓存报告
  Future<AiReport?> getCachedReport(String inputHash) async {
    // 先从缓存索引查找
    final cachedReportId = _cacheIndexBox.get(inputHash) as String?;
    if (cachedReportId == null) return null;

    // 获取报告
    final report = _reportBox.get(cachedReportId);
    if (report == null) {
      // 清理无效索引
      await _cacheIndexBox.delete(inputHash);
      return null;
    }

    // 检查是否过期
    if (report.isCacheExpired) {
      await _removeCachedReport(inputHash, cachedReportId);
      return null;
    }

    return report;
  }

  /// 根据ID获取报告
  AiReport? getReport(String id) {
    return _reportBox.get(id);
  }

  /// 根据评估ID获取所有相关报告
  List<AiReport> getReportsByAssessmentId(String assessmentId) {
    return _reportBox.values
        .where((report) => report.assessmentId == assessmentId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 获取最新的报告
  AiReport? getLatestReport() {
    final reports = getAllReports();
    return reports.isEmpty ? null : reports.first;
  }

  /// 获取所有报告
  List<AiReport> getAllReports() {
    return _reportBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 查询报告
  List<AiReport> queryReports(AiReportQuery query) {
    var reports = _reportBox.values.where((report) {
      // 评估ID过滤
      if (query.assessmentId != null && report.assessmentId != query.assessmentId) {
        return false;
      }

      // 输入哈希过滤
      if (query.inputHash != null && report.inputHash != query.inputHash) {
        return false;
      }

      // 状态过滤
      if (query.status != null && report.status != query.status) {
        return false;
      }

      // 缓存状态过滤
      if (query.isCached != null && report.isCached != query.isCached) {
        return false;
      }

      // 时间范围过滤
      if (query.createdAfter != null && report.createdAt.isBefore(query.createdAfter!)) {
        return false;
      }
      if (query.createdBefore != null && report.createdAt.isAfter(query.createdBefore!)) {
        return false;
      }

      // 过期状态过滤
      if (query.includeExpired == false && report.isCacheExpired) {
        return false;
      }

      // 标签过滤
      if (query.tags != null && query.tags!.isNotEmpty) {
        final hasMatchingTag = query.tags!.any((tag) => report.tags.contains(tag));
        if (!hasMatchingTag) return false;
      }

      return true;
    }).toList();

    // 排序
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 分页
    if (query.offset != null) {
      reports = reports.skip(query.offset!).toList();
    }
    if (query.limit != null) {
      reports = reports.take(query.limit!).toList();
    }

    return reports;
  }

  /// 删除报告
  Future<void> deleteReport(String id) async {
    final report = _reportBox.get(id);
    if (report != null && report.isCached) {
      // 清理缓存索引
      await _cacheIndexBox.delete(report.inputHash);
    }
    await _reportBox.delete(id);
  }

  /// 清空所有报告
  Future<void> clearAllReports() async {
    await _reportBox.clear();
    await _cacheIndexBox.clear();
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    await _cleanupExpiredCache();
  }

  /// 获取报告统计信息
  AiReportStats getStats() {
    final reports = _reportBox.values.toList();
    
    final statusCounts = <AiReportStatus, int>{};
    final tagCounts = <String, int>{};
    var totalGenerationTime = 0;
    var generationTimeCount = 0;
    var cachedCount = 0;
    var expiredCount = 0;

    for (final report in reports) {
      // 状态统计
      statusCounts[report.status] = (statusCounts[report.status] ?? 0) + 1;

      // 标签统计
      for (final tag in report.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }

      // 生成时间统计
      if (report.generationTimeMs != null) {
        totalGenerationTime += report.generationTimeMs!;
        generationTimeCount++;
      }

      // 缓存统计
      if (report.isCached) {
        cachedCount++;
        if (report.isCacheExpired) {
          expiredCount++;
        }
      }
    }

    final averageGenerationTime = generationTimeCount > 0 
        ? totalGenerationTime / generationTimeCount 
        : 0.0;

    return AiReportStats(
      totalReports: reports.length,
      cachedReports: cachedCount,
      expiredReports: expiredCount,
      averageGenerationTime: averageGenerationTime,
      statusCounts: statusCounts,
      tagCounts: tagCounts,
    );
  }

  /// 生成输入数据哈希值
  static String generateInputHash({
    required Assessment currentAssessment,
    required Map<String, GoalSetting> userGoalSettings,
    Assessment? previousAssessment,
    required String aiModel,
    required Map<String, dynamic> apiParameters,
  }) {
    final inputData = {
      'currentAssessment': {
        'id': currentAssessment.id,
        'type': currentAssessment.type.toString(),
        'scores': currentAssessment.scores,
        'notes': currentAssessment.notes,
        'overallNote': currentAssessment.overallNote,
      },
      'userGoalSettings': userGoalSettings.map(
        (key, value) => MapEntry(key, {
          'abilityId': value.abilityId,
          'scoreDescriptions': value.scoreDescriptions.map(
            (intKey, stringValue) => MapEntry(intKey.toString(), stringValue),
          ),
        }),
      ),
      'previousAssessment': previousAssessment != null ? {
        'id': previousAssessment.id,
        'type': previousAssessment.type.toString(),
        'scores': previousAssessment.scores,
        'notes': previousAssessment.notes,
        'overallNote': previousAssessment.overallNote,
      } : null,
      'aiModel': aiModel,
      'apiParameters': apiParameters,
    };

    final jsonString = jsonEncode(inputData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 检查是否存在相同输入的报告
  Future<bool> hasReportForInput(String inputHash) async {
    final cachedReport = await getCachedReport(inputHash);
    return cachedReport != null && cachedReport.isValid;
  }

  /// 更新缓存索引
  Future<void> _updateCacheIndex(AiReport report) async {
    await _cacheIndexBox.put(report.inputHash, report.id);
  }

  /// 移除缓存报告
  Future<void> _removeCachedReport(String inputHash, String reportId) async {
    await _cacheIndexBox.delete(inputHash);
    await _reportBox.delete(reportId);
  }

  /// 清理过期缓存
  Future<void> _cleanupExpiredCache() async {
    final now = DateTime.now();
    final expiredReports = _reportBox.values
        .where((report) => report.isCached && report.isCacheExpired)
        .toList();

    for (final report in expiredReports) {
      await _removeCachedReport(report.inputHash, report.id);
    }
  }

  /// 关闭存储服务
  Future<void> close() async {
    await _reportBox.close();
    await _cacheIndexBox.close();
  }
}