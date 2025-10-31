import 'package:flutter/material.dart';

/// 目标设定页 (03-1)
class GoalSettingScreen extends StatelessWidget {
  const GoalSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目标设定'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 提示文字
            Text(
              '定义你心中的10分',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '在这里，设定你心中各项能力10分应该是什么样子。这将成为你评估的基准。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // 占位内容
            const Center(
              child: Text('目标设定页面 - 开发中'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('恢复默认'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {},
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
