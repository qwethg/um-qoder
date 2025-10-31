import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';

/// 花瓣式彩虹渐变雷达图
class UltimateWheelRadarChart extends StatelessWidget {
  final Map<String, double> scores; // abilityId -> score (0-10)
  final double size;
  final bool showLabels;
  final bool showGrid;
  final int gridLevels;

  const UltimateWheelRadarChart({
    super.key,
    required this.scores,
    this.size = 300,
    this.showLabels = true,
    this.showGrid = true,
    this.gridLevels = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          scores: scores,
          showLabels: showLabels,
          showGrid: showGrid,
          gridLevels: gridLevels,
          textStyle: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> scores;
  final bool showLabels;
  final bool showGrid;
  final int gridLevels;
  final TextStyle? textStyle;

  _RadarChartPainter({
    required this.scores,
    required this.showLabels,
    required this.showGrid,
    required this.gridLevels,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;

    // 1. 绘制网格背景
    if (showGrid) {
      _drawGrid(canvas, center, radius);
    }

    // 2. 绘制数据花瓣
    _drawPetals(canvas, center, radius);

    // 3. 绘制标签
    if (showLabels) {
      _drawLabels(canvas, center, radius, size);
    }
  }

  /// 绘制12边形网格
  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制同心12边形，与花瓣边缘对齐
    for (int level = 1; level <= gridLevels; level++) {
      final levelRadius = radius * (level / gridLevels);
      final path = Path();

      for (int i = 0; i < 12; i++) {
        // 与花瓣边缘对齐：每个花瓣的边缘角度
        final angle = (i * 30 - 90 - 15) * math.pi / 180; // 花瓣左边缘
        final nextAngle = (i * 30 - 90 + 15) * math.pi / 180; // 花瓣右边缘
        
        final x1 = center.dx + levelRadius * math.cos(angle);
        final y1 = center.dy + levelRadius * math.sin(angle);
        final x2 = center.dx + levelRadius * math.cos(nextAngle);
        final y2 = center.dy + levelRadius * math.sin(nextAngle);

        if (i == 0) {
          path.moveTo(x1, y1);
        }
        path.lineTo(x2, y2);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 绘制从中心发射的12条轴线（与花瓣边缘对齐）
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90 - 15) * math.pi / 180; // 花瓣左边缘
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  /// 绘制数据花瓣
  void _drawPetals(Canvas canvas, Offset center, double radius) {
    final abilities = AbilityConstants.abilities;

    for (int i = 0; i < abilities.length; i++) {
      final ability = abilities[i];
      final score = scores[ability.id] ?? 0.0;
      
      if (score > 0) {
        _drawSinglePetal(
          canvas,
          center,
          radius,
          i,
          score,
          ability.category.colorIndex,
        );
      }
    }
  }

  /// 绘制单个花瓣（扇形区域）
  void _drawSinglePetal(
    Canvas canvas,
    Offset center,
    double radius,
    int index,
    double score,
    int categoryColorIndex,
  ) {
    final startAngle = (index * 30 - 90 - 15) * math.pi / 180;
    final sweepAngle = 30 * math.pi / 180;
    final maxRadius = radius * (score / 10.0);

    // 获取该类别的基础色
    final baseColors = AppTheme.getCategoryGradient(categoryColorIndex);
    
    // 为同类别的每个子项生成不同的颜色变体
    final abilities = AbilityConstants.abilities;
    final ability = abilities[index];
    final categoryAbilities = AbilityConstants.getAbilitiesByCategory(ability.category);
    final abilityIndexInCategory = categoryAbilities.indexWhere((a) => a.id == ability.id);
    final totalInCategory = categoryAbilities.length;
    
    // 根据子项在类别中的位置调整色相
    final hueShift = (abilityIndexInCategory / totalInCategory) * 0.15 - 0.075;
    final adjustedColors = baseColors.map((color) => _adjustColorHue(color, hueShift)).toList();

    // 创建完整的花瓣路径
    final path = Path();
    path.moveTo(center.dx, center.dy);
    
    // 外弧
    path.arcTo(
      Rect.fromCircle(center: center, radius: maxRadius),
      startAngle,
      sweepAngle,
      false,
    );
    
    path.close();

    // 使用径向渐变填充 + 晕染效果
    final rect = Rect.fromCircle(center: center, radius: maxRadius * 1.15); // 扩大范围产生晕染
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        adjustedColors.first.withOpacity(0.3),  // 中心更透明
        adjustedColors.last.withOpacity(0.75),   // 边缘浓郁
        adjustedColors.last.withOpacity(0.15),   // 外延晕染
      ],
      stops: const [0.0, 0.85, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3); // 添加模糊效果

    canvas.drawPath(path, paint);
  }
  
  /// 调整颜色的色相
  Color _adjustColorHue(Color color, double hueShift) {
    final hslColor = HSLColor.fromColor(color);
    final newHue = (hslColor.hue + hueShift * 360) % 360;
    return hslColor.withHue(newHue).toColor();
  }

  /// 在多个颜色之间插值
  Color _interpolateColor(List<Color> colors, double progress) {
    if (colors.isEmpty) return Colors.grey;
    if (colors.length == 1) return colors[0];
    
    // 将progress映射到颜色数组的区间
    final scaledProgress = progress * (colors.length - 1);
    final index = scaledProgress.floor();
    final nextIndex = (index + 1).clamp(0, colors.length - 1);
    final t = scaledProgress - index;

    final color1 = colors[index];
    final color2 = colors[nextIndex];

    return Color.lerp(color1, color2, t) ?? color1;
  }

  /// 绘制标签
  void _drawLabels(Canvas canvas, Offset center, double radius, Size size) {
    final abilities = AbilityConstants.abilities;
    final labelRadius = radius * 1.08; // 标签靠近雷达图

    for (int i = 0; i < abilities.length; i++) {
      final ability = abilities[i];
      final angle = (i * 30 - 90) * math.pi / 180;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      // 获取该能力项的颜色
      final baseColors = AppTheme.getCategoryGradient(ability.category.colorIndex);
      final categoryAbilities = AbilityConstants.getAbilitiesByCategory(ability.category);
      final abilityIndexInCategory = categoryAbilities.indexWhere((a) => a.id == ability.id);
      final totalInCategory = categoryAbilities.length;
      final hueShift = (abilityIndexInCategory / totalInCategory) * 0.15 - 0.075;
      final labelColor = _adjustColorHue(baseColors.last, hueShift);

      // 绘制文字（去掉表情符号）
      final textPainter = TextPainter(
        text: TextSpan(
          text: ability.name,
          style: textStyle?.copyWith(
            fontSize: 13,          // 字体更大
            fontWeight: FontWeight.w600,  // 加粗
            color: labelColor,     // 使用对应颜色
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // 根据位置调整对齐方式
      final offsetX = x - textPainter.width / 2;
      final offsetY = y - textPainter.height / 2;

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
           oldDelegate.showLabels != showLabels ||
           oldDelegate.showGrid != showGrid ||
           oldDelegate.gridLevels != gridLevels;
  }
}
