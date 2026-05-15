import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ultimate_wheel/config/constants.dart';
import 'package:ultimate_wheel/models/ability.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/radar_theme.dart';
import 'package:ultimate_wheel/providers/assessment_provider.dart';
import 'package:ultimate_wheel/providers/radar_theme_provider.dart';
import 'package:ultimate_wheel/services/share_service.dart';
import 'package:ultimate_wheel/widgets/ai_analysis_section.dart';
import 'package:ultimate_wheel/widgets/radar_theme_preview.dart';
import 'package:ultimate_wheel/widgets/ultimate_wheel_radar_chart.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:async';

// 性能优化: 将原 StatefulWidget 拆分为 StatelessWidget，仅负责获取数据。
class AssessmentResultScreen extends StatelessWidget {
  final String assessmentId;

  const AssessmentResultScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    // 性能优化: 使用 Selector 精准监听 assessment 对象，避免因 Provider 其他数据变化导致重建。
    return Selector<AssessmentProvider, Assessment?>(
      selector: (_, provider) => provider.getAssessmentById(assessmentId),
      builder: (context, assessment, _) {
        if (assessment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('评估结果')),
            // 性能优化: 添加 const 关键字。
            body: const Center(
              child: Text('未找到评估记录'),
            ),
          );
        }
        // 性能优化: 将包含状态和复杂UI的部分拆分为独立的 StatefulWidget。
        return _ResultContent(assessment: assessment);
      },
    );
  }
}

/// 承载结果页主要内容和状态的内部 Widget
class _ResultContent extends StatefulWidget {
  final Assessment assessment;

  const _ResultContent({required this.assessment});

  @override
  State<_ResultContent> createState() => _ResultContentState();
}

class _ResultContentState extends State<_ResultContent> {
  final _screenshotController = ScreenshotController();
  final _shareService = ShareService();
  RadarTheme? _previewTheme; // 用于分享预览的临时主题

