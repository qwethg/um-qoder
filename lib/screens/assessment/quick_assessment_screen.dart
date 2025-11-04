import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 快速评估页 (03-3)
class QuickAssessmentScreen extends StatefulWidget {
  const QuickAssessmentScreen({super.key});

  @override
  State<QuickAssessmentScreen> createState() => _QuickAssessmentScreenState();
}

class _QuickAssessmentScreenState extends State<QuickAssessmentScreen> {
  // 存储每个能力的评分 (abilityId -> score)
  final Map<String, double> _scores = {};
  
  // 是否正在保存
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 初始化所有能力的分数为0
    for (final ability in AbilityConstants.abilities) {
      _scores[ability.id] = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快速评估'),
      ),
      // 性能优化: 移除了包裹整体的 Consumer，因为 GoalSettingProvider 的数据是静态的，不需要监听。
      body: SingleChildScrollView(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 性能优化: 拆分为独立的 StatelessWidget。
            const _AssessmentHeader(),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 32),
            
            // 按类别分组显示
            // 性能优化: 将类别区域拆分为独立的 StatelessWidget。
            ...AbilityCategory.values.map((category) {
              final abilities = AbilityConstants.getAbilitiesByCategory(category);
              final color = AppTheme.getCategoryColor(category.colorIndex);
              return _AbilityCategorySection(
                key: ValueKey(category),
                category: category,
                abilities: abilities,
                scores: _scores,
                color: color,
                onScoreChanged: (abilityId, score) {
                  setState(() {
                    _scores[abilityId] = score;
                  });
                },
              );
            }),
            
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 80), // 留出底部按钮空间
          ],
        ),
      ),
      // BUG修复: 修正了 Scaffold 结构，将底部栏正确放置在 bottomNavigationBar。
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建底部按钮栏
  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(24.0),
        child: FilledButton(
          onPressed: _isSaving ? null : _handleComplete,
          // 性能优化: 添加 const 关键字。
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSaving
              // 性能优化: 添加 const 关键字。
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              // 性能优化: 添加 const 关键字。
              : const Text('完成评估'),
        ),
      ),
    );
  }

  /// 处理完成评估
  Future<void> _handleComplete() async {
    // 检查是否有未评分的项目
    final hasUnscored = _scores.values.any((score) => score == 0.0);
    if (hasUnscored) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          // 性能优化: 添加 const 关键字。
          title: const Text('提示'),
          content: const Text('还有未评分的项目，确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              // 性能优化: 添加 const 关键字。
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              // 性能优化: 添加 const 关键字。
              child: const Text('继续'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 创建评估记录
      final assessment = Assessment(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        type: AssessmentType.quick,
        scores: Map.from(_scores),
        notes: const {},
      );

      // 保存评估
      if (mounted) {
        // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
        await context.read<AssessmentProvider>().saveAssessment(assessment);

        // 跳转到结果页
        if (mounted) {
          context.go('/assessment/result/${assessment.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// 评估页面的静态标题和描述
class _AssessmentHeader extends StatelessWidget {
  const _AssessmentHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速评估',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 8),
        Text(
          '用 5 分钟快速更新你的能力状态。根据你对当前状态的满意度进行评分。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// 单个能力类别的 UI 区域
class _AbilityCategorySection extends StatelessWidget {
  final AbilityCategory category;
  final List<Ability> abilities;
  final Map<String, double> scores;
  final Color color;
  final Function(String, double) onScoreChanged;

  const _AbilityCategorySection({
    super.key,
    required this.category,
    required this.abilities,
    required this.scores,
    required this.color,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类别标题
        Padding(
          // 性能优化: 添加 const 关键字。
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 20,
                color: color,
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(width: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // 能力项列表
        ...abilities.map((ability) {
          return _AbilityItem(
            key: ValueKey(ability.id),
            ability: ability,
            color: color,
            score: scores[ability.id] ?? 0.0,
            onChanged: (score) => onScoreChanged(ability.id, score),
          );
        }),

        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 32),
      ],
    );
  }
}

/// 单个能力项的 UI，包含滑块和描述
class _AbilityItem extends StatelessWidget {
  final Ability ability;
  final Color color;
  final double score;
  final ValueChanged<double> onChanged;

  const _AbilityItem({
    super.key,
    required this.ability,
    required this.color,
    required this.score,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showDescription = score == 3.0 || score == 5.0 || score == 7.0 || score == 10.0;

    return Card(
      // 性能优化: 添加 const 关键字。
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 能力名称和当前分数
            Row(
              children: [
                Icon(
                  ability.icon,
                  size: 22,
                  color: color,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ability.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        ability.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    score.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 16),

            // 滑块
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: score,
                min: 0,
                max: 10,
                divisions: 20, // 0.5 为一个刻度
                label: score.toStringAsFixed(1),
                onChanged: (value) {
                  onChanged(value);
                  // 移动端震动反馈
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                    if (value == 3.0 || value == 5.0 || value == 7.0 || value == 10.0) {
                      HapticFeedback.lightImpact();
                    }
                  }
                },
              ),
            ),

            // 显示描述（当分数为 3/5/7/10 时）
            if (showDescription)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: color,
                    ),
                    // 性能优化: 添加 const 关键字。
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        // 性能优化: 改用 context.read()，仅在需要时读取数据，不产生监听。
                        context.read<GoalSettingProvider>().getDescription(
                          ability.id,
                          score.toInt(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}