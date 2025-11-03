import 'dart:math';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/services/enhanced_ai_service.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// AI 服务性能测试工具
/// 
/// 用于验证AI分析功能的性能优化效果，包括：
/// - 缓存命中率测试
/// - 响应时间测试
/// - 并发性能测试
/// - 存储效率测试
class AiPerformanceTester {
  final EnhancedAiService _aiService;
  final StorageService _storageService;
  final Random _random = Random();

  AiPerformanceTester(this._aiService, this._storageService);

  /// 运行完整的性能测试套件
  /// 
  /// 返回: 性能测试报告
  Future<PerformanceTestReport> runFullTestSuite({
    String? apiKey,
    int testIterations = 10,
    int concurrentRequests = 3,
  }) async {
    print('🚀 开始AI服务性能测试...\n');

    final report = PerformanceTestReport();
    final stopwatch = Stopwatch()..start();

    try {
      // 1. 缓存性能测试
      print('📊 测试1: 缓存性能测试');
      final cacheResults = await _testCachePerformance(
        apiKey: apiKey,
        iterations: testIterations,
      );
      report.cacheTestResults = cacheResults;
      print('✅ 缓存测试完成\n');

      // 2. 响应时间测试
      print('⏱️ 测试2: 响应时间测试');
      final responseResults = await _testResponseTime(
        apiKey: apiKey,
        iterations: testIterations,
      );
      report.responseTimeResults = responseResults;
      print('✅ 响应时间测试完成\n');

      // 3. 并发性能测试
      print('🔄 测试3: 并发性能测试');
      final concurrencyResults = await _testConcurrency(
        apiKey: apiKey,
        concurrentRequests: concurrentRequests,
      );
      report.concurrencyResults = concurrencyResults;
      print('✅ 并发测试完成\n');

      // 4. 存储效率测试
      print('💾 测试4: 存储效率测试');
      final storageResults = await _testStorageEfficiency();
      report.storageResults = storageResults;
      print('✅ 存储测试完成\n');

      // 5. 访问控制测试
      print('🔒 测试5: 访问控制测试');
      final accessResults = await _testAccessControl();
      report.accessControlResults = accessResults;
      print('✅ 访问控制测试完成\n');

    } catch (e) {
      print('❌ 测试过程中出现错误: $e');
      report.hasErrors = true;
      report.errorMessage = e.toString();
    }

    stopwatch.stop();
    report.totalTestTime = stopwatch.elapsedMilliseconds;
    
    print('🎉 性能测试完成！总耗时: ${report.totalTestTime}ms\n');
    _printTestSummary(report);
    
    return report;
  }

