import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/assessment.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../providers/preferences_provider.dart';
import '../providers/goal_setting_provider.dart';
import '../providers/assessment_provider.dart';
import '../models/goal_setting.dart';
import '../config/constants.dart';
import 'package:ultimate_wheel/providers/settings_provider.dart';
import '../models/ai_report.dart';

/// AI 分析结果显示组件
/// 支持三种状态：未生成、生成中、已生成
class AiAnalysisSection extends StatefulWidget {
  final Assessment assessment;
  final Function(Assessment) onAssessmentUpdated;

  const AiAnalysisSection({
    Key? key,
    required this.assessment,
    required this.onAssessmentUpdated,
  }) : super(key: key);

  @override
  State<AiAnalysisSection> createState() => _AiAnalysisSectionState();
}

class _AiAnalysisSectionState extends State<AiAnalysisSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isGenerating = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 从完整报告中提取总体评价作为摘要
  String _extractSummaryFromReport(String fullReport) {
    final lines = fullReport.split('\n');
    bool foundOverallSection = false;
    final summaryLines = <String>[];

    for (final line in lines) {
      if (line.contains('## 📊 总体评价') || line.contains('总体评价')) {
        foundOverallSection = true;
        continue;
      }

      if (foundOverallSection) {
        if (line.startsWith('##') && !line.contains('总体评价')) {
          // 遇到下一个章节，停止提取
          break;
        }

        if (line.trim().isNotEmpty) {
          summaryLines.add(line.trim());
          // 提取前2-3句话作为摘要
          if (summaryLines.length >= 3) {
            break;
          }
        }
      }
    }

    return summaryLines.join(' ').trim();
  }

  /// 生成 AI 分析报告
  Future<void> _generateAiAnalysis() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // 获取必要的 Provider
      final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
      final goalProvider = Provider.of<GoalSettingProvider>(context, listen: false);
      final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      // 检查 API Key
      if (prefsProvider.apiKey.isEmpty) {
        throw Exception('请先在设置中配置 API Key');
      }

      // 获取用户目标设定
      final goalSettings = <String, GoalSetting>{};
      for (final ability in AbilityConstants.abilities) {
        final setting = goalProvider.getGoalSetting(ability.id);
        if (setting != null) {
          goalSettings[ability.id] = setting;
        }
      }

      final aiService = AiService(storageService, settingsProvider, apiKey: prefsProvider.apiKey);
      final reportStream = aiService.generateReport(
        assessment: widget.assessment,
        goalSettings: goalSettings,
      );

      String finalContent = '';
      await for (final report in reportStream) {
        if (mounted) {
          setState(() {
            // 在流式传输期间更新内容
            if (report.status == AiReportStatus.generating) {
              finalContent = report.content ?? '';
              final updatedAssessment = widget.assessment.copyWith(
                aiAnalysisContent: finalContent,
              );
              widget.onAssessmentUpdated(updatedAssessment);
            }
          });
        }

        if (report.status == AiReportStatus.completed) {
          finalContent = report.content ?? '';
        } else if (report.status == AiReportStatus.failed) {
          // 失败时，直接抛出包含具体错误信息的异常
          throw Exception(report.error ?? '生成 AI 分析时发生未知错误');
        }
      }

      // 提取摘要
      final summary = _extractSummaryFromReport(finalContent);

      // 创建更新后的评估对象
      final updatedAssessment = widget.assessment.copyWith(
        aiAnalysisContent: finalContent,
        aiAnalysisGeneratedAt: DateTime.now(),
        aiAnalysisSummary: summary,
      );

      // 通知父组件更新
      widget.onAssessmentUpdated(updatedAssessment);
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成 AI 分析失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  /// 切换展开/折叠状态
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = widget.assessment.aiAnalysisContent != null &&
        widget.assessment.aiAnalysisContent!.trim().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _HeaderSection(
            isGenerating: _isGenerating,
            hasAnalysis: hasAnalysis,
            isExpanded: _isExpanded,
            assessment: widget.assessment,
            onToggleExpanded: _toggleExpanded,
          ),
          
          // 展开的内容区域
          if (hasAnalysis)
            _ExpandedContentSection(
              expandAnimation: _expandAnimation,
              analysisContent: widget.assessment.aiAnalysisContent!,
            ),
          
          // 生成按钮（仅在未生成时显示）
          if (!hasAnalysis && !_isGenerating)
            _GenerateButton(onPressed: _generateAiAnalysis),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isGenerating;
  final bool hasAnalysis;
  final bool isExpanded;
  final Assessment assessment;
  final VoidCallback onToggleExpanded;

  const _HeaderSection({
    required this.isGenerating,
    required this.hasAnalysis,
    required this.isExpanded,
    required this.assessment,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hasAnalysis && !isGenerating ? onToggleExpanded : null,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI 智能分析',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isGenerating)
                    const Text(
                      'AI 教练分析中...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    )
                  else if (hasAnalysis)
                    Text(
                      assessment.aiAnalysisSummary ?? '点击展开查看详细分析',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    const Text(
                      '点击下方按钮，获取 AI 教练为您生成的专业分析报告',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (isGenerating)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            else if (hasAnalysis)
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedContentSection extends StatelessWidget {
  final Animation<double> expandAnimation;
  final String analysisContent;

  const _ExpandedContentSection({
    required this.expandAnimation,
    required this.analysisContent,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: expandAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: MarkdownBody(
                data: analysisContent,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  h2: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  h3: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GenerateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.psychology, size: 18),
        label: const Text('获取 AI 智能分析'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}