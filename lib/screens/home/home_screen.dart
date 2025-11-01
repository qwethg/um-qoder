import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 首页 (02-1 / 02-2)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssessmentProvider, RadarThemeProvider>(
      builder: (context, assessmentProvider, themeProvider, _) {
        final hasAssessments = assessmentProvider.hasAssessments;
        final latestAssessment = assessmentProvider.latestAssessment;

        return Scaffold(
          appBar: AppBar(
            title: const Text('飞盘之轮'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push('/welcome'),
                tooltip: '什么是飞盘之轮?',
              ),
            ],
          ),
          body: hasAssessments && latestAssessment != null
              ? _buildWithAssessments(context, latestAssessment, themeProvider.currentTheme)
              : _buildEmptyState(context),
        );
      },
    );
  }

  /// 有评估记录的首页 (02-2)
  Widget _buildWithAssessments(BuildContext context, assessment, RadarTheme currentTheme) {
    // 计算各类别得分
    final athleticismIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.athleticism)
        .map((a) => a.id).toList();
    final awarenessIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.awareness)
        .map((a) => a.id).toList();
    final techniqueIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.technique)
        .map((a) => a.id).toList();
    final mindIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.mind)
        .map((a) => a.id).toList();

    final athleticismScore = assessment.getCategoryScore(athleticismIds);
    final awarenessScore = assessment.getCategoryScore(awarenessIds);
    final techniqueScore = assessment.getCategoryScore(techniqueIds);
    final mindScore = assessment.getCategoryScore(mindIds);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最新评估的雷达图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: UltimateWheelRadarChart(
                scores: assessment.scores,
                size: MediaQuery.of(context).size.width - 80,
                radarTheme: currentTheme,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 总分
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '总分',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    assessment.totalScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 分区得分
          Text(
            '分区得分',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // 第一行：身体 - 技术（使用IntrinsicHeight确保高度一致）
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCategoryDetailCard(
                    context,
                    assessment,
                    '身体',
                    athleticismScore,
                    0,
                    athleticismIds,
                    currentTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryDetailCard(
                    context,
                    assessment,
                    '技术',
                    techniqueScore,
                    2,
                    techniqueIds,
                    currentTheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 第二行：意识 - 心灵（使用IntrinsicHeight确保高度一致）
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCategoryDetailCard(
                    context,
                    assessment,
                    '意识',
                    awarenessScore,
                    1,
                    awarenessIds,
                    currentTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryDetailCard(
                    context,
                    assessment,
                    '心灵',
                    mindScore,
                    3,
                    mindIds,
                    currentTheme,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 总览评价
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本次评估总览',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assessment.overallNote ?? '暂无总体评价',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 空状态首页 (02-1)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 空白雷达图占位
            Opacity(
              opacity: 0.3,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '准备好开始\n第一次深度评估了吗？',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            FilledButton.icon(
              onPressed: () => context.go('/assessment'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始评估'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDetailCard(
    BuildContext context,
    assessment,
    String categoryName,
    double categoryScore,
    int colorIndex,
    List<String> abilityIds,
    RadarTheme currentTheme,
  ) {
    final color = currentTheme.getCategoryColor(colorIndex);
    final gradient = currentTheme.getCategoryGradient(colorIndex);
    
    // 获取该类别的所有能力项
    final abilities = AbilityConstants.abilities
        .where((a) => abilityIds.contains(a.id))
        .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 最小化高度
          children: [
            // 顶部：左边类别名称，右边总分
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  categoryScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 细项列表
            ...abilities.asMap().entries.map((entry) {
              final index = entry.key;
              final ability = entry.value;
              final score = assessment.scores[ability.id] ?? 0.0;
              
              // 计算该子项的颜色（与雷达图保持一致）
              final hueShift = (index / abilities.length) * 0.15 - 0.075;
              final itemColor = _adjustColorHue(gradient.last, hueShift);
              
              final isLast = index == abilities.length - 1;
              
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0), // 最后一项不留底部间距
                child: Row(
                  children: [
                    // 文字
                    SizedBox(
                      width: 60,
                      child: Text(
                        ability.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: itemColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    
                    // 横条（进度条）
                    Expanded(
                      child: LinearProgressIndicator(
                        value: score / 10.0,
                        backgroundColor: itemColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    
                    // 数值
                    SizedBox(
                      width: 32,
                      child: Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: itemColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  /// 调整颜色的色相（与雷达图一致）
  Color _adjustColorHue(Color color, double hueShift) {
    final hslColor = HSLColor.fromColor(color);
    final newHue = (hslColor.hue + hueShift * 360) % 360;
    return hslColor.withHue(newHue).toColor();
  }
}