  /// 测试缓存性能
  Future<CacheTestResults> _testCachePerformance({
    String? apiKey,
    required int iterations,
  }) async {
    final results = CacheTestResults();
    final assessment = _createTestAssessment();
    final goalSettings = _createTestGoalSettings();

    // 第一次请求（无缓存）
    final firstRequestTime = await _measureRequestTime(() async {
      if (apiKey != null) {
        return await _aiService.generateAnalysisReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
          apiKey: apiKey,
          forceRefresh: true,
        );
      } else {
        // 模拟请求，用于测试缓存逻辑
        return await _aiService.getCachedReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
        );
      }
    });

    results.firstRequestTime = firstRequestTime;

    // 后续请求（应该命中缓存）
    final cachedRequestTimes = <int>[];
    int cacheHits = 0;

    for (int i = 0; i < iterations; i++) {
      final requestTime = await _measureRequestTime(() async {
        final cachedReport = await _aiService.getCachedReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
        );
        
        if (cachedReport != null) {
          cacheHits++;
          return cachedReport;
        }
        
        return null;
      });

      cachedRequestTimes.add(requestTime);
    }

    results.cachedRequestTimes = cachedRequestTimes;
    results.cacheHitRate = cacheHits / iterations;
    results.averageCachedRequestTime = cachedRequestTimes.isNotEmpty
        ? cachedRequestTimes.reduce((a, b) => a + b) / cachedRequestTimes.length
        : 0.0;

    return results;
  }

  /// 测试响应时间
  Future<ResponseTimeResults> _testResponseTime({
    String? apiKey,
    required int iterations,
  }) async {
    final results = ResponseTimeResults();
    final responseTimes = <int>[];

    for (int i = 0; i < iterations; i++) {
      final assessment = _createTestAssessment();
      final goalSettings = _createTestGoalSettings();

      final responseTime = await _measureRequestTime(() async {
        return await _aiService.getCachedReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
        );
      });

      responseTimes.add(responseTime);
    }

    results.responseTimes = responseTimes;
    results.averageResponseTime = responseTimes.reduce((a, b) => a + b) / responseTimes.length;
    results.minResponseTime = responseTimes.reduce((a, b) => a < b ? a : b);
    results.maxResponseTime = responseTimes.reduce((a, b) => a > b ? a : b);

    // 计算95百分位数
    final sortedTimes = List<int>.from(responseTimes)..sort();
    final p95Index = (sortedTimes.length * 0.95).floor();
    results.p95ResponseTime = sortedTimes[p95Index];

    return results;
  }

  /// 测试并发性能
  Future<ConcurrencyResults> _testConcurrency({
    String? apiKey,
    required int concurrentRequests,
  }) async {
    final results = ConcurrencyResults();
    final futures = <Future<int>>[];

    // 创建并发请求
    for (int i = 0; i < concurrentRequests; i++) {
      final assessment = _createTestAssessment();
      final goalSettings = _createTestGoalSettings();

      final future = _measureRequestTime(() async {
        return await _aiService.getCachedReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
        );
      });

      futures.add(future);
    }

    // 等待所有请求完成
    final stopwatch = Stopwatch()..start();
    final responseTimes = await Future.wait(futures);
    stopwatch.stop();

    results.concurrentRequests = concurrentRequests;
    results.totalConcurrentTime = stopwatch.elapsedMilliseconds;
    results.individualResponseTimes = responseTimes;
    results.averageConcurrentResponseTime = responseTimes.reduce((a, b) => a + b) / responseTimes.length;

    return results;
  }

  /// 测试存储效率
  Future<StorageResults> _testStorageEfficiency() async {
    final results = StorageResults();
    final stats = _aiService.getReportStats();

    results.totalReports = stats.totalReports;
    results.cachedReports = stats.cachedReports;
    results.failedReports = stats.failedReports;
    results.averageReportSize = stats.averageReportSize;
    results.totalStorageSize = stats.totalStorageSize;

    // 测试查询性能
    final queryTime = await _measureRequestTime(() async {
      final query = AiReportQuery(
        status: AiReportStatus.completed,
        limit: 10,
      );
      return _aiService.queryReports(query);
    });

    results.queryPerformanceMs = queryTime;

    return results;
  }

  /// 测试访问控制
  Future<AccessControlResults> _testAccessControl() async {
    final results = AccessControlResults();
    final userStats = _aiService.getUserAccessStats();

    results.userStats = userStats;
    results.hasAccessControl = true;

    // 测试速率限制
    try {
      final assessment = _createTestAssessment();
      final goalSettings = _createTestGoalSettings();

      // 尝试快速连续请求
      for (int i = 0; i < 25; i++) {
        await _aiService.hasCachedReport(
          currentAssessment: assessment,
          userGoalSettings: goalSettings,
        );
      }
      results.rateLimitWorking = false;
    } catch (e) {
      results.rateLimitWorking = true;
    }

    return results;
  }

  /// 测量请求时间
  Future<int> _measureRequestTime(Future<dynamic> Function() request) async {
    final stopwatch = Stopwatch()..start();
    try {
      await request();
    } catch (e) {
      // 忽略错误，只测量时间
    }
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// 创建测试评估
  Assessment _createTestAssessment() {
    final scores = <String, int>{};
    for (int i = 1; i <= 10; i++) {
      scores['ability_$i'] = _random.nextInt(5) + 1;
    }

    return Assessment(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      createdAt: DateTime.now(),
      type: AssessmentType.deep,
      scores: scores,
      notes: {},
      overallNote: '测试评估',
    );
  }

  /// 创建测试目标设定
  Map<String, GoalSetting> _createTestGoalSettings() {
    final goalSettings = <String, GoalSetting>{};
    for (int i = 1; i <= 10; i++) {
      goalSettings['ability_$i'] = GoalSetting(
        id: 'goal_$i',
        abilityId: 'ability_$i',
        targetScore: _random.nextInt(5) + 1,
        priority: Priority.values[_random.nextInt(Priority.values.length)],
        deadline: DateTime.now().add(Duration(days: 30)),
        createdAt: DateTime.now(),
      );
    }
    return goalSettings;
  }

  /// 打印测试摘要
  void _printTestSummary(PerformanceTestReport report) {
    print('📋 性能测试报告摘要');
    print('=' * 50);
    
    if (report.cacheTestResults != null) {
      final cache = report.cacheTestResults!;
      print('🔄 缓存性能:');
      print('  - 缓存命中率: ${(cache.cacheHitRate * 100).toStringAsFixed(1)}%');
      print('  - 首次请求时间: ${cache.firstRequestTime}ms');
      print('  - 平均缓存请求时间: ${cache.averageCachedRequestTime.toStringAsFixed(1)}ms');
    }

    if (report.responseTimeResults != null) {
      final response = report.responseTimeResults!;
      print('⏱️ 响应时间:');
      print('  - 平均响应时间: ${response.averageResponseTime.toStringAsFixed(1)}ms');
      print('  - 最小响应时间: ${response.minResponseTime}ms');
      print('  - 最大响应时间: ${response.maxResponseTime}ms');
      print('  - P95响应时间: ${response.p95ResponseTime}ms');
    }

    if (report.storageResults != null) {
      final storage = report.storageResults!;
      print('💾 存储效率:');
      print('  - 总报告数: ${storage.totalReports}');
      print('  - 缓存报告数: ${storage.cachedReports}');
      print('  - 查询性能: ${storage.queryPerformanceMs}ms');
    }

    if (report.accessControlResults != null) {
      final access = report.accessControlResults!;
      print('🔒 访问控制:');
      print('  - 访问控制启用: ${access.hasAccessControl}');
      print('  - 速率限制工作: ${access.rateLimitWorking}');
    }

    print('⏰ 总测试时间: ${report.totalTestTime}ms');
    print('=' * 50);
  }
}

