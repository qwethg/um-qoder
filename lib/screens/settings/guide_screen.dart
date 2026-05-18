import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ultimate_wheel/constants/guide_content.dart';
import 'package:ultimate_wheel/config/l10n.dart';

/// 使用指南页面
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('使用指南'.tr),
      ),
      body: Markdown(
        data: guideMarkdownContent,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
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
    );
  }
}
