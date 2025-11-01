import 'package:flutter/material.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 雷达图主题预览组件
class RadarThemePreview extends StatelessWidget {
  final RadarTheme theme;
  final double size;
  final bool showName;
  final VoidCallback? onTap;
  final bool isSelected;

  const RadarThemePreview({
    super.key,
    required this.theme,
    this.size = 120,
    this.showName = true,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // 创建示例数据（均匀分布的样本）
    final sampleScores = <String, double>{};
    for (var ability in AbilityConstants.abilities) {
      sampleScores[ability.id] = 6.5 + (ability.order % 3) * 1.0; // 6.5, 7.5, 8.5循环
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 雷达图预览
            Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(8),
              child: UltimateWheelRadarChart(
                scores: sampleScores,
                size: size - 16,
                showLabels: false,
                showGrid: true,
                gridLevels: 5,
                radarTheme: theme,
              ),
            ),
            // 主题名称
            if (showName)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  theme.name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 主题颜色方块预览（用于颜色选择器）
class ThemeColorSquare extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;

  const ThemeColorSquare({
    super.key,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
