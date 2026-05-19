import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/l10n.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/widgets/ai_analysis_section.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 首页 (02-1 / 02-2)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '飞盘之轮'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/welcome'),
            tooltip: '什么是飞盘之轮?'.tr,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.scaffoldBackgroundColor,
                    const Color(0xFF1E2433),
                  ]
                : [
                    const Color(0xFFFDFBF7),
                    const Color(0xFFF4F7FB),
                    const Color(0xFFF8F4F9),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Selector<AssessmentProvider, bool>(
            selector: (_, provider) => provider.hasAssessments,
            builder: (context, hasAssessments, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: hasAssessments
                    ? const _WithAssessmentsView()
                    : const _EmptyState(),
              );
            },
          ),
        ),
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
    return Selector2<AssessmentProvider, RadarThemeProvider, (Assessment, RadarTheme, bool)>(
      selector: (_, assessmentProvider, themeProvider) {
        return (assessmentProvider.latestAssessment!, themeProvider.currentTheme, assessmentProvider.needsDeepRecalibration);
      }, builder: (context, data, _) {
      final assessment = data.$1;
      final currentTheme = data.$2;
      final needsDeepRecalibration = data.$3;

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
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 重新深度评估提示卡片
            if (needsDeepRecalibration)
              const _RecalibrationPromptCard(),

            // 最新评估的雷达图
            _RadarChartCard(assessment: assessment, currentTheme: currentTheme),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 16),

            // 总分
            _TotalScoreCard(totalScore: assessment.totalScore),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 12),

            // 分区得分卡片
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _CategoryDetailCard(
                      assessment: assessment,
                      categoryName: '身体'.tr,
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
                      categoryName: '技术'.tr,
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
                      categoryName: '意识'.tr,
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
                      categoryName: '心灵'.tr,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 空白雷达图占位
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withOpacity(isDark ? 0.3 : 0.5),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(isDark ? 0.1 : 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.self_improvement_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '准备好开始\n第一次深度评估了吗？'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),

            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => context.go('/assessment'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  '开始评估'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 基础玻璃态卡片组件，用于统一UI风格
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(isDark ? 0.6 : 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(isDark ? 0.15 : 0.2),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withOpacity(isDark ? 0.7 : 0.9),
                  theme.colorScheme.surface.withOpacity(isDark ? 0.4 : 0.6),
                ],
              ),
            ),
            child: child,
          ),
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
    return _GlassCard(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 增加轻微的发光背景提升雷达图质感
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: currentTheme.getCategoryColor(0).withOpacity(0.05),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          UltimateWheelRadarChart(
            scores: assessment.scores,
            size: MediaQuery.of(context).size.width - 96,
            radarTheme: currentTheme,
          ),
        ],
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
    final theme = Theme.of(context);
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '整体均衡度'.tr,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '总评得分'.tr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              totalScore.toStringAsFixed(1),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
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
    final theme = Theme.of(context);

    // 获取该类别的所有能力项
    final abilities = AbilityConstants.abilities
        .where((a) => abilityIds.contains(a.id))
        .toList();

    return _GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部：左边类别名称，右边总分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Text(
                  categoryName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Text(
                categoryScore.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ability.name.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 10.0,
                      backgroundColor: itemColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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

/// 深度重新评估提示卡片
class _RecalibrationPromptCard extends StatefulWidget {
  const _RecalibrationPromptCard();

  @override
  State<_RecalibrationPromptCard> createState() => _RecalibrationPromptCardState();
}

class _RecalibrationPromptCardState extends State<_RecalibrationPromptCard> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '你已经记录了很久的日常变化，要不要花 15 分钟，重新进行一次深度的自我对话？'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isDismissed = true),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () {
                context.push('/assessment/deep');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text('开始深度评估'.tr),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

