import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';

/// AI 报告有效性验证服务
/// 
/// 负责验证 AI 分析报告的质量、完整性和时效性
class AiReportValidator {
  /// 验证报告的有效性
  /// 
  /// 参数:
  /// - [report]: 要验证的 AI 报告
  /// - [assessment]: 对应的评估数据
  /// - [goalSettings]: 用户目标设定
  /// 
  /// 返回: 验证结果
  static AiReportValidationResult validateReport(
    AiReport report,
    Assessment assessment,
    Map<String, GoalSetting> goalSettings,
  ) {
    final issues = <ValidationIssue>[];
    
    // 1. 基础数据验证
    _validateBasicData(report, issues);
    
    // 2. 内容质量验证
    _validateContentQuality(report, issues);
    
    // 3. 时效性验证
    _validateTimeliness(report, issues);
    
    // 4. 数据一致性验证
    _validateDataConsistency(report, assessment, goalSettings, issues);
    
    // 5. 结构完整性验证
    _validateStructuralIntegrity(report, issues);
    
    return AiReportValidationResult(
      isValid: issues.where((i) => i.severity == ValidationSeverity.error).isEmpty,
      issues: issues,
      score: _calculateValidationScore(issues),
    );
  }

  /// 验证基础数据
  static void _validateBasicData(AiReport report, List<ValidationIssue> issues) {
    if (report.id.isEmpty) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.missingData,
        severity: ValidationSeverity.error,
        message: '报告ID不能为空',
        field: 'id',
      ));
    }
    
    // 修正：使用空安全的方式检查内容
    if (report.content == null || report.content!.isEmpty) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.missingData,
        severity: ValidationSeverity.error,
        message: '报告内容不能为空',
        field: 'content',
      ));
    }
    
    if (report.assessmentId.isEmpty) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.missingData,
        severity: ValidationSeverity.error,
        message: '关联的评估ID不能为空',
        field: 'assessmentId',
      ));
    }
    
    if (report.aiModel.isEmpty) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.missingData,
        severity: ValidationSeverity.warning,
        message: 'AI模型信息缺失',
        field: 'aiModel',
      ));
    }
  }

  /// 验证内容质量
  static void _validateContentQuality(AiReport report, List<ValidationIssue> issues) {
    final content = report.content;

    // 修正：如果内容为空，则直接返回，因为 _validateBasicData 已处理此问题
    if (content == null || content.isEmpty) {
      return;
    }
    
    // 检查内容长度
    if (content.length < 100) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.contentQuality,
        severity: ValidationSeverity.warning,
        message: '报告内容过短，可能不够详细',
        field: 'content',
      ));
    }
    
    if (content.length > 50000) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.contentQuality,
        severity: ValidationSeverity.warning,
        message: '报告内容过长，可能影响阅读体验',
        field: 'content',
      ));
    }
    
    // 检查 Markdown 格式
    if (!_isValidMarkdown(content)) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.formatError,
        severity: ValidationSeverity.warning,
        message: 'Markdown格式可能存在问题',
        field: 'content',
      ));
    }
    
    // 检查必要的章节
    final requiredSections = ['分析', '建议', '总结'];
    for (final section in requiredSections) {
      // 修正：在非空内容上调用 contains
      if (!content.contains(section)) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.contentQuality,
          severity: ValidationSeverity.info,
          message: '建议包含"$section"章节以提高报告完整性',
          field: 'content',
        ));
      }
    }
  }

  /// 验证时效性
  static void _validateTimeliness(AiReport report, List<ValidationIssue> issues) {
    final now = DateTime.now();
    final reportAge = now.difference(report.createdAt);
    
    // 检查报告年龄
    if (reportAge.inDays > 30) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.outdated,
        severity: ValidationSeverity.warning,
        message: '报告生成时间超过30天，建议重新生成',
        field: 'createdAt',
      ));
    }
  }

  /// 验证数据一致性
  static void _validateDataConsistency(
    AiReport report,
    Assessment assessment,
    Map<String, GoalSetting> goalSettings,
    List<ValidationIssue> issues,
  ) {
    // 检查评估ID一致性
    if (report.assessmentId != assessment.id) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.dataInconsistency,
        severity: ValidationSeverity.error,
        message: '报告关联的评估ID与实际评估不匹配',
        field: 'assessmentId',
      ));
    }
    
    // 检查生成时间逻辑性
    if (report.createdAt.isBefore(assessment.createdAt)) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.dataInconsistency,
        severity: ValidationSeverity.error,
        message: '报告生成时间早于评估创建时间',
        field: 'createdAt',
      ));
    }
    
    // 检查版本号合理性
    if (report.version < 1) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.dataInconsistency,
        severity: ValidationSeverity.error,
        message: '报告版本号无效',
        field: 'version',
      ));
    }
  }

  /// 验证结构完整性
  static void _validateStructuralIntegrity(AiReport report, List<ValidationIssue> issues) {
    // 检查状态合理性
    if (report.status == AiReportStatus.generating && 
        DateTime.now().difference(report.createdAt).inMinutes > 10) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.structuralError,
        severity: ValidationSeverity.error,
        message: '报告状态异常：生成时间过长',
        field: 'status',
      ));
    }
    
    // 检查生成时间合理性
    if (report.generationTimeMs != null) {
      if (report.generationTimeMs! < 0) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.structuralError,
          severity: ValidationSeverity.error,
          message: '生成时间不能为负数',
          field: 'generationTimeMs',
        ));
      }
      
      if (report.generationTimeMs! > 300000) { // 5分钟
        issues.add(ValidationIssue(
          type: ValidationIssueType.performance,
          severity: ValidationSeverity.warning,
          message: '报告生成时间过长，可能存在性能问题',
          field: 'generationTimeMs',
        ));
      }
    }
  }

  /// 检查 Markdown 格式是否有效
  static bool _isValidMarkdown(String content) {
    // 简单的 Markdown 格式检查
    final lines = content.split('\n');
    int headerCount = 0;
    
    for (final line in lines) {
      if (line.startsWith('#')) {
        headerCount++;
      }
    }
    
    // 至少应该有一个标题
    return headerCount > 0;
  }

  /// 计算验证分数
  static double _calculateValidationScore(List<ValidationIssue> issues) {
    double score = 100.0;
    
    for (final issue in issues) {
      switch (issue.severity) {
        case ValidationSeverity.error:
          score -= 20.0;
          break;
        case ValidationSeverity.warning:
          score -= 10.0;
          break;
        case ValidationSeverity.info:
          score -= 2.0;
          break;
      }
    }
    
    return score.clamp(0.0, 100.0);
  }
}

