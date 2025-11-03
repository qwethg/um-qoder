import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'package:ultimate_wheel/services/share_service.dart';
import 'package:ultimate_wheel/services/ai_service.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';
import 'package:ultimate_wheel/widgets/ai_analysis_section.dart';

/// 评估结果页 (03-4)
class AssessmentResultScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentResultScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  final _screenshotController = ScreenshotController();
  final _shareService = ShareService();
  RadarTheme? _previewTheme; // 分享预览使用的主题

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssessmentProvider, RadarThemeProvider>(
      builder: (context, assessmentProvider, themeProvider, _) {
        final assessment = assessmentProvider.getAssessmentById(widget.assessmentId);

        if (assessment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('评估结果')),
            body: const Center(
              child: Text('未找到评估记录'),
            ),
          );
        }

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

        final currentTheme = _previewTheme ?? themeProvider.currentTheme;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('评估结果'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _showShareThemeSelector(context, assessment, themeProvider),
                tooltip: '分享',
              ),
            ],
          ),
          body: Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildContent(
                  context,
                  assessment,
                  athleticismScore,
                  awarenessScore,
                  techniqueScore,
                  mindScore,
                  currentTheme,
                  assessmentProvider,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    assessment,
    double athleticismScore,
    double awarenessScore,
    double techniqueScore,
    double mindScore,
    RadarTheme currentTheme,
    AssessmentProvider assessmentProvider,
  ) {
    // 计算各类别能力项 IDs
    final athleticismIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.athleticism)
        .map((a) => a.id).toList();
    final awarenessIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.awareness)
        .map((a) => a.id).toList();
    final techniqueIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.technique)
        .map((a) => a.id).toList();
    final mindIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.mind)
        .map((a) => a.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                // 祝贺文字
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.celebration,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '恭喜，完成了本次评估',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '评估不代表你的全部，只代表此刻的你对自己的认知',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 雷达图
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

                // AI 智能分析组件
                AiAnalysisSection(
                  assessment: assessment,
                  onAssessmentUpdated: (updatedAssessment) {
                    // 更新评估记录
                    assessmentProvider.updateAssessment(updatedAssessment);
                  },
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

                const SizedBox(height: 8),
                // 2×2布局的分区得分：身体-技术 / 意识-心灵
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

                // 详细分数（可折叠）
                _DetailedScoresExpansionTile(assessment: assessment),
                const SizedBox(height: 24),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/history'),
                        icon: const Icon(Icons.history),
                        label: const Text('查看历史'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.home),
                        label: const Text('回到首页'),
                      ),
                    ),
                  ],
                ),
              ],
            );
  }

  /// 显示主题选择器并分享
  Future<void> _showShareThemeSelector(BuildContext context, assessment, RadarThemeProvider themeProvider) async {
    if (assessment == null) return;

    final selectedTheme = await showModalBottomSheet<RadarTheme?>(
      context: context,
      builder: (context) => _ShareThemeSelectorSheet(
        currentTheme: _previewTheme ?? themeProvider.currentTheme,
        allThemes: themeProvider.allThemes,
        assessment: assessment,
        onThemeChanged: (theme) {
          setState(() => _previewTheme = theme);
        },
      ),
    );

    if (selectedTheme != null) {
      // 用户选择了主题并确认分享
      _handleShare(context, assessment);
    }
    
    // 重置预览主题
    setState(() => _previewTheme = null);
  }

  void _handleShare(BuildContext context, assessment) async {
    if (assessment == null) return;

    await _shareService.shareAssessment(
      context: context,
      screenshotController: _screenshotController,
      assessmentDate: DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt),
      totalScore: assessment.totalScore,
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

/// 可折叠的详细分数组件
class _DetailedScoresExpansionTile extends StatelessWidget {
  final dynamic assessment;

  const _DetailedScoresExpansionTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            '详细分数',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          initiallyExpanded: false,
          children: AbilityConstants.abilities.map((ability) {
            final score = assessment.scores[ability.id] ?? 0.0;
            return _buildAbilityScoreItem(context, ability, score);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAbilityScoreItem(BuildContext context, Ability ability, double score) {
    // 使用默认主题（详细分数列表不支持主题切换）
    final color = PresetRadarThemes.defaultTheme.getCategoryColor(ability.category.colorIndex);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: ListTile(
        leading: Icon(
          ability.icon,
          size: 24,
          color: color,
        ),
        title: Text(ability.name),
        subtitle: Text(
          ability.description,
          style: Theme.of(context).textTheme.bodyMedium,
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
      ),
    );
  }
}

/// 分享主题选择器
class _ShareThemeSelectorSheet extends StatefulWidget {
  final RadarTheme currentTheme;
  final List<RadarTheme> allThemes;
  final dynamic assessment;
  final Function(RadarTheme) onThemeChanged;

  const _ShareThemeSelectorSheet({
    required this.currentTheme,
    required this.allThemes,
    required this.assessment,
    required this.onThemeChanged,
  });

  @override
  State<_ShareThemeSelectorSheet> createState() => _ShareThemeSelectorSheetState();
}

class _ShareThemeSelectorSheetState extends State<_ShareThemeSelectorSheet> {
  late RadarTheme _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75, // 限制高度
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择主题分享',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 大预览图（可滚动）
          Expanded(
            child: SingleChildScrollView(
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
          ),
          const SizedBox(height: 16),
          
          // 主题选择列表（横向滚动）
          SizedBox(
            height: 140,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.allThemes.length,
                itemBuilder: (context, index) {
                  final theme = widget.allThemes[index];
                  return Padding(
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
          ),
          const SizedBox(height: 16),
          
          // 确认按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selectedTheme),
              child: const Text('确认分享'),
            ),
          ),
        ],
      ),
    );
  }
}
