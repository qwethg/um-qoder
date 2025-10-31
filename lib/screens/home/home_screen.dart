import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 首页 (02-1 / 02-2)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 检查是否有评估历史
    final hasAssessments = false; // 临时

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
      body: hasAssessments
          ? _buildWithAssessments(context)
          : _buildEmptyState(context),
    );
  }

  /// 有评估记录的首页 (02-2)
  Widget _buildWithAssessments(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最新评估的雷达图
          Card(
            child: Container(
              height: 300,
              alignment: Alignment.center,
              child: const Text('雷达图占位符'),
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
                    '72.5',
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
              _buildCategoryCard(context, '🏃 身体', 7.5),
              _buildCategoryCard(context, '🧠 意识', 6.3),
              _buildCategoryCard(context, '⚙️ 技术', 5.8),
              _buildCategoryCard(context, '💚 心灵', 8.2),
            ],
          ),
          const SizedBox(height: 24),
          
          // 总览评价
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本次评估总览',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '你在身体素质和心灵层面表现出色，特别是团队协作能力值得称赞。技术方面仍有提升空间，建议加强传盘和接盘的练习。继续保持积极的心态，你正在稳步成长。',
                  ),
                ],
              ),
            ),
          ),
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
                child: Text(
                  '准备好开始\n第一次深度评估了吗？',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
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

  Widget _buildCategoryCard(BuildContext context, String title, double score) {
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
            Text(
              score.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
