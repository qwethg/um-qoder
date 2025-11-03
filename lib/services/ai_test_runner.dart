import 'package:flutter/foundation.dart';
import 'ai_integration_test.dart';
import '../models/assessment.dart';

/// AI测试运行器
/// 
/// 提供简单的接口来运行AI分析功能模块的各种测试
class AiTestRunner {
  static AiIntegrationTest? _integrationTest;
  
  /// 运行完整的AI功能测试套件
  static Future<void> runFullTestSuite() async {
    if (!kDebugMode) {
      print('⚠️ 测试只能在调试模式下运行');
      return;
    }
    
    print('🎯 启动AI分析功能模块完整测试套件...\n');
    
    try {
      _integrationTest = AiIntegrationTest();
      final report = await _integrationTest!.runFullTestSuite();
      
      // 打印测试报告摘要
      print('\n' + '=' * 60);
      print(report.generateSummary());
      print('=' * 60);
      
      // 打印详细测试结果
      print('\n📝 详细测试日志:');
      for (final result in report.testResults) {
        print(result);
      }
      
      // 性能测试结果
      if (report.performanceResults != null) {
        print('\n⚡ 性能测试结果:');
        _printPerformanceResults(report.performanceResults!);
      }
      
    } catch (e) {
      print('❌ 测试运行失败: $e');
    } finally {
      await _cleanup();
    }
  }
  
  /// 运行快速功能验证测试
  static Future<void> runQuickTest() async {
    if (!kDebugMode) {
      print('⚠️ 测试只能在调试模式下运行');
      return;
    }
    
    print('⚡ 启动AI功能快速验证测试...\n');
    
    try {
      _integrationTest = AiIntegrationTest();
      await _integrationTest!.initialize();
      
      // 创建一个简化的基础功能测试
      final basicResults = await _runQuickBasicTest();
      
      print('\n📊 快速测试结果:');
      print('  - 报告生成: ${basicResults.reportGeneration ? "✅" : "❌"}');
      print('  - 报告检索: ${basicResults.reportRetrieval ? "✅" : "❌"}');
      print('  - 报告质量: ${basicResults.reportQuality ? "✅" : "❌"}');
      print('  - 缓存一致性: ${basicResults.cacheConsistency ? "✅" : "❌"}');
      print('  - 生成时间: ${basicResults.generationTime}ms');
      
      final successRate = _calculateQuickTestSuccess(basicResults);
      print('\n🎯 快速测试成功率: ${(successRate * 100).toStringAsFixed(1)}%');
      
    } catch (e) {
      print('❌ 快速测试失败: $e');
    } finally {
      await _cleanup();
    }
  }
  
  /// 运行性能基准测试
  static Future<void> runPerformanceBenchmark() async {
    if (!kDebugMode) {
      print('⚠️ 测试只能在调试模式下运行');
      return;
    }
    
    print('🏃‍♂️ 启动AI性能基准测试...\n');
    
    try {
      _integrationTest = AiIntegrationTest();
      await _integrationTest!.initialize();
      
      // 运行简化的缓存性能测试
      final cacheResults = await _runQuickCacheTest();
      
      print('📊 缓存性能基准:');
      print('  - 首次生成时间: ${cacheResults.firstGenerationTime}ms');
      print('  - 缓存命中时间: ${cacheResults.cacheHitTime}ms');
      print('  - 性能提升倍数: ${cacheResults.speedImprovement.toStringAsFixed(2)}x');
      print('  - 缓存命中成功: ${cacheResults.cacheHitSuccess ? "✅" : "❌"}');
      
      // 评估性能等级
      final performanceGrade = _evaluatePerformance(cacheResults);
      print('\n🏆 性能等级: $performanceGrade');
      
    } catch (e) {
      print('❌ 性能基准测试失败: $e');
    } finally {
      await _cleanup();
    }
  }
  
