import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';

/// 欢迎界面 (01)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomePage> _pages = const [
    WelcomePage(
      title: '与理想中的自己对话',
      emoji: '💭',
      description: '这不是与他人的比较\n而是一次与自己的坦诚对话',
    ),
    WelcomePage(
      title: '满意度，而非排名',
      emoji: '🎯',
      description: '评分代表你对现状的满意度\n衡量的是现状与目标的差距',
    ),
    WelcomePage(
      title: '一场成长的仪式',
      emoji: '🌱',
      description: '花15-20分钟\n沉浸在这个专注而温柔的时刻',
    ),
    WelcomePage(
      title: '平衡即是圆满',
      emoji: '⚖️',
      description: '目标不是成为满分的"怪物"\n而是成为更圆满、更平衡的自己',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('跳过'),
              ),
            ),
            
            // 页面内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            
            // 指示器
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
            ),
            
            // 开始按钮
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FilledButton(
                onPressed: () {
                  // 标记首次启动完成
                  Provider.of<PreferencesProvider>(context, listen: false)
                      .completeFirstLaunch();
                  context.go('/home');
                },
                child: const Text('开始我的飞盘之轮'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// 欢迎页内容
class WelcomePage extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;

  const WelcomePage({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 32),
          
          // 标题
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // 描述
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
