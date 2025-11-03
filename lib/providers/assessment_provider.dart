import 'package:flutter/foundation.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/services/storage_service.dart';

/// 评估状态管理
class AssessmentProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  // 评估次数限制
  static const int maxAssessments = 20;

  AssessmentProvider(this._storageService) {
    _loadAssessments();
  }

  // 所有评估记录
  List<Assessment> _assessments = [];
  List<Assessment> get assessments => _assessments;

  // 最新的评估记录
  Assessment? get latestAssessment => 
      _assessments.isEmpty ? null : _assessments.first;

  // 是否有评估记录
  bool get hasAssessments => _assessments.isNotEmpty;
  
  // 是否已达到评估次数限制
  bool get hasReachedLimit => _assessments.length >= maxAssessments;
  
  // 剩余可评估次数
  int get remainingAssessments => maxAssessments - _assessments.length;

  // 加载评估记录
  void _loadAssessments() {
    _assessments = _storageService.getAllAssessments();
    notifyListeners();
  }

  /// 保存评估记录（带次数限制）
  Future<void> saveAssessment(Assessment assessment) async {
    // 如果已达到限制，删除最旧的评估记录
    if (_assessments.length >= maxAssessments) {
      final oldestAssessment = _assessments.last;
      await _storageService.deleteAssessment(oldestAssessment.id);
    }
    
    await _storageService.saveAssessment(assessment);
    _loadAssessments();
  }

  /// 更新评估记录
  Future<void> updateAssessment(Assessment assessment) async {
    await _storageService.saveAssessment(assessment);
    _loadAssessments();
  }

  /// 根据ID获取评估记录
  Assessment? getAssessmentById(String id) {
    return _storageService.getAssessment(id);
  }

  /// 删除评估记录
  Future<void> deleteAssessment(String id) async {
    await _storageService.deleteAssessment(id);
    _loadAssessments();
  }

  /// 清空所有评估记录
  Future<void> clearAllAssessments() async {
    await _storageService.clearAllAssessments();
    _loadAssessments();
  }

  /// 获取某个类别在所有评估中的分数变化
  List<double> getCategoryScoreHistory(List<String> abilityIds) {
    return _assessments.reversed.map((assessment) {
      return assessment.getCategoryScore(abilityIds);
    }).toList();
  }

  /// 获取某个能力在所有评估中的分数变化
  List<double> getAbilityScoreHistory(String abilityId) {
    return _assessments.reversed.map((assessment) {
      return assessment.scores[abilityId] ?? 0.0;
    }).toList();
  }
}
