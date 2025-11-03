// Ultimate Wheel 应用基础测试
//
// 测试应用的基本功能和组件

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ultimate_wheel/main.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';

void main() {
  group('Ultimate Wheel App Tests', () {
    setUpAll(() async {
      // 初始化 Hive 用于测试
      await Hive.initFlutter();
    });

    testWidgets('App should build without errors', (WidgetTester tester) async {
      // 创建测试用的服务
      final storageService = StorageService();
      await storageService.initialize();
      
      final radarThemeProvider = RadarThemeProvider();
      await radarThemeProvider.init();

      // 构建应用
      await tester.pumpWidget(UltimateWheelApp(
        storageService: storageService,
        radarThemeProvider: radarThemeProvider,
      ));

      // 验证应用能够正常构建
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
