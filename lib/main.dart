import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/router.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/services/logger_service.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/settings_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      logger.error('Flutter 框架捕获到错误', details.exception, details.stack);
    };

    // 初始化 Hive
    await Hive.initFlutter();

    // 初始化存储服务
    final storageService = StorageService();
    await storageService.initialize();

    // 初始化雷达图主题Provider
    final radarThemeProvider = RadarThemeProvider();
    await radarThemeProvider.init();

    runApp(UltimateWheelApp(
      storageService: storageService,
      radarThemeProvider: radarThemeProvider,
    ));
  }, (error, stack) {
    logger.fatal('未捕获的 Dart 错误', error, stack);
  });
}

class UltimateWheelApp extends StatelessWidget {
  final StorageService storageService;
  final RadarThemeProvider radarThemeProvider;

  const UltimateWheelApp({
    super.key,
    required this.storageService,
    required this.radarThemeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalSettingProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider.value(
          value: radarThemeProvider,
        ),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          final router = AppRouter.createRouter(context);
          return MaterialApp.router(
            title: 'Ultimate Wheel - 飞盘之轮',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: prefs.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
