import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ultimate_wheel/constants/guide_content.dart';
import 'package:ultimate_wheel/config/l10n.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';

/// 使用指南页面
class GuideScreen extends StatelessWidget {
  final bool fromWelcome;
  
  const GuideScreen({
    super.key,
    this.fromWelcome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用指南'.tr),
      ),
      body: Column(
        children: [
          Expanded(
            child: Markdown(
              data: guideMarkdownContent,
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 16, 
                bottom: fromWelcome ? 32 : 100,
              ),
              selectable: true,
              onTapLink: (text, href, title) async {
                if (href != null) {
                  final uri = Uri.parse(href);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
              },
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                h2Padding: const EdgeInsets.only(top: 24, bottom: 12),
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                listBullet: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          if (fromWelcome)
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // 标记首次启动完成，并直接进入首页
                    Provider.of<PreferencesProvider>(context, listen: false)
                        .completeFirstLaunch();
                    context.go('/home');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '阅读完毕，开始我的飞盘之轮',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
