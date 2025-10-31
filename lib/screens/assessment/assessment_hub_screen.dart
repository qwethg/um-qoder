import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 评估中心 (03)
class AssessmentHubScreen extends StatelessWidget {
  const AssessmentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评估中心'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 目标设定
            _AssessmentCard(
              emoji: '🎯',
              title: '目标设定',
              description: '定义你的巅峰：描绘你心中10分的样子',
              color: const Color(0xFF4ECDC4),
              onTap: () => context.go('/assessment/goal-setting'),
            ),
            const SizedBox(height: 16),
            
            // 深度评估
            _AssessmentCard(
              emoji: '🧘',
              title: '深度评估',
              description: '沉浸式体验：一次与自己对话的完整仪式',
              color: const Color(0xFF95E1D3),
              onTap: () => context.go('/assessment/deep'),
            ),
            const SizedBox(height: 16),
            
            // 快速评估
            _AssessmentCard(
              emoji: '⚡',
              title: '快速评估',
              description: '快速更新：用5分钟追踪你的即时状态',
              color: const Color(0xFFFFA8E2),
              onTap: () => context.go('/assessment/quick'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 评估卡片组件
class _AssessmentCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AssessmentCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              
              // 文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 箭头
              Icon(
                Icons.arrow_forward_ios,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
