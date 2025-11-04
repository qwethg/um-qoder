import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';

/// 历史记录页 (04)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 性能优化: 改用 Selector，仅监听 assessmentProvider.assessments 列表，避免不必要的重建。
    return Selector<AssessmentProvider, List<Assessment>>(
      selector: (_, provider) => provider.assessments,
      builder: (context, assessments, _) {
        final isEmpty = assessments.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text('历史记录'),
            actions: [
              // 只有在有数据时才显示趋势分析按钮
              if (!isEmpty)
                IconButton(
                  icon: const Icon(Icons.show_chart),
                  tooltip: '趋势分析',
                  onPressed: () => context.push('/history/trend'),
                ),
            ],
          ),
          body: isEmpty
              // 性能优化: 拆分为独立的 StatelessWidget。
              ? const _EmptyState()
              : ListView.builder(
                  // 性能优化: 添加 const 关键字。
                  padding: const EdgeInsets.all(16.0),
                  itemCount: assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = assessments[index];
                    // 性能优化: 拆分为独立的 StatelessWidget。
                    return _AssessmentCard(
                      assessment: assessment,
                      isLatest: index == 0, // 列表已排序，第一个就是最新的
                      showComparisonButton: assessments.length > 1 && index == 0,
                    );
                  },
                ),
        );
      },
    );
  }
}

/// 空状态 Widget
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
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 24),
            Text(
              '还没有评估记录',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 8),
            Text(
              '完成第一次评估后，这里会显示你的成长轨迹',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/assessment'),
              // 性能优化: 添加 const 关键字。
              icon: const Icon(Icons.add),
              label: const Text('开始评估'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 评估卡片 Widget
class _AssessmentCard extends StatelessWidget {
  final Assessment assessment;
  final bool isLatest;
  final bool showComparisonButton;

  const _AssessmentCard({
    required this.assessment,
    required this.isLatest,
    required this.showComparisonButton,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final typeText = assessment.type == AssessmentType.deep ? '深度评估' : '快速评估';

    return Card(
      // 性能优化: 添加 const 关键字。
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/assessment/result/${assessment.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          // 性能优化: 添加 const 关键字。
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dateFormat.format(assessment.createdAt),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (isLatest) ...[
                              // 性能优化: 添加 const 关键字。
                              const SizedBox(width: 8),
                              Container(
                                // 性能优化: 添加 const 关键字。
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightSecondary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '最新',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // 性能优化: 添加 const 关键字。
                        const SizedBox(height: 4),
                        Container(
                          // 性能优化: 添加 const 关键字。
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: assessment.type == AssessmentType.deep
                                ? AppTheme.lightSecondary.withOpacity(0.2)
                                : AppTheme.lightPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: assessment.type == AssessmentType.deep
                                      ? AppTheme.lightSecondary
                                      : AppTheme.lightPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // 性能优化: 添加 const 关键字。
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      assessment.totalScore.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(height: 16),
              
              // 分类得分
              Row(
                children: [
                  // 性能优化: 拆分为独立的 StatelessWidget。
                  _MiniScoreChip(
                    icon: Icons.directions_run,
                    score: assessment.getCategoryScore(AbilityConstants.getAbilitiesByCategory(AbilityCategory.athleticism).map((e) => e.id).toList()),
                    colorIndex: 0,
                  ),
                  // 性能优化: 添加 const 关键字。
                  const SizedBox(width: 8),
                  _MiniScoreChip(
                    icon: Icons.visibility,
                    score: assessment.getCategoryScore(AbilityConstants.getAbilitiesByCategory(AbilityCategory.awareness).map((e) => e.id).toList()),
                    colorIndex: 1,
                  ),
                  // 性能优化: 添加 const 关键字。
                  const SizedBox(width: 8),
                  _MiniScoreChip(
                    icon: Icons.build,
                    score: assessment.getCategoryScore(AbilityConstants.getAbilitiesByCategory(AbilityCategory.technique).map((e) => e.id).toList()),
                    colorIndex: 2,
                  ),
                  // 性能优化: 添加 const 关键字。
                  const SizedBox(width: 8),
                  _MiniScoreChip(
                    icon: Icons.favorite,
                    score: assessment.getCategoryScore(AbilityConstants.getAbilitiesByCategory(AbilityCategory.mind).map((e) => e.id).toList()),
                    colorIndex: 3,
                  ),
                ],
              ),
              
              // 对比按钮
              if (showComparisonButton) ...[
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/history/comparison/${assessment.id}'),
                    // 性能优化: 添加 const 关键字。
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('与历史对比'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 迷你得分标签 Widget
class _MiniScoreChip extends StatelessWidget {
  final IconData icon;
  final double score;
  final int colorIndex;

  const _MiniScoreChip({
    required this.icon,
    required this.score,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCategoryColor(colorIndex);
    return Expanded(
      child: Container(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 4),
            Text(
              score.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