  /// 运行存储可靠性测试
  static Future<void> runStorageReliabilityTest() async {
    if (!kDebugMode) {
      print('⚠️ 测试只能在调试模式下运行');
      return;
    }
    
    print('💾 启动存储可靠性测试...\n');
    
    try {
      _integrationTest = AiIntegrationTest();
      await _integrationTest!.initialize();
      
      // 运行简化的存储持久化测试
      final storageResults = await _runQuickStorageTest();
      
      print('📊 存储可靠性结果:');
      print('  - 报告保存: ${storageResults.reportSaved ? "✅" : "❌"}');
      print('  - 数据持久化: ${storageResults.reportPersisted ? "✅" : "❌"}');
      print('  - 数据完整性: ${storageResults.dataIntegrity ? "✅" : "❌"}');
      
      final reliabilityScore = _calculateReliabilityScore(storageResults);
      print('\n🛡️ 可靠性评分: ${(reliabilityScore * 100).toStringAsFixed(1)}%');
      
    } catch (e) {
      print('❌ 存储可靠性测试失败: $e');
    } finally {
      await _cleanup();
    }
  }
  
  /// 打印性能测试结果
  static void _printPerformanceResults(PerformanceTestReport report) {
    print('  📈 缓存命中率: ${(report.cacheResults.hitRate * 100).toStringAsFixed(1)}%');
    print('  ⏱️ 平均响应时间: ${report.responseTimeResults.averageTime}ms');
    print('  🚀 并发处理能力: ${report.concurrencyResults.successfulRequests}/${report.concurrencyResults.totalRequests}');
    print('  💾 存储效率: ${report.storageResults.compressionRatio.toStringAsFixed(2)}x');
  }
  
  /// 计算快速测试成功率
  static double _calculateQuickTestSuccess(BasicFunctionalityResults results) {
    int passed = 0;
    int total = 4;
    
    if (results.reportGeneration) passed++;
    if (results.reportRetrieval) passed++;
    if (results.reportQuality) passed++;
    if (results.cacheConsistency) passed++;
    
    return passed / total;
  }
  
  /// 评估性能等级
  static String _evaluatePerformance(CachePerformanceResults results) {
    if (!results.cacheHitSuccess) return '❌ 失败';
    
    if (results.speedImprovement >= 10) return '🥇 优秀 (10x+)';
    if (results.speedImprovement >= 5) return '🥈 良好 (5x+)';
    if (results.speedImprovement >= 2) return '🥉 及格 (2x+)';
    return '⚠️ 需要优化 (<2x)';
  }
  
  /// 计算可靠性评分
  static double _calculateReliabilityScore(StoragePersistenceResults results) {
    int passed = 0;
    int total = 3;
    
    if (results.reportSaved) passed++;
    if (results.reportPersisted) passed++;
    if (results.dataIntegrity) passed++;
    
    return passed / total;
  }
  
  /// 运行简化的基础功能测试
  static Future<BasicFunctionalityResults> _runQuickBasicTest() async {
    final results = BasicFunctionalityResults();
    
    try {
      // 创建测试评估
      final testAssessment = Assessment(
        id: 'quick_test_${DateTime.now().millisecondsSinceEpoch}',
        title: '快速测试评估',
        questions: [
          Question(
            id: 'q1',
            text: '测试问题',
            type: QuestionType.text,
            options: [],
          ),
        ],
        createdAt: DateTime.now(),
      );
      
      // 测试报告生成
      final stopwatch = Stopwatch()..start();
      final report = await _integrationTest!._enhancedAiService.generateAnalysisReport(
        testAssessment,
        '快速测试目标',
      );
      stopwatch.stop();
      
      results.reportGeneration = report != null;
      results.generationTime = stopwatch.elapsedMilliseconds;
      
      if (report != null) {
        results.reportQuality = report.content.isNotEmpty && 
                               report.summary.isNotEmpty;
        
        // 测试缓存检索
        final hasCache = await _integrationTest!._enhancedAiService.hasCachedReport(
          testAssessment,
          '快速测试目标',
        );
        results.reportRetrieval = hasCache;
        
        if (hasCache) {
          final cachedReport = await _integrationTest!._enhancedAiService.getCachedReport(
            testAssessment,
            '快速测试目标',
          );
          results.cacheConsistency = cachedReport?.id == report.id;
        }
      }
      
    } catch (e) {
      print('❌ 快速基础功能测试异常: $e');
    }
    
    return results;
  }
  
