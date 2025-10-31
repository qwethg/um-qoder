import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/config/theme.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';

/// 趋势分析页面 - 折线图展示评估趋势
class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  // 时间范围选项
  TimeRange _selectedTimeRange = TimeRange.all;
  
  // 数据维度选项
  DataDimension _selectedDimension = DataDimension.total;
  
  // 选中的类别（当维度为category时）
  AbilityCategory? _selectedCategory;
  
  // 选中的能力项（当维度为ability时）
  Ability? _selectedAbility;

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final assessments = _filterAssessmentsByTimeRange(
          assessmentProvider.assessments,
          _selectedTimeRange,
        );

        if (assessments.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('趋势分析')),
            body: _buildEmptyState(context),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('趋势分析'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间范围选择器
                _buildTimeRangeSelector(context),
                const SizedBox(height: 16),

                // 数据维度选择器
                _buildDimensionSelector(context),
                const SizedBox(height: 16),

                // 根据维度显示子选择器
                if (_selectedDimension == DataDimension.category)
                  _buildCategorySelector(context),
                if (_selectedDimension == DataDimension.ability)
                  _buildAbilitySelector(context),
                if (_selectedDimension == DataDimension.category || 
                    _selectedDimension == DataDimension.ability)
                  const SizedBox(height: 16),

                // 折线图
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getChartTitle(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: _buildLineChart(context, assessments),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 统计信息
                _buildStatistics(context, assessments),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '暂无数据',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '选择的时间范围内没有评估记录',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '时间范围',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: TimeRange.values.map((range) {
                final isSelected = _selectedTimeRange == range;
                return ChoiceChip(
                  label: Text(_getTimeRangeLabel(range)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimeRange = range;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据维度',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: DataDimension.values.map((dimension) {
                final isSelected = _selectedDimension == dimension;
                return ChoiceChip(
                  label: Text(_getDimensionLabel(dimension)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDimension = dimension;
                        // 重置子选择器
                        if (dimension == DataDimension.category) {
                          _selectedCategory = AbilityCategory.athleticism;
                        } else if (dimension == DataDimension.ability) {
                          _selectedAbility = AbilityConstants.abilities.first;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<AbilityCategory>(
          decoration: const InputDecoration(
            labelText: '选择类别',
            border: OutlineInputBorder(),
          ),
          value: _selectedCategory ?? AbilityCategory.athleticism,
          items: AbilityCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_getCategoryLabel(category)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAbilitySelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<Ability>(
          decoration: const InputDecoration(
            labelText: '选择能力项',
            border: OutlineInputBorder(),
          ),
          value: _selectedAbility ?? AbilityConstants.abilities.first,
          items: AbilityConstants.abilities.map((ability) {
            return DropdownMenuItem(
              value: ability,
              child: Text('${ability.name} (${_getCategoryLabel(ability.category)})'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAbility = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<Assessment> assessments) {
    final spots = _getDataSpots(assessments);
    
    if (spots.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final color = _getChartColor();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 2,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= assessments.length) {
                  return const Text('');
                }
                final date = assessments[index].createdAt;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        minX: 0,
        maxX: (assessments.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
            tooltipBorder: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= assessments.length) {
                  return null;
                }
                final date = assessments[index].createdAt;
                return LineTooltipItem(
                  '${DateFormat('yyyy-MM-dd').format(date)}\n${spot.y.toStringAsFixed(1)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, List<Assessment> assessments) {
    final scores = _getScores(assessments);
    
    if (scores.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final latestScore = scores.last;
    final firstScore = scores.first;
    final totalChange = latestScore - firstScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '统计信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(context, '最高分', maxScore, Icons.arrow_upward, Colors.green),
                ),
                Expanded(
                  child: _buildStatItem(context, '最低分', minScore, Icons.arrow_downward, Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(context, '平均分', avgScore, Icons.analytics, AppTheme.lightPrimary),
                ),
                Expanded(
                  child: _buildStatItem(
                    context, 
                    '总变化', 
                    totalChange, 
                    totalChange >= 0 ? Icons.trending_up : Icons.trending_down,
                    totalChange >= 0 ? Colors.green : Colors.red,
                    showSign: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color, {
    bool showSign = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            showSign && value >= 0 ? '+${value.toStringAsFixed(1)}' : value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Assessment> _filterAssessmentsByTimeRange(
    List<Assessment> assessments,
    TimeRange range,
  ) {
    if (range == TimeRange.all) {
      return assessments;
    }

    final now = DateTime.now();
    final cutoffDate = switch (range) {
      TimeRange.week => now.subtract(const Duration(days: 7)),
      TimeRange.month => DateTime(now.year, now.month - 1, now.day),
      TimeRange.threeMonths => DateTime(now.year, now.month - 3, now.day),
      TimeRange.year => DateTime(now.year - 1, now.month, now.day),
      TimeRange.all => DateTime(2000),
    };

    return assessments.where((a) => a.createdAt.isAfter(cutoffDate)).toList();
  }

  List<FlSpot> _getDataSpots(List<Assessment> assessments) {
    return assessments.asMap().entries.map((entry) {
      final index = entry.key;
      final assessment = entry.value;
      final score = _getScoreForAssessment(assessment);
      return FlSpot(index.toDouble(), score);
    }).toList();
  }

  List<double> _getScores(List<Assessment> assessments) {
    return assessments.map((a) => _getScoreForAssessment(a)).toList();
  }

  double _getScoreForAssessment(Assessment assessment) {
    return switch (_selectedDimension) {
      DataDimension.total => assessment.totalScore,
      DataDimension.category => () {
        final abilityIds = AbilityConstants.getAbilitiesByCategory(
          _selectedCategory ?? AbilityCategory.athleticism,
        ).map((a) => a.id).toList();
        return assessment.getCategoryScore(abilityIds);
      }(),
      DataDimension.ability => assessment.scores[
        (_selectedAbility ?? AbilityConstants.abilities.first).id
      ] ?? 0.0,
    };
  }

  double _getMaxY() {
    return switch (_selectedDimension) {
      DataDimension.total => 120,
      DataDimension.category => 30,
      DataDimension.ability => 10,
    };
  }

  Color _getChartColor() {
    return switch (_selectedDimension) {
      DataDimension.total => AppTheme.lightSecondary,
      DataDimension.category => AppTheme.getCategoryColor(
        (_selectedCategory ?? AbilityCategory.athleticism).colorIndex,
      ),
      DataDimension.ability => AppTheme.getCategoryColor(
        (_selectedAbility ?? AbilityConstants.abilities.first).category.colorIndex,
      ),
    };
  }

  String _getChartTitle() {
    return switch (_selectedDimension) {
      DataDimension.total => '总分趋势',
      DataDimension.category => '${_getCategoryLabel(_selectedCategory ?? AbilityCategory.athleticism)}类别趋势',
      DataDimension.ability => '${(_selectedAbility ?? AbilityConstants.abilities.first).name}趋势',
    };
  }

  String _getTimeRangeLabel(TimeRange range) {
    return switch (range) {
      TimeRange.week => '近一周',
      TimeRange.month => '近一月',
      TimeRange.threeMonths => '近三月',
      TimeRange.year => '近一年',
      TimeRange.all => '全部',
    };
  }

  String _getDimensionLabel(DataDimension dimension) {
    return switch (dimension) {
      DataDimension.total => '总分',
      DataDimension.category => '类别',
      DataDimension.ability => '能力项',
    };
  }

  String _getCategoryLabel(AbilityCategory category) {
    return switch (category) {
      AbilityCategory.athleticism => '身体',
      AbilityCategory.awareness => '意识',
      AbilityCategory.technique => '技术',
      AbilityCategory.mind => '心灵',
    };
  }
}

/// 时间范围枚举
enum TimeRange {
  week,
  month,
  threeMonths,
  year,
  all,
}

/// 数据维度枚举
enum DataDimension {
  total,
  category,
  ability,
}
