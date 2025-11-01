import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/services/share_service.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';
import 'package:ultimate_wheel/config/constants.dart';

/// 雷达图对比页面 - 对比两个评估记录
class ComparisonScreen extends StatefulWidget {
  final String latestAssessmentId;
  final String? selectedAssessmentId;

  const ComparisonScreen({
    super.key,
    required this.latestAssessmentId,
    this.selectedAssessmentId,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String? _selectedAssessmentId;
  final _screenshotController = ScreenshotController();
  final _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _selectedAssessmentId = widget.selectedAssessmentId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssessmentProvider, RadarThemeProvider>(
      builder: (context, assessmentProvider, themeProvider, _) {
        final currentTheme = themeProvider.currentTheme;
        final latestAssessment = assessmentProvider.getAssessmentById(widget.latestAssessmentId);
        final selectedAssessment = _selectedAssessmentId != null 
            ? assessmentProvider.getAssessmentById(_selectedAssessmentId!)
            : null;

        if (latestAssessment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('评估对比')),
            body: const Center(child: Text('未找到评估记录')),
          );
        }

        // 获取所有历史记录（排除最新的）
        final historicalAssessments = assessmentProvider.assessments
            .where((a) => a.id != widget.latestAssessmentId)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('评估对比'),
            actions: [
              if (selectedAssessment != null)
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _shareComparison(
                    context,
                    latestAssessment,
                    selectedAssessment,
                  ),
                  tooltip: '分享',
                ),
            ],
          ),
          body: Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 选择对比记录
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '选择对比记录',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 最新记录（固定）
                        _buildAssessmentChip(
                          context, 
                          latestAssessment, 
                          '最新记录',
                          PresetRadarThemes.defaultTheme.getCategoryColor(1).withOpacity(0.5),
                          isSelected: true,
                        ),
                        const SizedBox(height: 12),
                        
