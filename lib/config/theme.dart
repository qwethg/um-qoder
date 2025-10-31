import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 应用主题配置
class AppTheme {
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

  /// Material Design 3 主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4ECDC4),
        brightness: Brightness.light,
      ),
      
      // 字体配置 - 使用 Google Fonts
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSans(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.notoSans(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.notoSans(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 填充按钮主题
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4ECDC4),
        brightness: Brightness.dark,
      ),
      
      textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
