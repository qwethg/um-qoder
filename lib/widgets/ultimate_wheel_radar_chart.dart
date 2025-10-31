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
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制同心12边形
    for (int level = 1; level <= gridLevels; level++) {
      final levelRadius = radius * (level / gridLevels);
      final path = Path();

      for (int i = 0; i < 12; i++) {
        final angle = (i * 30 - 90) * math.pi / 180; // -90度使第一个点在顶部
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 绘制从中心发射的12条轴线
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
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
    final startAngle = (index * 30 - 90 - 15) * math.pi / 180; // 每个花瓣占30度，向左偏移15度居中
    final sweepAngle = 30 * math.pi / 180; // 30度扇形
    final maxRadius = radius * (score / 10.0); // 根据分数计算半径

    // 获取该类别的渐变色
    final gradientColors = AppTheme.getCategoryGradient(categoryColorIndex);

    // 分段绘制，创建阶梯式渐变效果
    final steps = (score / 10.0 * gridLevels).ceil(); // 根据分数计算需要绘制的段数
    
    for (int level = 1; level <= steps; level++) {
      final levelRadius = maxRadius * (level / steps);
      final prevRadius = level > 1 ? maxRadius * ((level - 1) / steps) : 0.0;

      // 计算颜色（根据level在渐变色数组中插值）
      final colorProgress = (level - 1) / (steps > 1 ? steps - 1 : 1);
      final color = _interpolateColor(gradientColors, colorProgress);

      // 创建扇形路径
      final path = Path();
      
      // 外弧
      path.arcTo(
        Rect.fromCircle(center: center, radius: levelRadius),
        startAngle,
        sweepAngle,
        false,
      );

      // 右边线
      final endAngle = startAngle + sweepAngle;
      if (level > 1) {
        path.lineTo(
          center.dx + prevRadius * math.cos(endAngle),
          center.dy + prevRadius * math.sin(endAngle),
        );

        // 内弧
        path.arcTo(
          Rect.fromCircle(center: center, radius: prevRadius),
          endAngle,
          -sweepAngle,
          false,
        );
      } else {
        // 第一层，直接连到中心
        path.lineTo(center.dx, center.dy);
      }

      path.close();

      // 填充颜色
      final paint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
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
    final labelRadius = radius * 1.15; // 标签距离中心更远一些

    for (int i = 0; i < abilities.length; i++) {
      final ability = abilities[i];
      final angle = (i * 30 - 90) * math.pi / 180;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      // 绘制emoji
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${ability.emoji}\n${ability.name}',
          style: textStyle?.copyWith(
            fontSize: 10,
            height: 1.2,
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
