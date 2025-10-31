import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';

/// 目标设定页 (03-1)
class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  // 存储每个能力的描述 (abilityId -> {score -> description})
  final Map<String, Map<int, TextEditingController>> _controllers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 初始化所有控制器
    final goalProvider = Provider.of<GoalSettingProvider>(context, listen: false);
    
    for (final ability in AbilityConstants.abilities) {
      _controllers[ability.id] = {};
      for (final score in [3, 5, 7, 10]) {
        final description = goalProvider.getDescription(ability.id, score);
        _controllers[ability.id]![score] = TextEditingController(text: description);
      }
    }
  }

  @override
  void dispose() {
    // 释放所有控制器
    for (final abilityControllers in _controllers.values) {
      for (final controller in abilityControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

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
              '在这里，设定你心中各项能力 3/5/7/10 分应该是什么样子。这将成为你评估的基准。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            
            // 按类别分组显示
            ...AbilityCategory.values.map((category) {
              final abilities = AbilityConstants.getAbilitiesByCategory(category);
              return _buildCategorySection(context, category, abilities);
            }),
            
            const SizedBox(height: 80), // 留出底部按钮空间
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建类别区域
  Widget _buildCategorySection(
    BuildContext context,
    AbilityCategory category,
    List<Ability> abilities,
  ) {
    final color = AppTheme.getCategoryColor(category.colorIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类别标题
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 能力项列表
        ...abilities.map((ability) {
          return _buildAbilityItem(context, ability, color);
        }),

        const SizedBox(height: 32),
      ],
    );
  }

  /// 构建单个能力项
  Widget _buildAbilityItem(
    BuildContext context,
    Ability ability,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        leading: Icon(
          ability.icon,
          size: 24,
          color: color,
        ),
        title: Text(
          ability.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          ability.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 10分
                _buildScoreField(context, ability.id, 10, '10分 - 理想工峰', color, Icons.emoji_events),
                const SizedBox(height: 12),
                // 7分
                _buildScoreField(context, ability.id, 7, '7分 - 优秀水平', color, Icons.star),
                const SizedBox(height: 12),
                // 5分
                _buildScoreField(context, ability.id, 5, '5分 - 良好水平', color, Icons.thumb_up),
                const SizedBox(height: 12),
                // 3分
                _buildScoreField(context, ability.id, 3, '3分 - 基础水平', color, Icons.local_florist),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分数描述输入框
  Widget _buildScoreField(
    BuildContext context,
    String abilityId,
    int score,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[abilityId]![score],
          maxLines: 2,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: '请描述 $score 分应该是什么样子...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: color.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  /// 构建底部按钮栏
  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _handleReset,
                child: const Text('恢复默认'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理恢复默认
  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('确定要恢复所有设定为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 恢复所有控制器为默认值
      for (final ability in AbilityConstants.abilities) {
        for (final score in [3, 5, 7, 10]) {
          final defaultText = DefaultGoalTexts.getDefault(ability.id, score) ?? '';
          _controllers[ability.id]![score]!.text = defaultText;
        }
      }

      // 清空存储
      if (mounted) {
        await Provider.of<GoalSettingProvider>(context, listen: false).resetToDefault();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已恢复为默认设定')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// 处理保存
  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 收集所有描述
      final settingsMap = <String, Map<int, String>>{};
      
      for (final ability in AbilityConstants.abilities) {
        settingsMap[ability.id] = {};
        for (final score in [3, 5, 7, 10]) {
          final text = _controllers[ability.id]![score]!.text.trim();
          if (text.isNotEmpty) {
            settingsMap[ability.id]![score] = text;
          }
        }
      }

      // 保存
      if (mounted) {
        await Provider.of<GoalSettingProvider>(context, listen: false)
            .saveAllGoalSettings(settingsMap);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