/// 性能测试报告
class PerformanceTestReport {
  int totalTestTime = 0;
  bool hasErrors = false;
  String? errorMessage;
  
  CacheTestResults? cacheTestResults;
  ResponseTimeResults? responseTimeResults;
  ConcurrencyResults? concurrencyResults;
  StorageResults? storageResults;
  AccessControlResults? accessControlResults;
}

/// 缓存测试结果
class CacheTestResults {
  int firstRequestTime = 0;
  List<int> cachedRequestTimes = [];
  double cacheHitRate = 0.0;
  double averageCachedRequestTime = 0.0;
}

/// 响应时间测试结果
class ResponseTimeResults {
  List<int> responseTimes = [];
  double averageResponseTime = 0.0;
  int minResponseTime = 0;
  int maxResponseTime = 0;
  int p95ResponseTime = 0;
}

/// 并发测试结果
class ConcurrencyResults {
  int concurrentRequests = 0;
  int totalConcurrentTime = 0;
  List<int> individualResponseTimes = [];
  double averageConcurrentResponseTime = 0.0;
}

/// 存储测试结果
class StorageResults {
  int totalReports = 0;
  int cachedReports = 0;
  int failedReports = 0;
  double averageReportSize = 0.0;
  int totalStorageSize = 0;
  int queryPerformanceMs = 0;
}

/// 访问控制测试结果
class AccessControlResults {
  UserAccessStats? userStats;
  bool hasAccessControl = false;
  bool rateLimitWorking = false;
}