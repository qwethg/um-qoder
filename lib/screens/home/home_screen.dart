import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'package:ultimate_wheel/services/ai_service.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 首页 (02-1 / 02-2)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _aiService = AiService();
  bool _isLoadingAi = false;
  String? _aiAnalysisResult;

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
    // 需要从 Provider 获取 assessmentProvider
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    
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
          
          // AI 分析结果卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 智能分析',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _aiAnalysisResult ?? '点击下方按钮，获取 AI 教练为您生成的专业分析报告',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _aiAnalysisResult == null 
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_aiAnalysisResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () => _showAiAnalysisResult(context),
                        child: const Text('查看完整报告'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI 分析按钮
          Consumer2<PreferencesProvider, GoalSettingProvider>(
            builder: (context, prefsProvider, goalProvider, _) {
              final hasApiKey = prefsProvider.apiKey.isNotEmpty;
              
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: hasApiKey && !_isLoadingAi
                    ? () => _fetchAiAnalysis(
                          context,
                          assessment,
                          assessmentProvider,
                          goalProvider,
                          prefsProvider,
                        )
                    : null,
                  icon: _isLoadingAi
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isLoadingAi 
                      ? 'AI 教练分析中...' 
                      : hasApiKey
                        ? '获取 AI 智能分析'
                        : '请先在设置中配置 API Key',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
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

  /// 获取 AI 分析
  Future<void> _fetchAiAnalysis(
    BuildContext context,
    dynamic assessment,
    AssessmentProvider assessmentProvider,
    GoalSettingProvider goalProvider,
    PreferencesProvider prefsProvider,
  ) async {
    setState(() {
      _isLoadingAi = true;
      _aiAnalysisResult = null;
    });

    try {
      // 获取上一次评估记录（用于对比）
      final allAssessments = assessmentProvider.assessments;
      final currentIndex = allAssessments.indexWhere((a) => a.id == assessment.id);
      final previousAssessment = currentIndex < allAssessments.length - 1
          ? allAssessments[currentIndex + 1]
          : null;

      // 获取用户目标设定
      final goalSettings = <String, GoalSetting>{};
      for (final ability in AbilityConstants.abilities) {
        final setting = goalProvider.getGoalSetting(ability.id);
        if (setting != null) {
          goalSettings[ability.id] = setting;
        }
      }

      // 调用 AI 服务
      final result = await _aiService.generateAnalysis(
        currentAssessment: assessment,
        userGoalSettings: goalSettings,
        previousAssessment: previousAssessment,
        apiKey: prefsProvider.apiKey,
      );

      setState(() {
        // 只保存总体评价部分（前3行或前200字）
        final lines = result.split('\n');
        final overviewSection = lines.where((line) => 
          line.isNotEmpty && 
          !line.startsWith('#') && 
          !line.startsWith('**') &&
          !line.contains('分项') &&
          !line.contains('行动计划')
        ).take(3).join('\n');
        _aiAnalysisResult = overviewSection.length > 200 
          ? '${overviewSection.substring(0, 200)}...'
          : overviewSection;
        _isLoadingAi = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI 分析已生成，点击"查看完整报告"查看详情'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingAi = false;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成分析失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: () => _fetchAiAnalysis(
                context,
                assessment,
                assessmentProvider,
                goalProvider,
                prefsProvider,
              ),
            ),
          ),
        );
      }
    }
  }

  /// 显示 AI 分析结果
  void _showAiAnalysisResult(BuildContext context) async {
    // 重新获取完整结果
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalSettingProvider>(context, listen: false);
    final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
    final latestAssessment = assessmentProvider.latestAssessment;
    
    if (latestAssessment == null) return;

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  '加载完整报告中...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 获取完整报告
      final allAssessments = assessmentProvider.assessments;
      final currentIndex = allAssessments.indexWhere((a) => a.id == latestAssessment.id);
      final previousAssessment = currentIndex < allAssessments.length - 1
          ? allAssessments[currentIndex + 1]
          : null;

      final goalSettings = <String, GoalSetting>{};
      for (final ability in AbilityConstants.abilities) {
        final setting = goalProvider.getGoalSetting(ability.id);
        if (setting != null) {
          goalSettings[ability.id] = setting;
        }
      }

      final fullResult = await _aiService.generateAnalysis(
        currentAssessment: latestAssessment,
        userGoalSettings: goalSettings,
        previousAssessment: previousAssessment,
        apiKey: prefsProvider.apiKey,
      );

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        
        // 显示完整报告
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 顶部标题栏
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'AI 智能分析报告',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                  // Markdown 内容
                  Expanded(
                    child: Markdown(
                      controller: scrollController,
                      data: fullResult,
                      styleSheet: MarkdownStyleSheet(
                        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        p: Theme.of(context).textTheme.bodyMedium,
                        listBullet: Theme.of(context).textTheme.bodyMedium,
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载完整报告失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
