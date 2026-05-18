import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ultimate_wheel/models/assessment.dart';
import 'package:ultimate_wheel/models/goal_setting.dart';
import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/services/storage_service.dart';
import 'package:intl/intl.dart';

class BackupService {
  final StorageService _storageService;

  BackupService(this._storageService);

  /// 导出数据为 JSON
  Future<bool> exportData() async {
    try {
      final assessments = _storageService.getAllAssessments();
      final goalSettings = _storageService.getAllGoalSettings().values.toList();
      final aiReports = _storageService.aiReportStorage.getAllReports();

      final data = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'assessments': assessments.map((e) => _assessmentToJson(e)).toList(),
        'goalSettings': goalSettings.map((e) => _goalSettingToJson(e)).toList(),
        'aiReports': aiReports.map((e) => _aiReportToJson(e)).toList(),
      };

      final jsonStr = jsonEncode(data);
      final bytes = utf8.encode(jsonStr);
      final fileName = 'ultimate_wheel_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      if (kIsWeb) {
        // Web: use file_selector to download
        final file = XFile.fromData(
          Uint8List.fromList(bytes),
          name: fileName,
          mimeType: 'application/json',
        );
        await file.saveTo(fileName);
        return true;
      } else if (Platform.isIOS || Platform.isAndroid) {
        // Mobile: use share_plus
        final file = XFile.fromData(
          Uint8List.fromList(bytes),
          name: fileName,
          mimeType: 'application/json',
        );
        final result = await Share.shareXFiles([file], subject: 'Ultimate Wheel Backup');
        return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
      } else {
        // Desktop
        final location = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'JSON', extensions: ['json'])
          ],
        );
        if (location != null) {
          final file = XFile.fromData(Uint8List.fromList(bytes));
          await file.saveTo(location.path);
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Export failed: $e');
      return false;
    }
  }

  /// 导入 JSON 数据
  Future<bool> importData() async {
    try {
      final typeGroup = const XTypeGroup(
        label: 'JSON files',
        extensions: ['json'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      
      if (file == null) return false;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['version'] != 1) {
        throw Exception('Unsupported backup version');
      }

      // 导入 Assessments
      if (data['assessments'] != null) {
        final List<dynamic> assessmentsJson = data['assessments'];
        for (var item in assessmentsJson) {
          final assessment = _assessmentFromJson(item as Map<String, dynamic>);
          await _storageService.saveAssessment(assessment);
        }
      }

      // 导入 GoalSettings
      if (data['goalSettings'] != null) {
        final List<dynamic> goalsJson = data['goalSettings'];
        final goals = goalsJson.map((e) => _goalSettingFromJson(e as Map<String, dynamic>)).toList();
        await _storageService.saveGoalSettings(goals);
      }

      // 导入 AiReports
      if (data['aiReports'] != null) {
        final List<dynamic> reportsJson = data['aiReports'];
        for (var item in reportsJson) {
          final report = _aiReportFromJson(item as Map<String, dynamic>);
          await _storageService.aiReportStorage.saveReport(report);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Import failed: $e');
      return false;
    }
  }

  // ==== 序列化辅助方法 ====

  Map<String, dynamic> _assessmentToJson(Assessment a) {
    return {
      'id': a.id,
      'createdAt': a.createdAt.toIso8601String(),
      'type': a.type.index, // Enum as index
      'scores': a.scores,
      'notes': a.notes,
      'overallNote': a.overallNote,
      'aiAnalysisContent': a.aiAnalysisContent,
      'aiAnalysisGeneratedAt': a.aiAnalysisGeneratedAt?.toIso8601String(),
      'aiAnalysisSummary': a.aiAnalysisSummary,
    };
  }

  Assessment _assessmentFromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: AssessmentType.values[json['type'] as int],
      scores: Map<String, double>.from(json['scores'] as Map),
      notes: Map<String, String>.from(json['notes'] as Map),
      overallNote: json['overallNote'] as String?,
      aiAnalysisContent: json['aiAnalysisContent'] as String?,
      aiAnalysisGeneratedAt: json['aiAnalysisGeneratedAt'] != null 
          ? DateTime.parse(json['aiAnalysisGeneratedAt'] as String) 
          : null,
      aiAnalysisSummary: json['aiAnalysisSummary'] as String?,
    );
  }

  Map<String, dynamic> _goalSettingToJson(GoalSetting g) {
    return {
      'abilityId': g.abilityId,
      // Map<int, String> needs string keys for JSON
      'scoreDescriptions': g.scoreDescriptions.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  GoalSetting _goalSettingFromJson(Map<String, dynamic> json) {
    final descriptions = (json['scoreDescriptions'] as Map).map(
      (k, v) => MapEntry(int.parse(k.toString()), v.toString()),
    );
    return GoalSetting(
      abilityId: json['abilityId'] as String,
      scoreDescriptions: descriptions,
    );
  }

  Map<String, dynamic> _aiReportToJson(AiReport r) {
    return {
      'id': r.id,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
      'version': r.version,
      'assessmentId': r.assessmentId,
      'inputHash': r.inputHash,
      'content': r.content,
      'status': r.status.index,
      'error': r.error,
      'aiModel': r.aiModel,
      'apiParameters': r.apiParameters,
      'generationTimeMs': r.generationTimeMs,
      'tags': r.tags,
      'isCached': r.isCached,
      'cachedAt': r.cachedAt?.toIso8601String(),
    };
  }

  AiReport _aiReportFromJson(Map<String, dynamic> json) {
    return AiReport(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: json['version'] as int,
      assessmentId: json['assessmentId'] as String,
      inputHash: json['inputHash'] as String,
      content: json['content'] as String?,
      status: AiReportStatus.values[json['status'] as int],
      error: json['error'] as String?,
      aiModel: json['aiModel'] as String,
      apiParameters: Map<String, dynamic>.from(json['apiParameters'] as Map),
      generationTimeMs: json['generationTimeMs'] as int?,
      tags: List<String>.from(json['tags'] as List),
      isCached: json['isCached'] as bool? ?? false,
      cachedAt: json['cachedAt'] != null ? DateTime.parse(json['cachedAt'] as String) : null,
    );
  }
}
