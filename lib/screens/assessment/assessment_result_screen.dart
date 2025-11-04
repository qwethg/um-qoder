import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/services/share_service.dart';
import 'package:ultimate_wheel/widgets/ai_analysis_section.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

// 性能优化: 将原 StatefulWidget 拆分为 StatelessWidget，仅负责获取数据。
class AssessmentResultScreen extends StatelessWidget {
  final String assessmentId;

  const AssessmentResultScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 精准监听 assessment 对象，避免因 Provider 其他数据变化导致重建。
    return Selector<AssessmentProvider, Assessment?>(
      selector: (_, provider) => provider.getAssessmentById(assessmentId),
      builder: (context, assessment, _) {
        if (assessment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('评估结果')),
            // 性能优化: 添加 const 关键字。
            body: const Center(
              child: Text('未找到评估记录'),
            ),
          );
        }
        // 性能优化: 将包含状态和复杂UI的部分拆分为独立的 StatefulWidget。
        return _ResultContent(assessment: assessment);
      },
    );
  }
}

/// 承载结果页主要内容和状态的内部 Widget
class _ResultContent extends StatefulWidget {
  final Assessment assessment;

  const _ResultContent({required this.assessment});

  @override
  State<_ResultContent> createState() => _ResultContentState();
}

class _ResultContentState extends State<_ResultContent> {
  final _screenshotController = ScreenshotController();
  final _shareService = ShareService();
  RadarTheme? _previewTheme; // 用于分享预览的临时主题

