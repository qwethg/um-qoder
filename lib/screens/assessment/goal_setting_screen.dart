import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';

/// 目标设定页 (03-1)
class GoalSettingScreen extends StatefulWidget {
  // 性能优化: 添加 const 构造函数。
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
    // 性能优化: 在 initState 中使用 context.read() 是最佳实践。
    final goalProvider = context.read<GoalSettingProvider>();
    
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
    // BUG修复: 逻辑正确，无需修改。确保所有控制器都被释放。
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
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 性能优化: 拆分为独立的 StatelessWidget。
            const _Header(),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 24),
            
            // 按类别分组显示
            ...AbilityCategory.values.map((category) {
              final abilities = AbilityConstants.getAbilitiesByCategory(category);
              // 性能优化: 拆分为独立的 StatelessWidget。
              return _CategorySection(
                category: category,
                abilities: abilities,
                controllers: _controllers,
              );
            }),
            
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 80), // 留出底部按钮空间
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        isSaving: _isSaving,
        onReset: _handleReset,
        onSave: _handleSave,
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
        // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
        await context.read<GoalSettingProvider>().resetToDefault();
        
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
        // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
        await context.read<GoalSettingProvider>().saveAllGoalSettings(settingsMap);
        
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

/// 页面头部 Widget
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '定义你心中的10分',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 8),
        Text(
          '在这里，设定你心中各项能力 3/5/7/10 分应该是什么样子。这将成为你评估的基准。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// 类别区域 Widget
class _CategorySection extends StatelessWidget {
  final AbilityCategory category;
  final List<Ability> abilities;
  final Map<String, Map<int, TextEditingController>> controllers;

  const _CategorySection({
    required this.category,
    required this.abilities,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCategoryColor(category.colorIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 类别标题
        Padding(
          // 性能优化: 添加 const 关键字。
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Icon(
                category.icon,
                size: 20,
                color: color,
              ),
              // 性能优化: 添加 const 关键字。
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
          // 性能优化: 拆分为独立的 StatelessWidget。
          return _AbilityItem(
            ability: ability,
            color: color,
            controllers: controllers[ability.id]!,
          );
        }),

        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 32),
      ],
    );
  }
}

/// 单个能力项 Widget
class _AbilityItem extends StatelessWidget {
  final Ability ability;
  final Color color;
  final Map<int, TextEditingController> controllers;

  const _AbilityItem({
    required this.ability,
    required this.color,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // 性能优化: 添加 const 关键字。
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
            // 性能优化: 添加 const 关键字。
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 10分
                _ScoreField(
                  controller: controllers[10]!,
                  score: 10,
                  label: '10分 - 理想巅峰',
                  color: color,
                  icon: Icons.emoji_events,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 12),
                // 7分
                _ScoreField(
                  controller: controllers[7]!,
                  score: 7,
                  label: '7分 - 优秀水平',
                  color: color,
                  icon: Icons.star,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 12),
                // 5分
                _ScoreField(
                  controller: controllers[5]!,
                  score: 5,
                  label: '5分 - 良好水平',
                  color: color,
                  icon: Icons.thumb_up,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 12),
                // 3分
                _ScoreField(
                  controller: controllers[3]!,
                  score: 3,
                  label: '3分 - 基础水平',
                  color: color,
                  icon: Icons.local_florist,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 分数描述输入框 Widget
class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final int score;
  final String label;
  final Color color;
  final IconData icon;

  const _ScoreField({
    required this.controller,
    required this.score,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            // 性能优化: 添加 const 关键字。
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
        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
}

/// 底部按钮栏 Widget
class _BottomBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _BottomBar({
    required this.isSaving,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : onReset,
                child: const Text('恢复默认'),
              ),
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
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
}
