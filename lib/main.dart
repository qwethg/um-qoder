import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/router.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/config/translations.dart';
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

    // 初始化全局语言
    AppLanguage.currentLanguage = storageService.language;

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

class UltimateWheelApp extends StatefulWidget {
  final StorageService storageService;
  final RadarThemeProvider radarThemeProvider;

  const UltimateWheelApp({
    super.key,
    required this.storageService,
    required this.radarThemeProvider,
  });

  @override
  State<UltimateWheelApp> createState() => _UltimateWheelAppState();
}

class _UltimateWheelAppState extends State<UltimateWheelApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // 使用 StorageService 的 isFirstLaunch 初始化路由，避免在 build 中重建
    _router = AppRouter.createRouter(widget.storageService.isFirstLaunch);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: widget.storageService),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalSettingProvider(widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(widget.storageService),
        ),
        ChangeNotifierProvider.value(
          value: widget.radarThemeProvider,
        ),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return MaterialApp.router(
            title: 'Ultimate Wheel - 飞盘之轮',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: prefs.themeMode,
            routerConfig: _router,
            builder: (context, child) {
              // 给整个应用添加最小宽度限制，在极端狭窄的窗口（如侧边栏）允许横向滚动，避免出现黄黑溢出条纹
              return LayoutBuilder(
                builder: (context, constraints) {
                  const double minWidth = 360.0;
                  if (constraints.maxWidth < minWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minWidth,
                        height: constraints.maxHeight,
                        child: child,
                      ),
                    );
                  }
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
