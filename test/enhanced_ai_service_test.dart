import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ultimate_wheel/services/enhanced_ai_service.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ai_report.dart';

void main() {
  group('EnhancedAiService 性能测试', () {
    late EnhancedAiService aiService;
    late StorageService storageService;

    setUpAll(() async {
      // 初始化 Hive（内存模式，适合测试）
      Hive.init('.');
      
      // 注册适配器
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AssessmentAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GoalSettingAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(AiReportAdapter());
      }
      
      storageService = StorageService();
      await storageService.initialize();
      aiService = EnhancedAiService(storageService);
    });

    test('缓存检查性能测试', () async {
      // 创建测试数据
      final assessment = Assessment(
        id: 'test_assessment_1',
        createdAt: DateTime.now(),
        type: AssessmentType.deep,
        scores: {
          'ability1': 8.0,
          'ability2': 7.5,
          'ability3': 9.0,
        },
        notes: {'ability1': '测试备注'},
        overallNote: '整体表现良好',
      );

      final goalSettings = <String, GoalSetting>{
        'ability1': GoalSetting(
          abilityId: 'ability1',
          scoreDescriptions: {
            1: '需要改进',
            5: '一般水平',
            10: '优秀表现',
          },
        ),
      };

      // 测试缓存检查性能
      final stopwatch = Stopwatch()..start();
      
      final hasCached = await aiService.hasCachedReport(
        currentAssessment: assessment,
        userGoalSettings: goalSettings,
      );
      
      stopwatch.stop();
      
      print('缓存检查耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // 验证性能要求（应该在100ms以内）
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(hasCached, isA<bool>());
    });

    test('报告统计获取性能测试', () {
      final stopwatch = Stopwatch()..start();
      
      final stats = aiService.getReportStats();
      
      stopwatch.stop();
      
      print('统计获取耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // 验证性能要求（应该在50ms以内）
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(stats, isNotNull);
    });

    test('访问控制检查性能测试', () {
      final stopwatch = Stopwatch()..start();
      
      final userStats = aiService.getUserAccessStats();
      
      stopwatch.stop();
      
      print('访问统计耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // 验证性能要求（应该在30ms以内）
      expect(stopwatch.elapsedMilliseconds, lessThan(30));
      expect(userStats, isNotNull);
    });

    test('缓存清理性能测试', () async {
      final stopwatch = Stopwatch()..start();
      
      await aiService.cleanupExpiredCache();
      
      stopwatch.stop();
      
      print('缓存清理耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // 验证性能要求（应该在200ms以内）
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });
  });
}