  // BUG修复: 添加了缺失的 dispose() 调用，防止内存泄漏。
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 将主题的获取也放在这里，以便分享功能可以影响它
    final themeProvider = context.watch<RadarThemeProvider>();
    final currentTheme = _previewTheme ?? themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('评估结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showShareThemeSelector(context, themeProvider),
            tooltip: '分享',
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            // 性能优化: 添加 const 关键字。
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CongratulationsSection(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 32),
                _RadarChartCard(
                  assessment: widget.assessment,
                  theme: currentTheme,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                AiAnalysisSection(
                  assessment: widget.assessment,
                  onAssessmentUpdated: (updatedAssessment) {
                    // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
                    context
                        .read<AssessmentProvider>()
                        .updateAssessment(updatedAssessment);
                  },
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _TotalScoreCard(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _CategoryDetailGrid(
                  assessment: widget.assessment,
                  theme: currentTheme,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _DetailedScoresExpansionTile(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                const _ActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示主题选择器并处理分享逻辑
  Future<void> _showShareThemeSelector(
      BuildContext context, RadarThemeProvider themeProvider) async {
    final selectedTheme = await showModalBottomSheet<RadarTheme?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ShareThemeSelectorSheet(
        currentTheme: _previewTheme ?? themeProvider.currentTheme,
        allThemes: themeProvider.allThemes,
        assessment: widget.assessment,
        onThemeChanged: (theme) {
          setState(() => _previewTheme = theme);
        },
      ),
    );

    if (selectedTheme != null) {
      // 用户选择了主题并确认分享
      await _handleShare();
    }

    // 重置预览主题，避免影响主页面的主题显示
    if (mounted) {
      setState(() => _previewTheme = null);
    }
  }

  /// 处理分享操作
  Future<void> _handleShare() async {
    await _shareService.shareAssessment(
      context: context,
      screenshotController: _screenshotController,
      assessmentDate:
          DateFormat('yyyy-MM-dd HH:mm').format(widget.assessment.createdAt),
      totalScore: widget.assessment.totalScore,
    );
  }
}

// --- 以下是将 UI 拆分为的独立 StatelessWidget ---

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _CongratulationsSection extends StatelessWidget {
  final Assessment assessment;
  const _CongratulationsSection({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 16),
          Text(
            '恭喜，完成了本次评估',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 8),
          Text(
            '评估不代表你的全部，只代表此刻的你对自己的认知',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 8),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _RadarChartCard extends StatelessWidget {
  final Assessment assessment;
  final RadarTheme theme;

  const _RadarChartCard({required this.assessment, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: UltimateWheelRadarChart(
          scores: assessment.scores,
          size: MediaQuery.of(context).size.width - 80,
          radarTheme: theme,
        ),
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _TotalScoreCard extends StatelessWidget {
  final Assessment assessment;
  const _TotalScoreCard({required this.assessment});

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
              assessment.totalScore.toStringAsFixed(1),
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

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _CategoryDetailGrid extends StatelessWidget {
  final Assessment assessment;
  final RadarTheme theme;

  const _CategoryDetailGrid({required this.assessment, required this.theme});

  @override
  Widget build(BuildContext context) {
    final categories = AbilityCategory.values;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[0], // 身体
                  theme: theme,
                ),
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[2], // 技术
                  theme: theme,
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
                  category: categories[1], // 意识
                  theme: theme,
                ),
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[3], // 心灵
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 性能优化: 将 _buildCategoryDetailCard 方法重构为独立的 StatelessWidget。
class _CategoryDetailCard extends StatelessWidget {
  final Assessment assessment;
  final AbilityCategory category;
  final RadarTheme theme;

  const _CategoryDetailCard({
    required this.assessment,
    required this.category,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final abilityIds =
        AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
    final categoryScore = assessment.getCategoryScore(abilityIds);
    final color = theme.getCategoryColor(category.colorIndex);
    final gradient = theme.getCategoryGradient(category.colorIndex);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
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
            ...abilities.asMap().entries.map((entry) {
              final index = entry.key;
              final ability = entry.value;
              final score = assessment.scores[ability.id] ?? 0.0;
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
                        overflow: TextOverflow.ellipsis,
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

  Color _adjustColorHue(Color color, double hueShift) {
    final hslColor = HSLColor.fromColor(color);
    final newHue = (hslColor.hue + hueShift * 360) % 360;
    return hslColor.withHue(newHue).toColor();
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _DetailedScoresExpansionTile extends StatelessWidget {
  final Assessment assessment;

  const _DetailedScoresExpansionTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            '详细分数',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: AbilityConstants.abilities.map((ability) {
            final score = assessment.scores[ability.id] ?? 0.0;
            return _AbilityScoreItem(ability: ability, score: score);
          }).toList(),
        ),
      ),
    );
  }
}

class _AbilityScoreItem extends StatelessWidget {
  final Ability ability;
  final double score;

  const _AbilityScoreItem({required this.ability, required this.score});

  @override
  Widget build(BuildContext context) {
    final color =
        PresetRadarThemes.defaultTheme.getCategoryColor(ability.category.colorIndex);

    return ListTile(
      leading: Icon(
        ability.icon,
        size: 24,
        color: color,
      ),
      title: Text(ability.name),
      subtitle: Text(
        ability.description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          score.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/history'),
            // 性能优化: 添加 const 关键字。
            icon: const Icon(Icons.history),
            label: const Text('查看历史'),
          ),
        ),
        // 性能优化: 添加 const 关键字。
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.go('/home'),
            // 性能优化: 添加 const 关键字。
            icon: const Icon(Icons.home),
            label: const Text('回到首页'),
          ),
        ),
      ],
    );
  }
}

/// 分享主题选择器 Sheet
class _ShareThemeSelectorSheet extends StatefulWidget {
  final RadarTheme currentTheme;
  final List<RadarTheme> allThemes;
  final Assessment assessment;
  final Function(RadarTheme) onThemeChanged;

  const _ShareThemeSelectorSheet({
    required this.currentTheme,
    required this.allThemes,
    required this.assessment,
    required this.onThemeChanged,
  });

  @override
  State<_ShareThemeSelectorSheet> createState() =>
      _ShareThemeSelectorSheetState();
}

class _ShareThemeSelectorSheetState extends State<_ShareThemeSelectorSheet> {
  late RadarTheme _selectedTheme;
  late ScrollController _scrollController;
  static const double _itemWidth = 112.0;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(bool left) {
    final currentOffset = _scrollController.offset;
    final newOffset = (left ? currentOffset - _itemWidth : currentOffset + _itemWidth)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择主题分享',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: UltimateWheelRadarChart(
                scores: widget.assessment.scores,
                size: 220,
                radarTheme: _selectedTheme,
              ),
            ),
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                _ScrollButton(icon: Icons.chevron_left, onPressed: () => _scroll(true)),
                // 性能优化: 添加 const 关键字。
                const SizedBox(width: 8),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.allThemes.length,
                    itemBuilder: (context, index) {
                      final theme = widget.allThemes[index];
                      return Padding(
                        // 性能优化: 添加 const 关键字。
                        padding: const EdgeInsets.only(right: 12),
                        child: RadarThemePreview(
                          theme: theme,
                          size: 100,
                          isSelected: theme.id == _selectedTheme.id,
                          onTap: () {
                            setState(() => _selectedTheme = theme);
                            widget.onThemeChanged(theme);
                          },
                        ),
                      );
                    },
                  ),
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(width: 8),
                _ScrollButton(icon: Icons.chevron_right, onPressed: () => _scroll(false)),
              ],
            ),
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selectedTheme),
              // 性能优化: 添加 const 关键字。
              child: const Text('确认分享'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ScrollButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 140,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
