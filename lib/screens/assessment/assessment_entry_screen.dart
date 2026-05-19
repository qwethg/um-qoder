import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/assessment_provider.dart';
import 'deep_assessment_screen.dart';
import 'unified_assessment_screen.dart';

/// 评估统一入口页
/// 根据是否有历史评估记录，动态决定展示哪种评估流
class AssessmentEntryScreen extends StatelessWidget {
  const AssessmentEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        if (provider.hasAssessments) {
          return const UnifiedAssessmentScreen();
        } else {
          return const DeepAssessmentScreen();
        }
      },
    );
  }
}
