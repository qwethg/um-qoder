import 'package:flutter/material.dart';

/// 评估结果页 (03-4)
class AssessmentResultScreen extends StatelessWidget {
  final String assessmentId;

  const AssessmentResultScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评估结果'),
      ),
      body: const Center(
        child: Text('评估结果页面 - 开发中'),
      ),
    );
  }
}