/// 验证结果
class AiReportValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final double score;

  const AiReportValidationResult({
    required this.isValid,
    required this.issues,
    required this.score,
  });

  /// 获取错误问题
  List<ValidationIssue> get errors => 
      issues.where((i) => i.severity == ValidationSeverity.error).toList();

  /// 获取警告问题
  List<ValidationIssue> get warnings => 
      issues.where((i) => i.severity == ValidationSeverity.warning).toList();

  /// 获取信息问题
  List<ValidationIssue> get infos => 
      issues.where((i) => i.severity == ValidationSeverity.info).toList();

  /// 是否有严重问题
  bool get hasCriticalIssues => errors.isNotEmpty;

  /// 获取质量等级
  String get qualityGrade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

/// 验证问题
class ValidationIssue {
  final ValidationIssueType type;
  final ValidationSeverity severity;
  final String message;
  final String field;

  const ValidationIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.field,
  });
}

/// 验证问题类型
enum ValidationIssueType {
  missingData,      // 数据缺失
  contentQuality,   // 内容质量
  formatError,      // 格式错误
  outdated,         // 过期
  dataInconsistency, // 数据不一致
  structuralError,  // 结构错误
  performance,      // 性能问题
}

/// 验证严重程度
enum ValidationSeverity {
  error,    // 错误：必须修复
  warning,  // 警告：建议修复
  info,     // 信息：可选修复
}