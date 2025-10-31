import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/goal_setting_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 深度评估页 (03-2)
class DeepAssessmentScreen extends StatefulWidget {
  const DeepAssessmentScreen({super.key});

  @override
  State<DeepAssessmentScreen> createState() => _DeepAssessmentScreenState();
}

class _DeepAssessmentScreenState extends State<DeepAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showWelcome = true;
  
  // 存储每个能力的评分和笔记
  final Map<String, double> _scores = {};
  final Map<String, String> _notes = {};
  final Map<String, TextEditingController> _noteControllers = {};
  
  bool _isSaving = false;

  // 4个类别
  final List<AbilityCategory> _categories = AbilityCategory.values;

  @override
  void initState() {
    super.initState();
    // 初始化所有能力的分数为0
    for (final ability in AbilityConstants.abilities) {
      _scores[ability.id] = 0.0;
      _notes[ability.id] = '';
      _noteControllers[ability.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome) {
      return _buildWelcomeScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_categories[_currentPage].emoji} ${_categories[_currentPage].name}'),
        actions: [
          // 进度指示
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentPage + 1}/${_categories.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GoalSettingProvider>(
        builder: (context, goalProvider, _) {
          return PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // 禁止滑动，只能通过按钮切换
            itemCount: _categories.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildCategoryPage(
                context,
                _categories[index],
                goalProvider,
              );
            },
          );
        },
      ),
    );
  }

  /// 构建欢迎屏幕
  Widget _buildWelcomeScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🧘',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 32),
              Text(
                '深度评估',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '这是一次与自己深度对话的完整仪式',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildPhilosophyCard(
                context,
                '💭',
                '内向型评估',
                '评分的基准不是外部的“职业选手”，\n而是自己内心期望达到的最佳状态',
              ),
              const SizedBox(height: 16),
              _buildPhilosophyCard(
                context,
                '🎯',
                '满意度驱动',
                '分数代表满意度，衡量的是\n现状与目标的差距',
              ),
              const SizedBox(height: 16),
              _buildPhilosophyCard(
                context,
                '🌱',
                '过程即仪式',
                '花 15-20 分钟，沉浸在这个\n专注而温柔的时刻',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _showWelcome = false;
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('开始评估'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhilosophyCard(BuildContext context, String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建类别评估页面
  Widget _buildCategoryPage(
    BuildContext context,
    AbilityCategory category,
    GoalSettingProvider goalProvider,
  ) {
    final abilities = AbilityConstants.getAbilitiesByCategory(category);
    final color = AppTheme.getCategoryColor(category.colorIndex);
    final isLastCategory = _currentPage == _categories.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类别介绍
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请为以下 ${abilities.length} 项能力进行评分',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 能力项列表
          ...abilities.map((ability) {
            return _buildAbilityAssessmentCard(
              context,
              ability,
              color,
              goalProvider,
            );
          }).toList(),

          const SizedBox(height: 24),

          // 导航按钮
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: Text(_categories[_currentPage - 1].name),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isLastCategory ? _handleComplete : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(isLastCategory ? Icons.check : Icons.arrow_forward),
                  label: Text(isLastCategory ? '完成评估' : _categories[_currentPage + 1].name),
                ),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 构建单个能力评估卡片
  Widget _buildAbilityAssessmentCard(
    BuildContext context,
    Ability ability,
    Color color,
    GoalSettingProvider goalProvider,
  ) {
    final currentScore = _scores[ability.id] ?? 0.0;
    final showDescription = currentScore == 3.0 || 
                           currentScore == 5.0 || 
                           currentScore == 7.0 ||
                           currentScore == 10.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 能力信息
            Row(
              children: [
                Text(
                  ability.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ability.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ability.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 分数显示
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 滑块
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: currentScore,
                min: 0,
                max: 10,
                divisions: 20,
                label: currentScore.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _scores[ability.id] = value;
                  });
                  
                  // 移动端震动反馈
                  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                    if (value == 3.0 || value == 5.0 || value == 7.0 || value == 10.0) {
                      HapticFeedback.lightImpact();
                    }
                  }
                },
              ),
            ),

            // 显示描述
            if (showDescription)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goalProvider.getDescription(
                          ability.id,
                          currentScore.toInt(),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 笔记输入框
            TextField(
              controller: _noteControllers[ability.id],
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: '记录你的思考（可选）',
                hintText: '我还欠缺什么？我与理想的差距在哪里？',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: color.withOpacity(0.05),
              ),
              onChanged: (value) {
                _notes[ability.id] = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 处理完成评估
  Future<void> _handleComplete() async {
    // 检查是否有未评分的项目
    final hasUnscored = _scores.values.any((score) => score == 0.0);
    if (hasUnscored) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('还有未评分的项目，确定要继续吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('继续'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 创建评估记录
      final assessment = Assessment(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        type: AssessmentType.deep,
        scores: Map.from(_scores),
        notes: Map.from(_notes),
      );

      // 保存评估
      if (mounted) {
        await Provider.of<AssessmentProvider>(context, listen: false)
            .saveAssessment(assessment);

        // 跳转到结果页
        if (mounted) {
          context.go('/assessment/result/${assessment.id}');
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
