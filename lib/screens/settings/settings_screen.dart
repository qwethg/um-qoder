import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';
import 'package:go_router/go_router.dart';

/// 设置页 (06)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
      _apiKeyController.text = prefsProvider.apiKey;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer3<PreferencesProvider, AssessmentProvider, RadarThemeProvider>(
        builder: (context, prefsProvider, assessmentProvider, themeProvider, _) {
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
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('雷达图主题'),
                subtitle: Text('当前：${themeProvider.currentTheme.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/radar-theme'),
              ),
              // 主题预览
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: RadarThemePreview(
                  theme: themeProvider.currentTheme,
                  size: 150,
                  showName: false,
                ),
              ),

              const Divider(),

              // AI 设置
              _buildSectionHeader(context, 'AI 设置'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.key_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'API Key 设置',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '输入您的 SiliconFlow API Key 以启用 AI 智能分析功能',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          hintText: '请输入您的 API Key',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _apiKeyController.clear(),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _saveApiKey(context, prefsProvider),
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('保存 API Key'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              // 评估设置
              _buildSectionHeader(context, '评估设置'),
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

  void _saveApiKey(BuildContext context, PreferencesProvider provider) async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key 不能为空'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await provider.updateApiKey(key);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key 已保存'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      applicationIcon: Icon(
        Icons.sports,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 16),
        const Text('飞盘之轮是一个帮助极限飞盘玩家进行自我评估的工具。'),
        const SizedBox(height: 16),
        const Text('核心理念：与理想中的自己对话，而非与他人比较。'),
      ],
    );
  }
}
