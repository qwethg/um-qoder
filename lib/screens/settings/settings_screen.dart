import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:go_router/go_router.dart';

/// 设置页 (06)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer2<PreferencesProvider, AssessmentProvider>(
        builder: (context, prefsProvider, assessmentProvider, _) {
          return ListView(
            children: [
              // 外观设置
              _buildSectionHeader(context, '外观'),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('主题模式'),
                subtitle: Text(_getThemeModeText(prefsProvider.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeModeDialog(context, prefsProvider),
              ),
              ListTile(
                leading: const Icon(Icons.radar_outlined),
                title: const Text('雷达图样式'),
                subtitle: Text('当前：${prefsProvider.radarChartStyle}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRadarStyleDialog(context, prefsProvider),
              ),

              const Divider(),

              // 评估设置
              _buildSectionHeader(context, '评估'),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('目标设定'),
                subtitle: const Text('自定义各项能力的分数描述'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/assessment/goal-setting'),
              ),

              const Divider(),

              // 数据管理
              _buildSectionHeader(context, '数据管理'),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('清空所有评估记录'),
                subtitle: Text('当前有 ${assessmentProvider.assessments.length} 条记录'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearDataDialog(context, assessmentProvider),
              ),

              const Divider(),

              // 关于
              _buildSectionHeader(context, '关于'),
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('关于 Ultimate Wheel'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('使用指南'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/welcome'),
              ),

              const SizedBox(height: 24),

              // 版本信息
              Center(
                child: Text(
                  'Ultimate Wheel v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '飞盘之轮 - 与理想中的自己对话',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showThemeModeDialog(BuildContext context, PreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('浅色模式'),
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色模式'),
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadarStyleDialog(BuildContext context, PreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('雷达图样式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('default'),
              subtitle: const Text('默认样式'),
              selected: provider.radarChartStyle == 'default',
              onTap: () {
                provider.setRadarChartStyle('default');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AssessmentProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text('确定要清空所有评估记录吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await provider.clearAllAssessments();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已清空所有记录')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ultimate Wheel',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🥏', style: TextStyle(fontSize: 48)),
      children: [
        const SizedBox(height: 16),
        const Text('飞盘之轮是一个帮助极限飞盘玩家进行自我评估的工具。'),
        const SizedBox(height: 16),
        const Text('核心理念：与理想中的自己对话，而非与他人比较。'),
      ],
    );
  }
}