  // BUG修复: 添加了缺失的 dispose() 调用，防止内存泄漏。
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 将主题的获取也放在这里，以便分享功能可以影响它
    final themeProvider = context.watch<RadarThemeProvider>();
    final currentTheme = _previewTheme ?? themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('评估结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _showShareThemeSelector(context, themeProvider),
            tooltip: '分享',
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            // 性能优化: 添加 const 关键字。
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CongratulationsSection(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 32),
                _RadarChartCard(
                  assessment: widget.assessment,
                  theme: currentTheme,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                AiAnalysisSection(
                  assessment: widget.assessment,
                  onAssessmentUpdated: (updatedAssessment) {
                    // 性能优化: 在事件处理器中使用 context.read()，避免 Widget 重建。
                    context
                        .read<AssessmentProvider>()
                        .updateAssessment(updatedAssessment);
                  },
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _TotalScoreCard(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _CategoryDetailGrid(
                  assessment: widget.assessment,
                  theme: currentTheme,
                ),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                _DetailedScoresExpansionTile(assessment: widget.assessment),
                // 性能优化: 添加 const 关键字。
                const SizedBox(height: 24),
                const _ActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 显示主题选择器并处理分享逻辑
  Future<void> _showShareThemeSelector(
      BuildContext context, RadarThemeProvider themeProvider) async {
    final selectedTheme = await showModalBottomSheet<RadarTheme?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ShareThemeSelectorSheet(
        currentTheme: _previewTheme ?? themeProvider.currentTheme,
        allThemes: themeProvider.allThemes,
        assessment: widget.assessment,
        onThemeChanged: (theme) {
          setState(() => _previewTheme = theme);
        },
      ),
    );

    if (selectedTheme != null) {}

    // 重置预览主题，避免影响主页面的主题显示
    if (mounted) {
      setState(() => _previewTheme = null);
    }
  }

  /// 处理分享操作
  Future<void> _handleShare() async {
    await _shareService.shareAssessment(
      context: context,
      screenshotController: _screenshotController,
      assessmentDate:
          DateFormat('yyyy-MM-dd HH:mm').format(widget.assessment.createdAt),
      totalScore: widget.assessment.totalScore,
    );
  }
}

// --- 以下是将 UI 拆分为的独立 StatelessWidget ---

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _CongratulationsSection extends StatelessWidget {
  final Assessment assessment;
  const _CongratulationsSection({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.celebration,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 16),
          Text(
            '恭喜，完成了本次评估',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 8),
          Text(
            '评估不代表你的全部，只代表此刻的你对自己的认知',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          // 性能优化: 添加 const 关键字。
          const SizedBox(height: 8),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(assessment.createdAt),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _RadarChartCard extends StatelessWidget {
  final Assessment assessment;
  final RadarTheme theme;

  const _RadarChartCard({required this.assessment, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: UltimateWheelRadarChart(
          scores: assessment.scores,
          size: MediaQuery.of(context).size.width - 80,
          radarTheme: theme,
        ),
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _TotalScoreCard extends StatelessWidget {
  final Assessment assessment;
  const _TotalScoreCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '总分',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              assessment.totalScore.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _CategoryDetailGrid extends StatelessWidget {
  final Assessment assessment;
  final RadarTheme theme;

  const _CategoryDetailGrid({required this.assessment, required this.theme});

  @override
  Widget build(BuildContext context) {
    final categories = AbilityCategory.values;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[0], // 身体
                  theme: theme,
                ),
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[2], // 技术
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
        // 性能优化: 添加 const 关键字。
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[1], // 意识
                  theme: theme,
                ),
              ),
              // 性能优化: 添加 const 关键字。
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDetailCard(
                  assessment: assessment,
                  category: categories[3], // 心灵
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 性能优化: 将 _buildCategoryDetailCard 方法重构为独立的 StatelessWidget。
class _CategoryDetailCard extends StatelessWidget {
  final Assessment assessment;
  final AbilityCategory category;
  final RadarTheme theme;

  const _CategoryDetailCard({
    required this.assessment,
    required this.category,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final abilityIds =
        AbilityConstants.getAbilitiesByCategory(category).map((a) => a.id).toList();
    final categoryScore = assessment.getCategoryScore(abilityIds);
    final color = theme.getCategoryColor(category.colorIndex);
    final gradient = theme.getCategoryGradient(category.colorIndex);
    final abilities = AbilityConstants.abilities
        .where((a) => abilityIds.contains(a.id))
        .toList();

    return Card(
      child: Padding(
        // 性能优化: 添加 const 关键字。
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  categoryScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            // 性能优化: 添加 const 关键字。
            const SizedBox(height: 12),
            ...abilities.asMap().entries.map((entry) {
              final index = entry.key;
              final ability = entry.value;
              final score = assessment.scores[ability.id] ?? 0.0;
              final hueShift = (index / abilities.length) * 0.15 - 0.075;
              final itemColor = _adjustColorHue(gradient.last, hueShift);
              final isLast = index == abilities.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        ability.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: itemColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 性能优化: 添加 const 关键字。
                    const SizedBox(width: 6),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: score / 10.0,
                        backgroundColor: itemColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // 性能优化: 添加 const 关键字。
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 32,
                      child: Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: itemColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _adjustColorHue(Color color, double hueShift) {
    final hslColor = HSLColor.fromColor(color);
    final newHue = (hslColor.hue + hueShift * 360) % 360;
    return hslColor.withHue(newHue).toColor();
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _DetailedScoresExpansionTile extends StatelessWidget {
  final Assessment assessment;

  const _DetailedScoresExpansionTile({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            '详细分数',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          children: AbilityConstants.abilities.map((ability) {
            final score = assessment.scores[ability.id] ?? 0.0;
            return _AbilityScoreItem(ability: ability, score: score);
          }).toList(),
        ),
      ),
    );
  }
}

class _AbilityScoreItem extends StatelessWidget {
  final Ability ability;
  final double score;

  const _AbilityScoreItem({required this.ability, required this.score});

  @override
  Widget build(BuildContext context) {
    final color =
        PresetRadarThemes.defaultTheme.getCategoryColor(ability.category.colorIndex);

    return ListTile(
      leading: Icon(
        ability.icon,
        size: 24,
        color: color,
      ),
      title: Text(ability.name),
      subtitle: Text(
        ability.description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          score.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ),
    );
  }
}

/// 性能优化: 拆分为独立的 StatelessWidget，隔离重建范围。
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/history'),
            // 性能优化: 添加 const 关键字。
            icon: const Icon(Icons.history),
            label: const Text('查看历史'),
          ),
        ),
        // 性能优化: 添加 const 关键字。
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.go('/home'),
            // 性能优化: 添加 const 关键字。
            icon: const Icon(Icons.home),
            label: const Text('回到首页'),
          ),
        ),
      ],
    );
  }
}

/// 分享主题选择器 Sheet
class _ShareThemeSelectorSheet extends StatefulWidget {
  final RadarTheme currentTheme;
  final List<RadarTheme> allThemes;
  final Assessment assessment;
  final Function(RadarTheme) onThemeChanged;

  const _ShareThemeSelectorSheet({
    required this.currentTheme,
    required this.allThemes,
    required this.assessment,
    required this.onThemeChanged,
  });

  @override
  State<_ShareThemeSelectorSheet> createState() =>
      _ShareThemeSelectorSheetState();
}

class _ShareThemeSelectorSheetState extends State<_ShareThemeSelectorSheet> {
  late RadarTheme _selectedTheme;
  late ScrollController _scrollController;
  static const double _itemWidth = 112.0;
  bool _showSummary = true;
  bool _showCategoryScores = false;
  bool _showTotalScore = true;
  bool _isProcessing = false;
  final TextEditingController _saveDirController = TextEditingController();
  // 移除用户自定义图片尺寸与像素密度，使用固定生成逻辑
  Uint8List? _previewBytes;
  Timer? _previewDebounce;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _scrollController = ScrollController();
    _updatePreview();
  }

  @override
  void dispose() {
    _saveDirController.dispose();
    _scrollController.dispose();
    _previewDebounce?.cancel();
    super.dispose();
  }

  void _scroll(bool left) {
    final currentOffset = _scrollController.offset;
    final newOffset = (left ? currentOffset - _itemWidth : currentOffset + _itemWidth)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final isWide = w >= 720;
          final sheetMaxHeight = MediaQuery.of(context).size.height * 0.85;
          final radarPreviewSize = isWide ? 240.0 : 200.0;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: sheetMaxHeight),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '选择主题分享',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: UltimateWheelRadarChart(
                        scores: widget.assessment.scores,
                        size: radarPreviewSize,
                        radarTheme: _selectedTheme,
                      ),
                    ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await Navigator.of(context).push<RadarTheme?>(
                        MaterialPageRoute(
                          builder: (_) => _ThemePickerPage(
                            allThemes: widget.allThemes,
                            initial: _selectedTheme,
                          ),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedTheme = picked);
                        widget.onThemeChanged(picked);
                        _updatePreview();
                      }
                    },
                    child: Text('选择雷达主题：${_selectedTheme.name}'),
                  ),
                ),
              ],
            ),
          ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('预览图片', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: isWide ? 360 : 280,
                            child: Center(
                              child: _previewBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _previewBytes!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('显示AI教练总体评价'),
                            value: _showSummary,
                            onChanged: (v) {
                              setState(() => _showSummary = v);
                              _schedulePreviewUpdate();
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('显示分区得分'),
                            value: _showCategoryScores,
                            onChanged: (v) {
                              setState(() => _showCategoryScores = v);
                              _schedulePreviewUpdate();
                            },
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('显示总分'),
                            value: _showTotalScore,
                            onChanged: (v) {
                              setState(() => _showTotalScore = v);
                              _schedulePreviewUpdate();
                            },
                          ),
                          const SizedBox(height: 8),
                      const SizedBox.shrink(),
                          const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _saveDirController,
                              decoration: InputDecoration(
                                labelText: '保存目录(可选)',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: _pickSaveDirectory,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isProcessing ? null : () async {
                              setState(() => _isProcessing = true);
                              final service = ShareService();
                    final bytes = await service.generateAssessmentImageBytes(
                      assessment: widget.assessment,
                      theme: _selectedTheme,
                      includeSummary: _showSummary,
                      includeCategoryScores: _showCategoryScores,
                      includeTotalScore: _showTotalScore,
                    );
                              await service.saveImageToLocal(
                                context: context,
                                imageBytes: bytes,
                                fileNamePrefix: 'ultimate_wheel',
                                customDirPath: _saveDirController.text.trim().isEmpty ? null : _saveDirController.text.trim(),
                              );
                              if (mounted) {
                                setState(() => _isProcessing = false);
                                Navigator.pop(context, _selectedTheme);
                              }
                            },
                            icon: const Icon(Icons.save_alt),
                            label: const Text('保存图片到本地'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isProcessing ? null : () async {
                              setState(() => _isProcessing = true);
                              final service = ShareService();
                    final bytes = await service.generateAssessmentImageBytes(
                      assessment: widget.assessment,
                      theme: _selectedTheme,
                      includeSummary: _showSummary,
                      includeCategoryScores: _showCategoryScores,
                      includeTotalScore: _showTotalScore,
                    );
                              final shareText = '我的Ultimate Wheel评估结果\n评估时间：${DateFormat('yyyy-MM-dd HH:mm').format(widget.assessment.createdAt)}\n总分：${widget.assessment.totalScore.toStringAsFixed(1)}\n\n#极限飞盘 #UltimateWheel';
                              await service.shareImageBytes(
                                context: context,
                                imageBytes: bytes,
                                shareText: shareText,
                                fileName: 'ultimate_wheel_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
                              );
                              if (mounted) {
                                setState(() => _isProcessing = false);
                                Navigator.pop(context, _selectedTheme);
                              }
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('直接分享'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updatePreview() async {
    final service = ShareService();
    final bytes = await service.generateAssessmentImageBytes(
      assessment: widget.assessment,
      theme: _selectedTheme,
      includeSummary: _showSummary,
      includeCategoryScores: _showCategoryScores,
      includeTotalScore: _showTotalScore,
    );
    if (mounted) {
      setState(() => _previewBytes = bytes);
    }
  }
  void _schedulePreviewUpdate([int ms = 200]) {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(Duration(milliseconds: ms), () {
      _updatePreview();
    });
  }

  Future<void> _pickSaveDirectory() async {
    try {
      final dir = await getDirectoryPath();
      if (dir != null && dir.trim().isNotEmpty) {
        setState(() => _saveDirController.text = dir.trim());
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未选择目录或平台不支持目录选择')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择目录失败：$e')),
        );
      }
    }
  }
}

class _ScrollButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ScrollButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 140,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
class _ThemePickerPage extends StatefulWidget {
  final List<RadarTheme> allThemes;
  final RadarTheme initial;
  const _ThemePickerPage({required this.allThemes, required this.initial});

  @override
  State<_ThemePickerPage> createState() => _ThemePickerPageState();
}

class _ThemePickerPageState extends State<_ThemePickerPage> {
  late RadarTheme _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择雷达主题'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _current),
            child: const Text('确认'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: widget.allThemes.length,
          itemBuilder: (context, index) {
            final theme = widget.allThemes[index];
            return InkWell(
              onTap: () => setState(() => _current = theme),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.id == _current.id
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: theme.id == _current.id ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: RadarThemePreview(
                    theme: theme,
                    size: 100,
                    isSelected: theme.id == _current.id,
                    onTap: () => setState(() => _current = theme),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
