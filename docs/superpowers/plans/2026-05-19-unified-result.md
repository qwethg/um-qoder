# Unified Assessment Result Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new Zen-style result page for the unified assessment flow and fix the hidden "Save" button on the assessment screen to complete the loop.

**Architecture:** 
- Fix `UnifiedAssessmentScreen` layout to ensure the FAB is visible above the bottom navigation bar.
- Create a new `UnifiedAssessmentResultScreen` with a Zen UI (frosted glass, background gradient, clean layout).
- Update routing to direct the user to this new screen instead of the generic one.

**Tech Stack:** Flutter, Provider, GoRouter, Screenshot, SharePlus

---

### Task 1: Fix Save Button Visibility

**Files:**
- Modify: `lib/screens/assessment/unified_assessment_screen.dart`

- [ ] **Step 1: Fix layout overlap**
In `UnifiedAssessmentScreen`, change the floating action button logic. Since `Scaffold.floatingActionButton` is placed relative to the inner Scaffold and overlaps the outer bottom navigation bar, wrap the `ListView` in a `Stack` and position the `_buildSaveButton()` explicitly at the bottom of the body, rather than using `floatingActionButton`.

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // ... existing appbar code
      ),
      body: Container(
        decoration: BoxDecoration(
          // ... existing gradient
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      // ... existing list view
                      // Change bottom padding/SizedBox from 100 to 120
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 24, // Position above the bottom nav bar
                left: 0,
                right: 0,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 2: Update navigation target**
In `_handleSave()`, change the navigation target to the new result page.

```dart
      if (mounted) {
        context.go('/assessment/unified-result/${assessment.id}');
      }
```

### Task 2: Scaffold Zen Result Page

**Files:**
- Create: `lib/screens/assessment/unified_assessment_result_screen.dart`

- [ ] **Step 1: Create the basic layout**
Create the screen with `Selector<AssessmentProvider, Assessment?>` to fetch data, and use `LinearBindingGradient` background.

```dart
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
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('未找到评估记录')));
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    );
  }
  // (We'll implement the sub-widgets in the next steps)
}
```

### Task 3: Implement Zen Result Components

**Files:**
- Modify: `lib/screens/assessment/unified_assessment_result_screen.dart`

- [ ] **Step 1: Implement Header and Radar Chart**

```dart
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
```

- [ ] **Step 2: Implement Minimal AI Analysis & Details**

```dart
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
```

- [ ] **Step 3: Implement Actions**

```dart
  Widget _buildActionButtons(BuildContext context) {
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
        const SizedBox(width: 16),
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
  }
```

### Task 4: Route Registration

**Files:**
- Modify: `lib/config/router.dart`

- [ ] **Step 1: Add new route**
Add the new route for the unified assessment result screen alongside the existing result screen.

```dart
import 'package:ultimate_wheel/screens/assessment/unified_assessment_result_screen.dart';

// Inside AppRouter routes list:
        GoRoute(
          path: '/assessment/unified-result/:id',
          name: 'unified-assessment-result',
          builder: (context, state) {
            final assessmentId = state.pathParameters['id']!;
            return UnifiedAssessmentResultScreen(assessmentId: assessmentId);
          },
        ),
```
