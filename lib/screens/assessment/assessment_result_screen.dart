import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';

/// 评估结果页 (03-4)
class AssessmentResultScreen extends StatelessWidget {
  final String assessmentId;

  const AssessmentResultScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final assessment = assessmentProvider.getAssessmentById(assessmentId);

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

        return Scaffold(
          appBar: AppBar(
            title: const Text('评估结果'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  // TODO: 分享功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享功能待开发')),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 祝贺文字
                Center(
                  child: Column(
                    children: [
                      Text(
                        '🎉',
                        style: const TextStyle(fontSize: 48),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2,
                  children: [
                    _buildCategoryCard(context, '🏃 身体', athleticismScore, 0),
                    _buildCategoryCard(context, '🧠 意识', awarenessScore, 1),
                    _buildCategoryCard(context, '⚙️ 技术', techniqueScore, 2),
                    _buildCategoryCard(context, '💚 心灵', mindScore, 3),
                  ],
                ),
                const SizedBox(height: 24),

                // 详细分数
                Text(
                  '详细分数',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...AbilityConstants.abilities.map((ability) {
                  final score = assessment.scores[ability.id] ?? 0.0;
                  return _buildAbilityScoreItem(context, ability, score);
                }).toList(),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, double score, int colorIndex) {
    final color = AppTheme.getCategoryColor(colorIndex);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityScoreItem(BuildContext context, Ability ability, double score) {
    final color = AppTheme.getCategoryColor(ability.category.colorIndex);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          ability.emoji,
          style: const TextStyle(fontSize: 24),
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
      ),
    );
  }
}
