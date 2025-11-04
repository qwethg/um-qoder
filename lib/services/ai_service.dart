import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/services/enhanced_ai_service.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// AI 智能分析服务
///
/// 注意：此服务已升级为增强版本，支持缓存和存储功能。
/// 建议使用 EnhancedAiService 获得更好的性能和功能。
class AiService {
  final StorageService _storageService;
  late final EnhancedAiService _enhancedService;

  AiService(this._storageService, {required String apiKey}) {
    _enhancedService = EnhancedAiService(
      apiKey: apiKey,
      storageService: _storageService,
    );
  }

  /// 生成 AI 分析报告（流式）
  ///
  /// 参数:
  /// - [assessment]: 当前的评估结果
  /// - [goalSettings]: 用户的目标设定
  /// - [forceRefresh]: 是否强制刷新，忽略缓存
  ///
  /// 返回: AI 分析报告的流
  Stream<AiReport> generateReport({
    required Assessment assessment,
    required Map<String, GoalSetting> goalSettings,
    bool forceRefresh = false,
  }) {
    return _enhancedService.generateReport(
      assessment: assessment,
      goalSettings: goalSettings,
      forceRefresh: forceRefresh,
    );
  }

  /// 获取评估相关的所有报告
  Future<List<AiReport>> getReportsForAssessment(String assessmentId) async {
    return await _storageService.aiReportStorage
        .getReportsByAssessmentId(assessmentId);
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    await _storageService.aiReportStorage.cleanupExpiredCache();
  }
}

/// AI 服务异常
class AiServiceException implements Exception {
  final String message;

  AiServiceException(this.message);

  @override
  String toString() => message;
}
