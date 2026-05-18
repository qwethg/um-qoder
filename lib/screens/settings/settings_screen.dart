import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/preferences_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/providers/settings_provider.dart';
import 'package:ultimate_wheel/widgets/api_key_tutorial_dialog.dart';
import 'package:ultimate_wheel/models/ai_provider.dart';

import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'package:ultimate_wheel/services/backup_service.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// 设置页 (06)
// 性能优化: 转换为 StatelessWidget，因为状态由 Provider 和子 StatefulWidget 管理。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: const [
          // 外观设置
          _SectionHeader('外观'),
          _ThemeModeTile(),
          _RadarStyleTile(),
          _RadarThemeTile(),
          Divider(),

          // AI 设置
          _SectionHeader('AI 设置'),
          _AiProviderSettingsCard(),
          _AiParametersCard(),
          _AiPromptTile(),
          Divider(),

          // 评估设置
          _SectionHeader('评估设置'),
          _GoalSettingTile(),
          Divider(),

          // 数据管理
          _SectionHeader('数据管理'),
          _BackupRestoreTile(),
          _ClearDataTile(),
          Divider(),

          // 关于
          _SectionHeader('关于'),
          _AboutTile(),
          _GuideTile(),
          SizedBox(height: 24),

          // 版本信息
          _VersionInfo(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 备份与恢复设置项
class _BackupRestoreTile extends StatelessWidget {
  const _BackupRestoreTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.backup_outlined),
      title: const Text('备份与恢复'),
      subtitle: const Text('导出或导入 JSON 格式的所有数据'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showBackupRestoreDialog(context),
    );
  }

  void _showBackupRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('备份与恢复'),
        content: const Text('您可以将所有数据导出为 JSON 文件进行备份，或者从之前备份的 JSON 文件中恢复数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _handleImport(context);
            },
            child: const Text('导入数据'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _handleExport(context);
            },
            child: const Text('导出数据'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final storageService = context.read<StorageService>();
    final backupService = BackupService(storageService);
    
    final success = await backupService.exportData();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '导出成功' : '导出取消或失败'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final storageService = context.read<StorageService>();
    final backupService = BackupService(storageService);
    
    final success = await backupService.importData();
    
    if (context.mounted) {
      if (success) {
        // 刷新 Provider 中的数据
        context.read<AssessmentProvider>().loadAssessments();
        context.read<GoalSettingProvider>().loadGoalSettings();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入成功，数据已刷新'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入取消或失败（请检查文件格式是否正确）'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}


// --- 拆分的 Widgets ---

/// 区域标题
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 性能优化: 添加 const 关键字。
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
}

/// 主题模式设置项
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 仅监听 themeMode 的变化。
    final themeMode = context.select((PreferencesProvider p) => p.themeMode);

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('主题模式'),
      subtitle: Text(_getThemeModeText(themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeModeDialog(context, context.read<PreferencesProvider>()),
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
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeText(mode)),
              value: mode,
              groupValue: provider.themeMode, // 这里用 provider.themeMode 来获取当前值
              onChanged: (value) {
                if (value != null) {
                  // 性能优化: 在事件处理器中使用 context.read() 或传递的 provider 实例。
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 雷达图样式设置项
class _RadarStyleTile extends StatelessWidget {
  const _RadarStyleTile();

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 仅监听 radarChartStyle 的变化。
    final radarStyle = context.select((PreferencesProvider p) => p.radarChartStyle);

    return ListTile(
      leading: const Icon(Icons.radar_outlined),
      title: const Text('雷达图样式'),
      subtitle: Text('当前：$radarStyle'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showRadarStyleDialog(context, context.read<PreferencesProvider>()),
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
}

/// 雷达图主题设置项
class _RadarThemeTile extends StatelessWidget {
  const _RadarThemeTile();

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 仅监听 currentTheme.name 的变化。
    final themeName = context.select((RadarThemeProvider p) => p.currentTheme.name);

    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('雷达图主题'),
      subtitle: Text('当前：$themeName'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings/radar-theme'),
    );
  }
}

/// AI 供应商与模型设置卡片
class _AiProviderSettingsCard extends StatefulWidget {
  const _AiProviderSettingsCard();

  @override
  State<_AiProviderSettingsCard> createState() => _AiProviderSettingsCardState();
}

class _AiProviderSettingsCardState extends State<_AiProviderSettingsCard> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _endpointPathController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SettingsProvider>();
    _apiKeyController = TextEditingController(text: provider.apiKey);
    _modelController = TextEditingController(text: provider.modelName);
    _baseUrlController = TextEditingController(text: provider.baseUrl);
    _endpointPathController = TextEditingController(text: provider.endpointPath);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    _endpointPathController.dispose();
    super.dispose();
  }

  void _syncControllers(SettingsProvider provider) {
    if (_apiKeyController.text != provider.apiKey) {
      _apiKeyController.value = _apiKeyController.value.copyWith(
        text: provider.apiKey,
        selection: TextSelection.collapsed(offset: provider.apiKey.length),
      );
    }
    if (_modelController.text != provider.modelName) {
      _modelController.value = _modelController.value.copyWith(
        text: provider.modelName,
        selection: TextSelection.collapsed(offset: provider.modelName.length),
      );
    }
    if (_baseUrlController.text != provider.baseUrl) {
      _baseUrlController.value = _baseUrlController.value.copyWith(
        text: provider.baseUrl,
        selection: TextSelection.collapsed(offset: provider.baseUrl.length),
      );
    }
    if (_endpointPathController.text != provider.endpointPath) {
      _endpointPathController.value = _endpointPathController.value.copyWith(
        text: provider.endpointPath,
        selection: TextSelection.collapsed(offset: provider.endpointPath.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    // Make sure controllers stay in sync if provider state changes externally
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllers(provider);
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.memory_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI 服务配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Provider Dropdown
            DropdownButtonFormField<AiProviderId>(
              value: provider.providerId,
              decoration: const InputDecoration(
                labelText: 'AI 模型服务商',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud_outlined),
              ),
              items: aiProviderOptions.map((option) {
                return DropdownMenuItem(
                  value: option.id,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (newProvider) {
                if (newProvider != null) {
                  provider.setProvider(newProvider);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              getProviderOption(provider.providerId).description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // API Key
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
              onChanged: (val) => provider.setApiKey(val),
            ),
            const SizedBox(height: 16),

            // Model Name
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'AI 模型名称',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.hub_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  tooltip: '恢复默认模型',
                  onPressed: () {
                    provider.restoreDefaultModelName();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('模型名称已恢复默认'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              onChanged: (val) => provider.setModelName(val),
            ),
            const SizedBox(height: 16),

            // Base URL
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  tooltip: '恢复默认URL',
                  onPressed: () {
                    provider.restoreDefaultBaseUrl();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Base URL 已恢复默认'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              onChanged: (val) => provider.setBaseUrl(val),
            ),
            const SizedBox(height: 16),

            // Endpoint Path
            TextField(
              controller: _endpointPathController,
              decoration: InputDecoration(
                labelText: 'Endpoint Path',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.route),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  tooltip: '恢复默认路径',
                  onPressed: () {
                    provider.restoreDefaultEndpointPath();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Endpoint Path 已恢复默认'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              onChanged: (val) => provider.setEndpointPath(val),
            ),
            
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showTutorialDialog(context),
                child: const Text('如何获取免费 API Key？'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ApiKeyTutorialDialog(),
    );
  }
}

/// AI 提示词设置项
class _AiPromptTile extends StatelessWidget {
  const _AiPromptTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.edit_note_outlined),
      title: const Text('AI 教练提示词'),
      subtitle: const Text('自定义 AI 教练的系统指令'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAiPromptDialog(context),
    );
  }

  void _showAiPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const _AiPromptDialog(),
    );
  }
}

/// AI 提示词编辑对话框
class _AiPromptDialog extends StatefulWidget {
  const _AiPromptDialog();

  @override
  State<_AiPromptDialog> createState() => _AiPromptDialogState();
}

class _AiPromptDialogState extends State<_AiPromptDialog> {
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    final aiPrompt = context.read<SettingsProvider>().prompt;
    _promptController = TextEditingController(text: aiPrompt);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    return AlertDialog(
      title: const Text('编辑 AI 教练提示词'),
      content: TextField(
        controller: _promptController,
        maxLines: 15,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '请输入 AI 教练的系统提示词...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            provider.restoreDefaultPrompt();
            _promptController.text = provider.prompt;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('提示词已恢复为默认设置'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text('恢复默认'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            provider.setPrompt(_promptController.text);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('提示词已保存'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// AI 模型设置卡片
class _AiModelCard extends StatefulWidget {
  const _AiModelCard();

  @override
  State<_AiModelCard> createState() => _AiModelCardState();
}

/// AI 参数设置卡片
class _AiParametersCard extends StatefulWidget {
  const _AiParametersCard();

  @override
  State<_AiParametersCard> createState() => _AiParametersCardState();
}

class _AiParametersCardState extends State<_AiParametersCard> {
  late final TextEditingController _maxTokensController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _maxTokensController = TextEditingController(text: settings.maxTokens.toString());
  }

  @override
  void dispose() {
    _maxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI 参数',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Temperature（创造性）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: provider.temperature,
                    min: 0.0,
                    max: 1.5,
                    divisions: 30,
                    label: provider.temperature.toStringAsFixed(2),
                    onChanged: (v) => provider.setTemperature(double.parse(v.toStringAsFixed(2))),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    provider.temperature.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Max Tokens（输出长度上限）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxTokensController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_decrease),
                hintText: '例如 2048',
              ),
              onSubmitted: (v) {
                final parsed = int.tryParse(v.trim());
                if (parsed != null && parsed > 0) {
                  provider.setMaxTokens(parsed);
                } else {
                  _maxTokensController.text = provider.maxTokens.toString();
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              '缓存有效期（天）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: provider.cacheTtlDays.toDouble(),
                    min: 7,
                    max: 90,
                    divisions: 83,
                    label: provider.cacheTtlDays.toString(),
                    onChanged: (v) => provider.setCacheTtlDays(v.round()),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    '${provider.cacheTtlDays}天',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      provider.restoreDefaultTemperature();
                      provider.restoreDefaultMaxTokens();
                      provider.restoreDefaultCacheTtlDays();
                      _maxTokensController.text = provider.maxTokens.toString();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('AI 参数已恢复默认'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('恢复默认参数'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiModelCardState extends State<_AiModelCard> {
  late final TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    final aiModel = context.read<SettingsProvider>().modelName;
    _modelController = TextEditingController(text: aiModel);
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.memory_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI 模型设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '当前模型为 SiliconFlow 提供的免费模型。目前仅支持 SiliconFlow 兼容接口。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'AI 模型名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.hub_outlined),
              ),
              onChanged: (value) => provider.setModelName(value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.restoreDefaultModelName();
                  _modelController.text = provider.modelName;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI 模型已恢复为默认设置'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('恢复默认模型'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 目标设定设置项
class _GoalSettingTile extends StatelessWidget {
  const _GoalSettingTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.edit_outlined),
      title: const Text('目标设定'),
      subtitle: const Text('自定义各项能力的分数描述'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/assessment/goal-setting'),
    );
  }
}

/// 清空数据设置项
class _ClearDataTile extends StatelessWidget {
  const _ClearDataTile();

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 仅监听评估数量的变化。
    final assessmentCount = context.select((AssessmentProvider p) => p.assessments.length);

    return ListTile(
      leading: const Icon(Icons.delete_outline),
      title: const Text('清空所有评估记录'),
      subtitle: Text('当前有 $assessmentCount 条记录'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showClearDataDialog(context),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空所有数据'),
        content: const Text('确定要清空所有评估记录吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              // 性能优化: 在事件处理器中使用 context.read()。
              await dialogContext.read<AssessmentProvider>().clearAllAssessments();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
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
}

/// 关于设置项
class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outlined),
      title: const Text('关于 Ultimate Wheel'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context),
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
      children: const [
        SizedBox(height: 16),
        Text('飞盘之轮是一个帮助极限飞盘玩家进行自我评估的工具。'),
        SizedBox(height: 16),
        Text('核心理念：与理想中的自己对话，而非与他人比较。'),
      ],
    );
  }
}

/// 使用指南设置项
class _GuideTile extends StatelessWidget {
  const _GuideTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.book_outlined),
      title: const Text('使用指南'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/welcome'),
    );
  }
}

/// 版本信息
class _VersionInfo extends StatelessWidget {
  const _VersionInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ultimate Wheel v1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '飞盘之轮 - 与理想中的自己对话',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
