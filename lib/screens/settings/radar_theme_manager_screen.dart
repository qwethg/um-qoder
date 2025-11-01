import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';
import 'package:go_router/go_router.dart';

/// 雷达图主题管理页面
class RadarThemeManagerScreen extends StatelessWidget {
  const RadarThemeManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('雷达图主题'),
      ),
      body: Consumer<RadarThemeProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 预设主题区域
              _buildSectionTitle(context, '预设主题'),
              const SizedBox(height: 12),
              _buildThemeGrid(
                context,
                provider.presetThemes,
                provider.currentTheme,
                (theme) => provider.setTheme(theme),
              ),
              const SizedBox(height: 32),
              
              // 自定义主题区域
              _buildSectionTitle(
                context, 
                '我的自定义主题 (${provider.customThemes.length}/${5})',
              ),
              const SizedBox(height: 12),
              
              if (provider.customThemes.isEmpty)
                _buildEmptyCustomThemes(context)
              else
                _buildCustomThemeGrid(context, provider),
              
              const SizedBox(height: 16),
              
              // 创建自定义主题按钮
              if (provider.canCreateMoreCustomThemes)
                FilledButton.icon(
                  onPressed: () => _showCreateCustomThemeDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('创建自定义主题'),
                )
              else
                Text(
                  '已达到自定义主题上限（最多5个）',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeGrid(
    BuildContext context,
    List<RadarTheme> themes,
    RadarTheme currentTheme,
    Function(RadarTheme) onSelect,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        return RadarThemePreview(
          theme: theme,
          isSelected: theme.id == currentTheme.id,
          onTap: () => onSelect(theme),
        );
      },
    );
  }

  Widget _buildCustomThemeGrid(BuildContext context, RadarThemeProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: provider.customThemes.length,
      itemBuilder: (context, index) {
        final theme = provider.customThemes[index];
        return Stack(
          children: [
            RadarThemePreview(
              theme: theme,
              isSelected: theme.id == provider.currentTheme.id,
              onTap: () => provider.setTheme(theme),
            ),
            // 删除按钮
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.all(4),
                ),
                onPressed: () => _confirmDeleteTheme(context, provider, theme),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCustomThemes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.palette_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            '还没有自定义主题',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateCustomThemeDialog(),
    );
  }

  void _confirmDeleteTheme(
    BuildContext context, 
    RadarThemeProvider provider, 
    RadarTheme theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除主题'),
        content: Text('确定要删除「${theme.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteCustomTheme(theme.id);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 创建自定义主题对话框
class _CreateCustomThemeDialog extends StatefulWidget {
  const _CreateCustomThemeDialog();

  @override
  State<_CreateCustomThemeDialog> createState() => _CreateCustomThemeDialogState();
}

class _CreateCustomThemeDialogState extends State<_CreateCustomThemeDialog> {
  final _nameController = TextEditingController();
  Color _athleticismColor = const Color(0xFFE68E46);
  Color _awarenessColor = const Color(0xFF2F504C);
  Color _techniqueColor = const Color(0xFF563437);
  Color _mindColor = const Color(0xFFE7BEBE);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建自定义主题'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主题名称
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '主题名称',
                hintText: '例如：我的专属配色',
              ),
            ),
            const SizedBox(height: 24),
            
            // 颜色选择
            Text(
              '选择类别颜色',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorPicker(
                  context,
                  '身体',
                  _athleticismColor,
                  (color) => setState(() => _athleticismColor = color),
                ),
                _buildColorPicker(
                  context,
                  '意识',
                  _awarenessColor,
                  (color) => setState(() => _awarenessColor = color),
                ),
                _buildColorPicker(
                  context,
                  '技术',
                  _techniqueColor,
                  (color) => setState(() => _techniqueColor = color),
                ),
                _buildColorPicker(
                  context,
                  '心灵',
                  _mindColor,
                  (color) => setState(() => _mindColor = color),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _createTheme,
          child: const Text('创建'),
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, label, currentColor, onColorChanged),
      child: ThemeColorSquare(
        color: currentColor,
        label: label,
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    // 简单的预设颜色选择器
    final presetColors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择$label颜色'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetColors.map((color) {
            return GestureDetector(
              onTap: () {
                onColorChanged(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == currentColor ? Colors.black : Colors.grey.shade300,
                    width: color == currentColor ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _createTheme() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入主题名称')),
      );
      return;
    }

    final provider = context.read<RadarThemeProvider>();
    final theme = await provider.createBasicCustomTheme(
      name: name,
      athleticismColor: _athleticismColor,
      awarenessColor: _awarenessColor,
      techniqueColor: _techniqueColor,
      mindColor: _mindColor,
    );

    if (theme != null && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('主题「$name」创建成功')),
      );
      // 自动应用新创建的主题
      provider.setTheme(theme);
    }
  }
}