  /// 运行简化的缓存性能测试
  static Future<CachePerformanceResults> _runQuickCacheTest() async {
    final results = CachePerformanceResults();
    
    try {
      final testAssessment = Assessment(
        id: 'cache_test_${DateTime.now().millisecondsSinceEpoch}',
        title: '缓存测试评估',
        questions: [
          Question(
            id: 'q1',
            text: '缓存测试问题',
            type: QuestionType.text,
            options: [],
          ),
        ],
        createdAt: DateTime.now(),
      );
      
      // 首次生成
      final firstGenStopwatch = Stopwatch()..start();
      await _integrationTest!._enhancedAiService.generateAnalysisReport(
        testAssessment,
        '缓存测试目标',
      );
      firstGenStopwatch.stop();
      results.firstGenerationTime = firstGenStopwatch.elapsedMilliseconds;
      
      // 缓存命中测试
      final cacheHitStopwatch = Stopwatch()..start();
      final cachedReport = await _integrationTest!._enhancedAiService.getCachedReport(
        testAssessment,
        '缓存测试目标',
      );
      cacheHitStopwatch.stop();
      results.cacheHitTime = cacheHitStopwatch.elapsedMilliseconds;
      
      results.cacheHitSuccess = cachedReport != null;
      if (results.cacheHitTime > 0) {
        results.speedImprovement = results.firstGenerationTime / results.cacheHitTime;
      }
      
    } catch (e) {
      print('❌ 快速缓存性能测试异常: $e');
    }
    
    return results;
  }
  
  /// 运行简化的存储测试
  static Future<StoragePersistenceResults> _runQuickStorageTest() async {
    final results = StoragePersistenceResults();
    
    try {
      final testAssessment = Assessment(
        id: 'storage_test_${DateTime.now().millisecondsSinceEpoch}',
        title: '存储测试评估',
        questions: [
          Question(
            id: 'q1',
            text: '存储测试问题',
            type: QuestionType.text,
            options: [],
          ),
        ],
        createdAt: DateTime.now(),
      );
      
      // 生成并存储报告
      final report = await _integrationTest!._enhancedAiService.generateAnalysisReport(
        testAssessment,
        '存储测试目标',
      );
      
      results.reportSaved = report != null;
      
      if (report != null) {
        // 检查报告是否可以检索
        final retrievedReport = await _integrationTest!._enhancedAiService.getCachedReport(
          testAssessment,
          '存储测试目标',
        );
        
        results.reportPersisted = retrievedReport != null;
        results.dataIntegrity = retrievedReport?.id == report.id;
      }
      
    } catch (e) {
      print('❌ 快速存储测试异常: $e');
    }
    
    return results;
  }

  /// 清理测试环境
  static Future<void> _cleanup() async {
    try {
      await _integrationTest?.cleanup();
      _integrationTest = null;
      print('\n🧹 测试环境清理完成');
    } catch (e) {
      print('⚠️ 测试环境清理失败: $e');
    }
  }
  
  /// 显示测试菜单
  static void showTestMenu() {
    if (!kDebugMode) {
      print('⚠️ 测试功能只在调试模式下可用');
      return;
    }
    
    print('\n🧪 AI分析功能测试菜单');
    print('=' * 40);
    print('1. 运行完整测试套件 (runFullTestSuite)');
    print('2. 快速功能验证 (runQuickTest)');
    print('3. 性能基准测试 (runPerformanceBenchmark)');
    print('4. 存储可靠性测试 (runStorageReliabilityTest)');
    print('=' * 40);
    print('💡 在调试控制台中调用相应方法来运行测试');
    print('   例如: AiTestRunner.runQuickTest()');
  }
}