                        // 对比记录选择器
                        if (historicalAssessments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                '暂无历史记录可对比',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: '选择历史记录',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.history),
                            ),
                            initialValue: _selectedAssessmentId,
                            hint: const Text('请选择一条历史记录'),
                            items: historicalAssessments.map((assessment) {
                              return DropdownMenuItem(
                                value: assessment.id,
                                child: Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt)} (${assessment.totalScore.toStringAsFixed(1)}分)',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAssessmentId = value;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 对比结果
                if (selectedAssessment != null) ...[
                  // 叠加雷达图
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '雷达图对比',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 历史记录（底层，半透明）
                              Opacity(
                                opacity: 0.5,
                                child: UltimateWheelRadarChart(
                                  scores: selectedAssessment.scores,
                                  size: MediaQuery.of(context).size.width - 64,
                                  radarTheme: currentTheme,
                                ),
                              ),
                              // 最新记录（顶层，半透明）
                              Opacity(
                                opacity: 0.7,
                                child: UltimateWheelRadarChart(
                                  scores: latestAssessment.scores,
                                  size: MediaQuery.of(context).size.width - 64,
                                  radarTheme: currentTheme,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegend(context, '历史记录', currentTheme.getCategoryColor(0).withOpacity(0.5)),
                              const SizedBox(width: 24),
                              _buildLegend(context, '最新记录', currentTheme.getCategoryColor(1).withOpacity(0.7)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 总分对比
                  _buildScoreComparisonCard(
                    context,
                    '总分',
                    latestAssessment.totalScore,
                    selectedAssessment.totalScore,
                  ),
                  const SizedBox(height: 16),

                  // 各类别对比
                  _buildCategoryComparison(
                    context,
                    latestAssessment,
                    selectedAssessment,
                    currentTheme,
                  ),
                  const SizedBox(height: 16),

                  // 详细差异
                  _buildDetailedDifference(
                    context,
                    latestAssessment,
                    selectedAssessment,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      );
    },
  );
}

  Future<void> _shareComparison(
    BuildContext context,
    latestAssessment,
    selectedAssessment,
  ) async {
    if (latestAssessment == null || selectedAssessment == null) return;

    final difference = latestAssessment.totalScore - selectedAssessment.totalScore;

    await _shareService.shareComparison(
      context: context,
      screenshotController: _screenshotController,
      latestDate: DateFormat('yyyy-MM-dd').format(latestAssessment.createdAt),
      historicalDate: DateFormat('yyyy-MM-dd').format(selectedAssessment.createdAt),
      scoreDifference: difference,
    );
  }

  Widget _buildAssessmentChip(
    BuildContext context,
    Assessment assessment,
    String label,
    Color color, {
    bool isSelected = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            assessment.totalScore.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildScoreComparisonCard(
    BuildContext context,
    String title,
    double latestScore,
    double historicalScore,
  ) {
    final difference = latestScore - historicalScore;
    final isImproved = difference > 0;
    final diffColor = isImproved ? Colors.green : (difference < 0 ? Colors.red : Colors.grey);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '最新',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PresetRadarThemes.defaultTheme.getCategoryColor(1),
                      ),
                    ),
                  ],
                ),
                Icon(
                  isImproved ? Icons.arrow_upward : (difference < 0 ? Icons.arrow_downward : Icons.remove),
                  color: diffColor,
                  size: 32,
                ),
                Column(
                  children: [
                    Text(
                      '历史',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      historicalScore.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PresetRadarThemes.defaultTheme.getCategoryColor(0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              difference == 0
                  ? '无变化'
                  : '${isImproved ? '+' : ''}${difference.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: diffColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    Assessment latestAssessment,
    Assessment selectedAssessment,
    RadarTheme currentTheme,
  ) {
    final categories = [
      ('身体', AbilityCategory.athleticism, 0),
      ('意识', AbilityCategory.awareness, 1),
      ('技术', AbilityCategory.technique, 2),
      ('心灵', AbilityCategory.mind, 3),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '类别对比',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              final categoryName = category.$1;
              final categoryEnum = category.$2;
              final colorIndex = category.$3;
              
              final abilityIds = AbilityConstants.getAbilitiesByCategory(categoryEnum)
                  .map((a) => a.id).toList();
              
              final latestScore = latestAssessment.getCategoryScore(abilityIds);
              final historicalScore = selectedAssessment.getCategoryScore(abilityIds);
              final difference = latestScore - historicalScore;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCategoryComparisonRow(
                  context,
                  categoryName,
                  latestScore,
                  historicalScore,
                  difference,
                  colorIndex,
                  currentTheme,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryComparisonRow(
    BuildContext context,
    String categoryName,
    double latestScore,
    double historicalScore,
    double difference,
    int colorIndex,
    RadarTheme currentTheme,
  ) {
    final color = currentTheme.getCategoryColor(colorIndex);
    final isImproved = difference > 0;
    final diffColor = isImproved ? Colors.green : (difference < 0 ? Colors.red : Colors.grey);

    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: latestScore / 30.0,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 35,
                child: Text(
                  latestScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Row(
            children: [
              Icon(
                isImproved ? Icons.arrow_upward : (difference < 0 ? Icons.arrow_downward : Icons.remove),
                color: diffColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                difference == 0 ? '0.0' : '${isImproved ? '+' : ''}${difference.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedDifference(
    BuildContext context,
    Assessment latestAssessment,
    Assessment selectedAssessment,
  ) {
    // 计算每个能力项的差异
    final abilities = AbilityConstants.abilities;
    final differences = abilities.map((ability) {
      final latestScore = latestAssessment.scores[ability.id] ?? 0.0;
      final historicalScore = selectedAssessment.scores[ability.id] ?? 0.0;
      final diff = latestScore - historicalScore;
      return (ability: ability, difference: diff);
    }).toList();

    // 找出进步最大和退步最大的
    differences.sort((a, b) => b.difference.compareTo(a.difference));
    final mostImproved = differences.where((d) => d.difference > 0).take(3).toList();
    final mostDeclined = differences.where((d) => d.difference < 0).toList();
    mostDeclined.sort((a, b) => a.difference.compareTo(b.difference));
    final topDeclined = mostDeclined.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细变化',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (mostImproved.isNotEmpty) ...[
              Text(
                '进步最大 💪',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...mostImproved.map((item) => _buildDifferenceItem(
                context,
                item.ability.name,
                item.difference,
                PresetRadarThemes.defaultTheme.getCategoryColor(item.ability.category.colorIndex),
              )),
              const SizedBox(height: 16),
            ],
            
            if (topDeclined.isNotEmpty) ...[
              Text(
                '需要关注 🤔',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...topDeclined.map((item) => _buildDifferenceItem(
                context,
                item.ability.name,
                item.difference,
                PresetRadarThemes.defaultTheme.getCategoryColor(item.ability.category.colorIndex),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifferenceItem(
    BuildContext context,
    String abilityName,
    double difference,
    Color color,
  ) {
    final isImproved = difference > 0;
    final diffColor = isImproved ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              abilityName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Row(
            children: [
              Icon(
                isImproved ? Icons.arrow_upward : Icons.arrow_downward,
                color: diffColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${isImproved ? '+' : ''}${difference.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
