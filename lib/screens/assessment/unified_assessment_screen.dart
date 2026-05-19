import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../config/l10n.dart';
import '../../models/ability.dart';
import '../../models/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/goal_setting_provider.dart';

/// 极简禅意风 (Zen/Minimal) 的统一评估页
class UnifiedAssessmentScreen extends StatefulWidget {
  const UnifiedAssessmentScreen({super.key});

  @override
  State<UnifiedAssessmentScreen> createState() => _UnifiedAssessmentScreenState();
}

class _UnifiedAssessmentScreenState extends State<UnifiedAssessmentScreen> {
  final Map<String, double> _scores = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initScores();
  }

  void _initScores() {
    final provider = context.read<AssessmentProvider>();
    final latest = provider.latestAssessment;
    
    for (final ability in AbilityConstants.abilities) {
      _scores[ability.id] = latest?.scores[ability.id] ?? 0.0;
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    
    try {
      final assessment = Assessment(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        scores: Map.from(_scores),
        notes: {}, // Notes field kept in data model but hidden from UI
        type: AssessmentType.quick,
      );

      await context.read<AssessmentProvider>().saveAssessment(assessment);
      
      if (mounted) {
        context.go('/assessment/unified-result/${assessment.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'.tr)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearBindingGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ...AbilityCategory.values.map((category) => _CategoryZenBlock(
                              category: category,
                              scores: _scores,
                              onScoreChanged: (abilityId, score) {
                                setState(() {
                                  _scores[abilityId] = score;
                                });
                              },
                            )),
                        const SizedBox(height: 120), // 为底部按钮留白
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 24, // 悬浮在底部导航栏上方
                left: 0,
                right: 0,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '与自己的对话'.tr,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '轻轻滑动，感受当下的状态'.tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSaving ? null : _handleSave,
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '保存并生成雷达图'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 自定义渐变背景
class LinearBindingGradient extends LinearGradient {
  const LinearBindingGradient({
    required super.colors,
  }) : super(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 1.0],
        );
}

/// 禅意风格的类别块
class _CategoryZenBlock extends StatelessWidget {
  final AbilityCategory category;
  final Map<String, double> scores;
  final Function(String, double) onScoreChanged;

  const _CategoryZenBlock({
    required this.category,
    required this.scores,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final abilities = AbilityConstants.getAbilitiesByCategory(category);
    final themeColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category.name.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                    color: themeColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...abilities.map((ability) => _ZenSliderRow(
                  ability: ability,
                  currentScore: scores[ability.id] ?? 0.0,
                  color: themeColor,
                  onChanged: (val) => onScoreChanged(ability.id, val),
                )),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AbilityCategory category) {
    switch (category) {
      case AbilityCategory.athleticism:
        return const Color(0xFFE8A39B); // 珊瑚粉
      case AbilityCategory.awareness:
        return const Color(0xFF6C7B95); // 雾霾蓝
      case AbilityCategory.technique:
        return const Color(0xFF82B09F); // 鼠尾草绿
      case AbilityCategory.mind:
        return const Color(0xFFD4A5A5); // 藕粉色
    }
  }
}

/// 禅意风格的滑动行
class _ZenSliderRow extends StatelessWidget {
  final Ability ability;
  final double currentScore;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ZenSliderRow({
    required this.ability,
    required this.currentScore,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final goalProvider = context.read<GoalSettingProvider>();
    final desc10 = goalProvider.getDescription(ability.id, 10);
    final desc7 = goalProvider.getDescription(ability.id, 7);
    final desc5 = goalProvider.getDescription(ability.id, 5);
    final desc3 = goalProvider.getDescription(ability.id, 3);
    
    final tooltipText = '10分: $desc10\n7分: $desc7\n5分: $desc5\n3分: $desc3';

    // Ghost cursor logic
    final assessmentProvider = context.read<AssessmentProvider>();
    final previousScore = assessmentProvider.latestAssessment?.scores[ability.id] ?? 0.0;
    
    // Calculate diff for subtle indicator
    final diff = currentScore - previousScore;
    Widget diffIndicator = const SizedBox.shrink();
    
    if (diff.abs() > 0.1) {
      final isPositive = diff > 0;
      diffIndicator = Text(
        isPositive ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1),
        style: TextStyle(
          fontSize: 9,
          color: isPositive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      diffIndicator = Text(
        '=',
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey.withOpacity(0.5),
          fontWeight: FontWeight.w300,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          // 左侧：名称与信息气泡
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ability.name.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: tooltipText,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, 
                    fontSize: 12, 
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    child: Icon(
                      Icons.lens_blur, 
                      size: 12, 
                      color: color.withOpacity(0.5)
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 中间：极简双层滑块
          Expanded(
            child: SizedBox(
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 底层 Ghost
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.grey.withOpacity(0.08),
                      thumbColor: Colors.grey.withOpacity(0.15),
                      overlayColor: Colors.transparent,
                      trackHeight: 1.0, // 极细线条
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3.0),
                    ),
                    child: Slider(
                      value: previousScore,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      onChanged: null,
                    ),
                  ),
                  // 表层 交互
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color.withOpacity(0.6),
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: color,
                      overlayColor: color.withOpacity(0.1),
                      trackHeight: 2.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                        elevation: 4.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: Slider(
                      value: currentScore,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      onChanged: (value) {
                        onChanged(value);
                        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                          if (value % 1 == 0) { // 整数分震动
                            HapticFeedback.lightImpact();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 右侧：分数与分差
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                diffIndicator,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
