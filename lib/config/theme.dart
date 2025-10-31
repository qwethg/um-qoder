import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 全局配色方案
  // 浅色模式
  static const Color lightBackground = Color(0xFFF0F4F8);        // 月白色背景
  static const Color lightSurface = Color(0xFFFFFFFF);            // 卡片/表面颜色
  static const Color lightPrimary = Color(0xFF6C7B95);            // 雾霾蓝主色
  static const Color lightOnPrimary = Color(0xFFFFFFFF);          // 主色上的文字
  static const Color lightSecondary = Color(0xFFE8A39B);          // 珊瑚粉点缀
  static const Color lightOnSecondary = Color(0xFF2C3E50);        // 点缀色上的文字
  static const Color lightText = Color(0xFF2C3E50);               // 深藏青色文字
  static const Color lightTextSecondary = Color(0xFF6C7B95);      // 次要文字
  static const Color lightOutline = Color(0xFFD0D7E0);            // 线条/边框
  
  // 深色模式
  static const Color darkBackground = Color(0xFF1A1F2E);          // 深藏青背景
  static const Color darkSurface = Color(0xFF252B3A);             // 卡片/表面颜色
  static const Color darkPrimary = Color(0xFF8A9AB0);             // 浅雾霾蓝
  static const Color darkOnPrimary = Color(0xFF1A1F2E);           // 主色上的文字
  static const Color darkSecondary = Color(0xFFE8A39B);           // 珊瑚粉点缀（保持一致）
  static const Color darkOnSecondary = Color(0xFF1A1F2E);         // 点缀色上的文字
  static const Color darkText = Color(0xFFE8EDF3);                // 浅色文字
  static const Color darkTextSecondary = Color(0xFF9AA5B8);       // 次要文字
  static const Color darkOutline = Color(0xFF3D4556);             // 线条/边框
  // 核心色彩方案 - 对应4个能力类别（参考图片配色）
  static const Color athleticismColor = Color(0xFFE68E46);  // 身体 - 橙色 #e68e46
  static const Color awarenessColor = Color(0xFF2F504C);    // 意识 - 深青绿 #2f504c
  static const Color techniqueColor = Color(0xFF563437);    // 技术 - 深酒红 #563437
  static const Color mindColor = Color(0xFFE7BEBE);         // 心灵 - 浅粉 #e7bebe

  // 渐变色列表 - 用于雷达图
  static const List<Color> athleticismGradient = [
    Color(0xFFFFA866),  // 浅橙
    Color(0xFFE68E46),  // 标准橙
    Color(0xFFCC7A3D),  // 深橙
  ];

  static const List<Color> awarenessGradient = [
    Color(0xFF4A7C76),  // 浅青绿
    Color(0xFF2F504C),  // 标准青绿
    Color(0xFF1F3935),  // 深青绿
  ];

  static const List<Color> techniqueGradient = [
    Color(0xFF7A5154),  // 浅酒红
    Color(0xFF563437),  // 标准酒红
    Color(0xFF3D2528),  // 深酒红
  ];

  static const List<Color> mindGradient = [
    Color(0xFFF5D8D8),  // 浅粉
    Color(0xFFE7BEBE),  // 标准粉
    Color(0xFFD9A4A4),  // 深粉
  ];

  /// 获取类别对应的主色
  static Color getCategoryColor(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return athleticismColor;
      case 1:
        return awarenessColor;
      case 2:
        return techniqueColor;
      case 3:
        return mindColor;
      default:
        return athleticismColor;
    }
  }

  /// 获取类别对应的渐变色列表
  static List<Color> getCategoryGradient(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return athleticismGradient;
      case 1:
        return awarenessGradient;
      case 2:
        return techniqueGradient;
      case 3:
        return mindGradient;
      default:
        return athleticismGradient;
    }
  }

  /// Material Design 3 浅色主题
  static ThemeData get lightTheme {
    // 使用霞鹜文楷 GB 轻便版 - 本地字体，无需网络加载
    const fontFamily = 'LXGWWenKaiGBLite';
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
    );
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: lightPrimary,               // 雾霾蓝
        onPrimary: lightOnPrimary,           // 白色
        secondary: lightSecondary,           // 珊瑚粉
        onSecondary: lightOnSecondary,       // 深藏青
        surface: lightSurface,               // 白色卡片
        onSurface: lightText,             // 深藏青文字
        outline: lightOutline,               // 浅灰线条
        error: const Color(0xFFD32F2F),      // 错误色
      ),
      scaffoldBackgroundColor: lightBackground,
      
      // 使用系统默认中文字体，避免加载延迟
      textTheme: baseTextTheme,
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: lightOutline,
            width: 0.5,
          ),
        ),
      ),
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: lightText,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),
      
      // 填充按钮主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: lightOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
        ),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightSecondary,
        foregroundColor: lightOnSecondary,
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPrimary, width: 2),
        ),
        filled: true,
        fillColor: lightSurface,
      ),
      
      // 进度条主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightPrimary,
        linearTrackColor: lightOutline,
      ),
      
      // 分割线主题
      dividerTheme: DividerThemeData(
        color: lightOutline,
        thickness: 1,
      ),
    );
  }

  /// Material Design 3 深色主题
  static ThemeData get darkTheme {
    // 使用霞鹜文楷 GB 轻便版
    const fontFamily = 'LXGWWenKaiGBLite';
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        fontFamily: fontFamily,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        fontFamily: fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        fontFamily: fontFamily,
      ),
    );
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,                // 浅雾霾蓝
        onPrimary: darkOnPrimary,            // 深藏青
        secondary: darkSecondary,            // 珊瑚粉
        onSecondary: darkOnSecondary,        // 深藏青
        surface: darkSurface,                // 深色卡片
        onSurface: darkText,              // 浅色文字
        outline: darkOutline,                // 深色线条
        error: const Color(0xFFEF5350),      // 错误色
      ),
      scaffoldBackgroundColor: darkBackground,
      
      textTheme: baseTextTheme,
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkOutline,
            width: 0.5,
          ),
        ),
      ),
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      
      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
        ),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSecondary,
        foregroundColor: darkOnSecondary,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        filled: true,
        fillColor: darkSurface,
      ),
      
      // 进度条主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkPrimary,
        linearTrackColor: darkOutline,
      ),
      
      // 分割线主题
      dividerTheme: DividerThemeData(
        color: darkOutline,
        thickness: 1,
      ),
    );
  }
}
