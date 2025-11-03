import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_wheel/config/theme.dart';
import '../../providers/assessment_provider.dart';

/// 评估中心 (03)
class AssessmentHubScreen extends StatelessWidget {
  const AssessmentHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评估中心'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 剩余评估次数显示
            Consumer<AssessmentProvider>(
              builder: (context, assessmentProvider, child) {
                final remainingCount = assessmentProvider.remainingAssessments;
                final hasReachedLimit = assessmentProvider.hasReachedLimit;
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: hasReachedLimit 
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasReachedLimit 
                          ? Colors.red.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasReachedLimit ? Icons.warning : Icons.assessment,
                        color: hasReachedLimit ? Colors.red : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasReachedLimit ? '评估次数已用完' : '剩余评估次数',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: hasReachedLimit ? Colors.red : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasReachedLimit 
                                  ? '已达到最大评估次数限制（20次）'
                                  : '$remainingCount / 20',
                              style: TextStyle(
                                fontSize: 12,
                                color: (hasReachedLimit ? Colors.red : Colors.blue).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // 目标设定
            _AssessmentCard(
              icon: Icons.flag,
              title: '目标设定',
              description: '定义你的巅峰：描绘你心中10分的样子',
              color: AppTheme.lightPrimary,        // 雾霾蓝
              onTap: () => context.go('/assessment/goal-setting'),
            ),
            const SizedBox(height: 16),
            
            // 深度评估
            Consumer<AssessmentProvider>(
              builder: (context, assessmentProvider, child) {
                return _AssessmentCard(
                  icon: Icons.self_improvement,
                  title: '深度评估',
                  description: '沉浸式体验：一次与自己对话的完整仪式',
                  color: AppTheme.lightSecondary,      // 珊瑚粉
                  onTap: assessmentProvider.hasReachedLimit 
                      ? () => _showLimitReachedDialog(context)
                      : () => context.go('/assessment/deep'),
                  isDisabled: assessmentProvider.hasReachedLimit,
                );
              },
            ),
            const SizedBox(height: 16),
            
            // 快速评估
            Consumer<AssessmentProvider>(
              builder: (context, assessmentProvider, child) {
                return _AssessmentCard(
                  icon: Icons.speed,
                  title: '快速评估',
                  description: '快速更新：用5分钟追踪你的即时状态',
                  color: const Color(0xFFE8D4A9),      // 中间色调
                  onTap: assessmentProvider.hasReachedLimit 
                      ? () => _showLimitReachedDialog(context)
                      : () => context.go('/assessment/quick'),
                  isDisabled: assessmentProvider.hasReachedLimit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示达到限制的对话框
  void _showLimitReachedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('评估次数已用完'),
        content: const Text('您已达到最大评估次数限制（20次）。如需继续评估，请联系管理员或等待重置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 评估卡片组件
class _AssessmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isDisabled;

  const _AssessmentCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? Colors.grey : color;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                effectiveColor.withOpacity(isDisabled ? 0.05 : 0.1),
                effectiveColor.withOpacity(isDisabled ? 0.02 : 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // 图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(isDisabled ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 32,
                  color: effectiveColor,
                ),
              ),
              const SizedBox(width: 16),
              
              // 文字内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDisabled 
                            ? Colors.grey.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 箭头或禁用图标
              Icon(
                isDisabled ? Icons.block : Icons.arrow_forward_ios,
                color: effectiveColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
