import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ultimate_wheel/config/router.dart';
import 'package:ultimate_wheel/config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // TODO: 注册 Hive 适配器
  
  runApp(const UltimateWheelApp());
}

class UltimateWheelApp extends StatelessWidget {
  const UltimateWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ultimate Wheel - 飞盘之轮',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
