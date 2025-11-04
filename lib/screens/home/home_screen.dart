import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/widgets/ai_analysis_section.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 首页 (02-1 / 02-2)
class HomeScreen extends StatelessWidget {
  // 性能优化: 改为 StatelessWidget，因为所有状态都由 Provider 管理。
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('飞盘之轮'),
        actions: [
          IconButton(
            // 性能优化: 添加 const 关键字。
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/welcome'),
            tooltip: '什么是飞盘之轮?',
          ),
        ],
      ),
      // 性能优化: 使用 Selector 仅监听评估记录是否存在，避免不必要的整体重建。
      body: Selector<AssessmentProvider, bool>(
        selector: (_, provider) => provider.hasAssessments,
        builder: (context, hasAssessments, _) {
          return hasAssessments
              ? const _WithAssessmentsView() // 性能优化: 拆分为独立的 StatelessWidget。
              : const _EmptyState(); // 性能优化: 拆分为独立的 StatelessWidget。
        },
      ),
    );
  }
}

/// 有评估记录时的首页视图 (02-2)
class _WithAssessmentsView extends StatelessWidget {
  const _WithAssessmentsView();

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector2 精确监听所需的数据，避免因无关数据变化导致重建。
    return Selector2<AssessmentProvider, RadarThemeProvider, (Assessment, RadarTheme)>(
      selector: (_, assessmentProvider, themeProvider) {
        return (assessmentProvider.latestAssessment!, themeProvider.currentTheme);
      }, builder: (context, data, _) {
      final assessment = data.$1;
      final currentTheme = data.$2;

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
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 最新评估的雷达图
            _RadarChartCard(assessment: assessment, currentTheme: currentTheme),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 24),

            // 总分
            _TotalScoreCard(totalScore: assessment.totalScore),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 16),

            // 分区得分标题
            Text(
              '分区得分',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 8),

            // 分区得分卡片
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _CategoryDetailCard(
                      assessment: assessment,
                      categoryName: '身体',
                      categoryScore: athleticismScore,
                      colorIndex: 0,
                      abilityIds: athleticismIds,
                      currentTheme: currentTheme,
                    ),
                  ),
                  // 性能优化: 添加 const 关键字。
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryDetailCard(
                      assessment: assessment,
                      categoryName: '技术',
                      categoryScore: techniqueScore,
                      colorIndex: 2,
                      abilityIds: techniqueIds,
                      currentTheme: currentTheme,
                    ),
                  ),
                ],
              ),
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _CategoryDetailCard(
                      assessment: assessment,
                      categoryName: '意识',
                      categoryScore: awarenessScore,
                      colorIndex: 1,
                      abilityIds: awarenessIds,
                      currentTheme: currentTheme,
                    ),
                  ),
                  // 性能优化: 添加 const 关键字。
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryDetailCard(
                      assessment: assessment,
                      categoryName: '心灵',
                      categoryScore: mindScore,
                      colorIndex: 3,
                      abilityIds: mindIds,
                      currentTheme: currentTheme,
                    ),
                  ),
                ],
              ),
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 24),

            // AI 智能分析组件
            AiAnalysisSection(
              assessment: assessment,
              onAssessmentUpdated: (updatedAssessment) {
                // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
                context.read<AssessmentProvider>().updateAssessment(updatedAssessment);
              },
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}

/// 空状态首页 (02-1)
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // 性能优化: 添加 const 关键字。
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
                    // 性能优化: 添加 const 关键字。
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
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 48),

            FilledButton.icon(
              onPressed: () => context.go('/assessment'),
              // 性能优化: 添加 const 关键字。
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始评估'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 雷达图卡片
class _RadarChartCard extends StatelessWidget {
  final Assessment assessment;
  final RadarTheme currentTheme;

  const _RadarChartCard({required this.assessment, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: UltimateWheelRadarChart(
          scores: assessment.scores,
          size: MediaQuery.of(context).size.width - 80,
          radarTheme: currentTheme,
        ),
      ),
    );
  }
}

/// 总分卡片
class _TotalScoreCard extends StatelessWidget {
  final double totalScore;

  const _TotalScoreCard({required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '总分',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              totalScore.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分区得分详情卡片
class _CategoryDetailCard extends StatelessWidget {
  final Assessment assessment;
  final String categoryName;
  final double categoryScore;
  final int colorIndex;
  final List<String> abilityIds;
  final RadarTheme currentTheme;

  const _CategoryDetailCard({
    required this.assessment,
    required this.categoryName,
    required this.categoryScore,
    required this.colorIndex,
    required this.abilityIds,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = currentTheme.getCategoryColor(colorIndex);
    final gradient = currentTheme.getCategoryGradient(colorIndex);

    // 获取该类别的所有能力项
    final abilities = AbilityConstants.abilities
        .where((a) => abilityIds.contains(a.id))
        .toList();

    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            // 性能优化: 添加 const 关键字。
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
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                child: Row(
                  children: [
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
                    // 性能优化: 添加 const 关键字。
                    const SizedBox(width: 6),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: score / 10.0,
                        backgroundColor: itemColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // 性能优化: 添加 const 关键字。
                    const SizedBox(width: 6),
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
