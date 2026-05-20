import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../config/l10n.dart';
import '../../models/assessment.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/radar_theme_provider.dart';
import '../../widgets/ultimate_wheel_radar_chart.dart';
import '../../widgets/ai_analysis_section.dart';
import '../../services/share_service.dart';
import 'unified_assessment_screen.dart'; // for LinearBindingGradient

class UnifiedAssessmentResultScreen extends StatelessWidget {
  final String assessmentId;
  
  const UnifiedAssessmentResultScreen({super.key, required this.assessmentId});

  @override
  Widget build(BuildContext context) {
    return Selector<AssessmentProvider, Assessment?>(
      selector: (_, provider) => provider.getAssessmentById(assessmentId),
      builder: (context, assessment, _) {
        if (assessment == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('未找到评估记录'.tr)),
          );
        }
        return _ZenResultContent(assessment: assessment);
      },
    );
  }
}

class _ZenResultContent extends StatefulWidget {
  final Assessment assessment;
  
  const _ZenResultContent({required this.assessment});
  
  @override
  State<_ZenResultContent> createState() => _ZenResultContentState();
}

class _ZenResultContentState extends State<_ZenResultContent> {
  final _screenshotController = ScreenshotController();
  final _shareService = ShareService();
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearBindingGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Screenshot(
            controller: _screenshotController,
            child: Container(
              // Needed for screenshot to capture background correctly if scrolled
              decoration: BoxDecoration(
                gradient: LinearBindingGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildRadarChart(context),
                  const SizedBox(height: 32),
                  _buildAiAnalysis(context),
                  const SizedBox(height: 32),
                  _buildScoreDetails(context),
                  const SizedBox(height: 48),
                  _buildActionButtons(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          '评估完成'.tr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('yyyy.MM.dd HH:mm').format(widget.assessment.createdAt),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    final theme = context.watch<RadarThemeProvider>().currentTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: UltimateWheelRadarChart(
            scores: widget.assessment.scores,
            size: MediaQuery.of(context).size.width - 96,
            radarTheme: theme,
          ),
        ),
      ),
    );
  }

  Widget _buildAiAnalysis(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: AiAnalysisSection(
        assessment: widget.assessment,
        onAssessmentUpdated: (updatedAssessment) {
          context.read<AssessmentProvider>().updateAssessment(updatedAssessment);
        },
      ),
    );
  }

  Widget _buildScoreDetails(BuildContext context) {
    return Column(
      children: [
        Text(
          '总分: ${widget.assessment.totalScore.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => context.go('/home'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('完成'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isProcessing ? null : _handleShare,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: _isProcessing 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.share, size: 18),
                label: Text('分享'.tr, style: const TextStyle(fontWeight: FontWeight.w400)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/history'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('查看历史'.tr, style: const TextStyle(fontWeight: FontWeight.w400)),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/history'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('查看历史'.tr, style: const TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _handleShare,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: _isProcessing 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.share, size: 18),
                label: Text('分享'.tr, style: const TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.go('/home'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('完成'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _handleShare() async {
    setState(() => _isProcessing = true);
    try {
      final theme = context.read<RadarThemeProvider>().currentTheme;
      final bytes = await _shareService.generateAssessmentImageBytes(
        assessment: widget.assessment,
        theme: theme,
        includeSummary: true,
        includeCategoryScores: true,
        includeTotalScore: true,
      );
      
      final shareText = '我的Ultimate Wheel评估结果\n评估时间：${DateFormat('yyyy-MM-dd HH:mm').format(widget.assessment.createdAt)}\n总分：${widget.assessment.totalScore.toStringAsFixed(1)}\n\n#极限飞盘 #UltimateWheel';
      
      if (mounted) {
        await _shareService.shareImageBytes(
          context: context,
          imageBytes: bytes,
          shareText: shareText,
          fileName: 'ultimate_wheel_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
