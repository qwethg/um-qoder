import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/router.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 初始化存储服务
  final storageService = StorageService();
  await storageService.initialize();
  
  runApp(UltimateWheelApp(storageService: storageService));
}

class UltimateWheelApp extends StatelessWidget {
  final StorageService storageService;

  const UltimateWheelApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalSettingProvider(storageService),
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
