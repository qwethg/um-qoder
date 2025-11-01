import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';

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
  
  // 选中的类别列表（多选）
  List<AbilityCategory> _selectedCategories = [];
  
  // 选中的能力项列表（多选）
  List<Ability> _selectedAbilities = [];
  
  // 自定义时间范围
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AssessmentProvider, RadarThemeProvider>(
      builder: (context, assessmentProvider, themeProvider, _) {
        final currentTheme = themeProvider.currentTheme;
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
                  _buildAbilitySelector(context, currentTheme),
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
                          '趋势图',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: _buildLineChart(context, assessments, currentTheme),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 统计信息
                _buildStatistics(context, assessments, currentTheme),
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
              runSpacing: 8,
              children: [
                ...TimeRange.values.map((range) {
                  final isSelected = _selectedTimeRange == range && _customDateRange == null;
                  return ChoiceChip(
                    label: Text(_getTimeRangeLabel(range)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTimeRange = range;
                          _customDateRange = null;
                        });
                      }
                    },
                  );
                }),
                // 自定义时间范围
                ChoiceChip(
                  label: Text(_customDateRange == null 
                    ? '自定义' 
                    : '${DateFormat('MM/dd').format(_customDateRange!.start)}-${DateFormat('MM/dd').format(_customDateRange!.end)}'),
                  selected: _customDateRange != null,
                  onSelected: (selected) async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _customDateRange,
                    );
                    if (range != null) {
                      setState(() {
                        _customDateRange = range;
                      });
                    }
                  },
                ),
              ],
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
                          _selectedCategories = [];
                        } else if (dimension == DataDimension.ability) {
                          _selectedAbilities = [];
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择类别（可多选）',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AbilityCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                final color = context.read<RadarThemeProvider>().currentTheme.getCategoryColor(category.colorIndex);
                return FilterChip(
                  label: Text(_getCategoryLabel(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: color.withOpacity(0.3),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            if (_selectedCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '请至少选择一个类别',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilitySelector(BuildContext context, RadarTheme currentTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择能力项（可多选）',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AbilityConstants.abilities.map((ability) {
                final isSelected = _selectedAbilities.contains(ability);
                final color = currentTheme.getCategoryColor(ability.category.colorIndex);
                return FilterChip(
                  label: Text(ability.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAbilities.add(ability);
                      } else {
                        _selectedAbilities.remove(ability);
                      }
                    });
                  },
                  selectedColor: color.withOpacity(0.3),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            if (_selectedAbilities.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '请至少选择一个能力项',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<Assessment> assessments, RadarTheme currentTheme) {
    if (_selectedDimension == DataDimension.ability && _selectedAbilities.isEmpty) {
      return const Center(child: Text('请至少选择一个能力项'));
    }
    if (_selectedDimension == DataDimension.category && _selectedCategories.isEmpty) {
      return const Center(child: Text('请至少选择一个类别'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getHorizontalInterval(),
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
              interval: _getHorizontalInterval(),
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
        lineBarsData: _getLineBarsData(assessments, currentTheme),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: false,
          horizontalLines: _selectedDimension == DataDimension.ability && _selectedAbilities.isNotEmpty
            ? _selectedAbilities.asMap().entries.map((entry) {
                final ability = entry.value;
                final color = currentTheme.getCategoryColor(ability.category.colorIndex);
                final lastScore = assessments.last.scores[ability.id] ?? 0.0;
                
                return HorizontalLine(
                  y: lastScore,
                  color: Colors.transparent,
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (line) => ability.name,
                  ),
                );
              }).toList()
            : _selectedDimension == DataDimension.category && _selectedCategories.isNotEmpty
              ? _selectedCategories.asMap().entries.map((entry) {
                  final category = entry.value;
                  final color = currentTheme.getCategoryColor(category.colorIndex);
                  final abilityIds = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
                  final lastScore = assessments.last.getCategoryScore(abilityIds);
                  
                  return HorizontalLine(
                    y: lastScore,
                    color: Colors.transparent,
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 8, bottom: 2),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => _getCategoryLabel(category),
                    ),
                  );
                }).toList()
              : [],
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
            tooltipBorder: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData(List<Assessment> assessments, RadarTheme currentTheme) {
    if (_selectedDimension == DataDimension.ability) {
      // 多能力项模式
      return _selectedAbilities.map((ability) {
        final spots = assessments.asMap().entries.map((entry) {
          final index = entry.key;
          final assessment = entry.value;
          final score = assessment.scores[ability.id] ?? 0.0;
          return FlSpot(index.toDouble(), score);
        }).toList();
        
        final color = currentTheme.getCategoryColor(ability.category.colorIndex);
        
        return LineChartBarData(
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
            show: false,
          ),
        );
      }).toList();
    } else if (_selectedDimension == DataDimension.category) {
      // 多类别模式
      return _selectedCategories.map((category) {
        final spots = assessments.asMap().entries.map((entry) {
          final index = entry.key;
          final assessment = entry.value;
          final abilityIds = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
          final score = assessment.getCategoryScore(abilityIds);
          return FlSpot(index.toDouble(), score);
        }).toList();
        
        final color = currentTheme.getCategoryColor(category.colorIndex);
        
        return LineChartBarData(
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
            show: false,
          ),
        );
      }).toList();
    } else {
      // 单线模式（总分或类别）
      final spots = assessments.asMap().entries.map((entry) {
        final index = entry.key;
        final assessment = entry.value;
        final score = _getScoreForAssessment(assessment);
        return FlSpot(index.toDouble(), score);
      }).toList();
      
      final color = _getChartColor(currentTheme);
      
      return [
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
      ];
    }
  }

  Widget _buildStatistics(BuildContext context, List<Assessment> assessments, RadarTheme currentTheme) {
    if (_selectedDimension == DataDimension.ability && _selectedAbilities.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  child: _buildStatItem(context, '平均分', avgScore, Icons.analytics, currentTheme.getCategoryColor(0)),
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
    // 自定义时间范围优先
    if (_customDateRange != null) {
      return assessments.where((a) {
        return a.createdAt.isAfter(_customDateRange!.start.subtract(const Duration(days: 1))) &&
               a.createdAt.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

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
      TimeRange.custom => DateTime(2000), // 不会到这里
    };

    return assessments.where((a) => a.createdAt.isAfter(cutoffDate)).toList();
  }

  List<double> _getScores(List<Assessment> assessments) {
    if (_selectedDimension == DataDimension.ability) {
      // 多能力项模式，返回平均值
      return assessments.map((a) {
        if (_selectedAbilities.isEmpty) return 0.0;
        final sum = _selectedAbilities.fold(0.0, (sum, ability) => sum + (a.scores[ability.id] ?? 0.0));
        return sum / _selectedAbilities.length;
      }).toList();
    } else if (_selectedDimension == DataDimension.category) {
      // 多类别模式，返回平均值
      return assessments.map((a) {
        if (_selectedCategories.isEmpty) return 0.0;
        final sum = _selectedCategories.fold(0.0, (sum, category) {
          final abilityIds = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
          return sum + a.getCategoryScore(abilityIds);
        });
        return sum / _selectedCategories.length;
      }).toList();
    }
    return assessments.map((a) => _getScoreForAssessment(a)).toList();
  }

  double _getScoreForAssessment(Assessment assessment) {
    return switch (_selectedDimension) {
      DataDimension.total => assessment.totalScore,
      DataDimension.category => () {
        if (_selectedCategories.isEmpty) return 0.0;
        final sum = _selectedCategories.fold(0.0, (sum, category) {
          final abilityIds = AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
          return sum + assessment.getCategoryScore(abilityIds);
        });
        return sum / _selectedCategories.length;
      }(),
      DataDimension.ability => () {
        if (_selectedAbilities.isEmpty) return 0.0;
        final sum = _selectedAbilities.fold(0.0, (sum, ability) => sum + (assessment.scores[ability.id] ?? 0.0));
        return sum / _selectedAbilities.length;
      }(),
    };
  }

  double _getMaxY() {
    return switch (_selectedDimension) {
      DataDimension.total => 120,
      DataDimension.category => 30,
      DataDimension.ability => 10,
    };
  }

  double _getHorizontalInterval() {
    return switch (_selectedDimension) {
      DataDimension.total => 20,  // 总分：0, 20, 40, 60, 80, 100, 120
      DataDimension.category => 5, // 类别：0, 5, 10, 15, 20, 25, 30
      DataDimension.ability => 2,  // 能力项：0, 2, 4, 6, 8, 10
    };
  }

  Color _getChartColor(RadarTheme currentTheme) {
    return switch (_selectedDimension) {
      DataDimension.total => currentTheme.getCategoryColor(1),
      DataDimension.category => currentTheme.getCategoryColor(
        _selectedCategories.isNotEmpty ? _selectedCategories.first.colorIndex : 0,
      ),
      DataDimension.ability => currentTheme.getCategoryColor(0),
    };
  }

  String _getTimeRangeLabel(TimeRange range) {
    return switch (range) {
      TimeRange.week => '近一周',
      TimeRange.month => '近一月',
      TimeRange.threeMonths => '近三月',
      TimeRange.year => '近一年',
      TimeRange.all => '全部',
      TimeRange.custom => '自定义',
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
  custom, // 新增自定义
}

/// 数据维度枚举
enum DataDimension {
  total,
  category,
  ability,
}
