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
      
      // 获取上一次评估记录（用于对比）
      final allAssessments = assessmentProvider.assessments;
      final currentIndex = allAssessments.indexWhere((a) => a.id == widget.assessment.id);
      final previousAssessment = currentIndex < allAssessments.length - 1
          ? allAssessments[currentIndex + 1]
          : null;

      final aiService = AiService();
      final analysisContent = await aiService.generateAnalysis(
        currentAssessment: widget.assessment,
        userGoalSettings: goalSettings,
        previousAssessment: previousAssessment,
        apiKey: prefsProvider.apiKey,
      );
      
      // 提取摘要
      final summary = _extractSummaryFromReport(analysisContent);
      
      // 创建更新后的评估对象
      final updatedAssessment = widget.assessment.copyWith(
        aiAnalysisContent: analysisContent,
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
    final hasAnalysis = widget.assessment.aiAnalysisContent != null;
    
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
          // 头部区域
          InkWell(
            onTap: hasAnalysis && !_isGenerating ? _toggleExpanded : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // AI 图标
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
                  
                  // 标题和状态
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
                        if (_isGenerating)
                          const Text(
                            'AI 教练分析中...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          )
                        else if (hasAnalysis)
                          Text(
                            widget.assessment.aiAnalysisSummary ?? '点击展开查看详细分析',
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
                  
                  // 右侧图标
                  if (_isGenerating)
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
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 展开的内容区域
          if (hasAnalysis)
            SizeTransition(
              sizeFactor: _expandAnimation,
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
                        data: widget.assessment.aiAnalysisContent!,
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
            ),
          
          // 生成按钮（仅在未生成时显示）
          if (!hasAnalysis && !_isGenerating)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateAiAnalysis,
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
            ),
        ],
      ),
    );
  }
}