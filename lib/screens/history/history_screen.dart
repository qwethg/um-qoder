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
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final assessments = assessmentProvider.assessments;

        if (assessments.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('历史记录')),
            body: _buildEmptyState(context),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('历史记录'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return _buildAssessmentCard(context, assessment);
            },
          ),
        );
      },
    );
  }

  /// 空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '还没有评估记录',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '完成第一次评估后，这里会显示你的成长轨迹',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/assessment'),
              icon: const Icon(Icons.add),
              label: const Text('开始评估'),
            ),
          ],
        ),
      ),
    );
  }

  /// 评估卡片
  Widget _buildAssessmentCard(BuildContext context, Assessment assessment) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final typeText = assessment.type == AssessmentType.deep ? '深度评估' : '快速评估';
    
    // 计算各类别得分
    final athleticismIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.athleticism)
        .map((a) => a.id).toList();
    final awarenessIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.awareness)
        .map((a) => a.id).toList();
    final techniqueIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.technique)
        .map((a) => a.id).toList();
    final mindIds = AbilityConstants.getAbilitiesByCategory(AbilityCategory.mind)
        .map((a) => a.id).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/assessment/result/${assessment.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(assessment.createdAt),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: assessment.type == AssessmentType.deep
                              ? AppTheme.lightSecondary.withOpacity(0.2)  // 珊瑚粉
                              : AppTheme.lightPrimary.withOpacity(0.2),   // 雾霾蓝
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: assessment.type == AssessmentType.deep
                                ? AppTheme.lightSecondary               // 珊瑚粉
                                : AppTheme.lightPrimary,                // 雾霾蓝
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
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
              const SizedBox(height: 16),
              
              // 分类得分
              Row(
                children: [
                  _buildMiniScoreChip(context, Icons.directions_run, assessment.getCategoryScore(athleticismIds), 0),
                  const SizedBox(width: 8),
                  _buildMiniScoreChip(context, Icons.visibility, assessment.getCategoryScore(awarenessIds), 1),
                  const SizedBox(width: 8),
                  _buildMiniScoreChip(context, Icons.build, assessment.getCategoryScore(techniqueIds), 2),
                  const SizedBox(width: 8),
                  _buildMiniScoreChip(context, Icons.favorite, assessment.getCategoryScore(mindIds), 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniScoreChip(BuildContext context, IconData icon, double score, int colorIndex) {
    final color = AppTheme.getCategoryColor(colorIndex);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
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
