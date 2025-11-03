import 'package:ultimate_wheel/models/ai_report.dart';
import 'package:ultimate_wheel/models/assessment.dart';

/// AI 报告访问控制服务
/// 
/// 负责管理 AI 分析报告的访问权限、数据安全和操作审计
class AiReportAccessControl {
  static const int _maxReportsPerUser = 1000;
  static const int _maxReportsPerDay = 50;
  static const Duration _rateLimitWindow = Duration(hours: 1);
  static const int _maxRequestsPerHour = 20;

  final Map<String, List<DateTime>> _userRequestHistory = {};
  final Map<String, int> _dailyReportCounts = {};
  final Map<String, DateTime> _lastResetTime = {};

  /// 检查用户是否有权限访问报告
  /// 
  /// 参数:
  /// - [userId]: 用户ID（可以是设备ID或用户标识）
  /// - [reportId]: 报告ID
  /// - [report]: 报告对象
  /// 
  /// 返回: 访问权限检查结果
  AccessControlResult checkReportAccess({
    required String userId,
    required String reportId,
    required AiReport report,
  }) {
    // 1. 基础权限检查
    if (!_hasBasicAccess(userId)) {
      return AccessControlResult.denied(
        reason: '用户无基础访问权限',
        code: AccessDeniedCode.noBasicAccess,
      );
    }

    // 2. 报告所有权检查
    if (!_isReportOwner(userId, report)) {
      return AccessControlResult.denied(
        reason: '用户无权访问此报告',
        code: AccessDeniedCode.notOwner,
      );
    }

    // 3. 报告状态检查
    if (!_isReportAccessible(report)) {
      return AccessControlResult.denied(
        reason: '报告当前不可访问',
        code: AccessDeniedCode.reportUnavailable,
      );
    }

    return AccessControlResult.allowed();
  }

  /// 检查用户是否有权限创建新报告
  /// 
  /// 参数:
  /// - [userId]: 用户ID
  /// - [assessment]: 关联的评估
  /// 
  /// 返回: 创建权限检查结果
  AccessControlResult checkCreateReportPermission({
    required String userId,
    required Assessment assessment,
  }) {
    // 1. 基础权限检查
    if (!_hasBasicAccess(userId)) {
      return AccessControlResult.denied(
        reason: '用户无基础访问权限',
        code: AccessDeniedCode.noBasicAccess,
      );
    }

    // 2. 评估所有权检查
    if (!_isAssessmentOwner(userId, assessment)) {
      return AccessControlResult.denied(
        reason: '用户无权为此评估创建报告',
        code: AccessDeniedCode.notOwner,
      );
    }

    // 3. 速率限制检查
    final rateLimitResult = _checkRateLimit(userId);
    if (!rateLimitResult.allowed) {
      return rateLimitResult;
    }

    // 4. 每日报告数量限制检查
    final dailyLimitResult = _checkDailyLimit(userId);
    if (!dailyLimitResult.allowed) {
      return dailyLimitResult;
    }

    // 5. 总报告数量限制检查
    final totalLimitResult = _checkTotalLimit(userId);
    if (!totalLimitResult.allowed) {
      return totalLimitResult;
    }

    return AccessControlResult.allowed();
  }

  /// 记录报告访问
  /// 
  /// 参数:
  /// - [userId]: 用户ID
  /// - [reportId]: 报告ID
  /// - [operation]: 操作类型
  void logReportAccess({
    required String userId,
    required String reportId,
    required ReportOperation operation,
  }) {
    final now = DateTime.now();
    
    // 记录用户请求历史（用于速率限制）
    _userRequestHistory.putIfAbsent(userId, () => []).add(now);
    
    // 清理过期的请求记录
    _cleanupExpiredRequests(userId);
    
    // 如果是创建操作，更新每日计数
    if (operation == ReportOperation.create) {
      _updateDailyCount(userId);
    }
    
    // 这里可以添加更详细的审计日志记录
    _logAuditEvent(userId, reportId, operation, now);
  }

  /// 获取用户的访问统计信息
  /// 
  /// 参数:
  /// - [userId]: 用户ID
  /// 
  /// 返回: 用户访问统计
  UserAccessStats getUserAccessStats(String userId) {
    final now = DateTime.now();
    final requestHistory = _userRequestHistory[userId] ?? [];
    final recentRequests = requestHistory
        .where((time) => now.difference(time) <= _rateLimitWindow)
        .length;
    
    final dailyCount = _getDailyCount(userId);
    
    return UserAccessStats(
      userId: userId,
      recentRequestCount: recentRequests,
      dailyReportCount: dailyCount,
      remainingDailyReports: (_maxReportsPerDay - dailyCount).clamp(0, _maxReportsPerDay),
      remainingHourlyRequests: (_maxRequestsPerHour - recentRequests).clamp(0, _maxRequestsPerHour),
      nextResetTime: _getNextResetTime(userId),
    );
  }

  /// 重置用户限制（管理员功能）
  /// 
  /// 参数:
  /// - [userId]: 用户ID
  /// - [resetType]: 重置类型
  void resetUserLimits({
    required String userId,
    required ResetType resetType,
  }) {
    switch (resetType) {
      case ResetType.rateLimit:
        _userRequestHistory.remove(userId);
        break;
      case ResetType.dailyLimit:
        _dailyReportCounts.remove(userId);
        _lastResetTime.remove(userId);
        break;
      case ResetType.all:
        _userRequestHistory.remove(userId);
        _dailyReportCounts.remove(userId);
        _lastResetTime.remove(userId);
        break;
    }
  }

  /// 检查基础访问权限
  bool _hasBasicAccess(String userId) {
    // 这里可以实现更复杂的权限检查逻辑
    // 例如检查用户是否被封禁、是否有有效订阅等
    return userId.isNotEmpty;
  }

  /// 检查报告所有权
  bool _isReportOwner(String userId, AiReport report) {
    // 在实际应用中，这里应该检查报告是否属于该用户
    // 目前简化为检查报告是否有效
    return report.id.isNotEmpty;
  }

  /// 检查评估所有权
  bool _isAssessmentOwner(String userId, Assessment assessment) {
    // 在实际应用中，这里应该检查评估是否属于该用户
    // 目前简化为检查评估是否有效
    return assessment.id.isNotEmpty;
  }

  /// 检查报告是否可访问
  bool _isReportAccessible(AiReport report) {
    // 检查报告状态
    if (report.status == AiReportStatus.failed) {
      return false;
    }
    
    // 检查缓存是否过期
    if (report.isCached && report.cacheExpiresAt != null) {
      if (DateTime.now().isAfter(report.cacheExpiresAt!)) {
        return false;
      }
    }
    
    return true;
  }

  /// 检查速率限制
  AccessControlResult _checkRateLimit(String userId) {
    final now = DateTime.now();
    final requestHistory = _userRequestHistory[userId] ?? [];
    final recentRequests = requestHistory
        .where((time) => now.difference(time) <= _rateLimitWindow)
        .length;
    
    if (recentRequests >= _maxRequestsPerHour) {
      return AccessControlResult.denied(
        reason: '请求过于频繁，请稍后再试',
        code: AccessDeniedCode.rateLimitExceeded,
        retryAfter: _rateLimitWindow,
      );
    }
    
    return AccessControlResult.allowed();
  }

  /// 检查每日限制
  AccessControlResult _checkDailyLimit(String userId) {
    final dailyCount = _getDailyCount(userId);
    
    if (dailyCount >= _maxReportsPerDay) {
      return AccessControlResult.denied(
        reason: '今日报告生成次数已达上限',
        code: AccessDeniedCode.dailyLimitExceeded,
        retryAfter: Duration(hours: 24),
      );
    }
    
    return AccessControlResult.allowed();
  }

  /// 检查总数限制
  AccessControlResult _checkTotalLimit(String userId) {
    // 这里应该查询数据库获取用户的总报告数
    // 目前简化处理
    return AccessControlResult.allowed();
  }

  /// 获取每日计数
  int _getDailyCount(String userId) {
    final now = DateTime.now();
    final lastReset = _lastResetTime[userId];
    
    // 如果是新的一天，重置计数
    if (lastReset == null || !_isSameDay(now, lastReset)) {
      _dailyReportCounts[userId] = 0;
      _lastResetTime[userId] = now;
      return 0;
    }
    
    return _dailyReportCounts[userId] ?? 0;
  }

  /// 更新每日计数
  void _updateDailyCount(String userId) {
    final currentCount = _getDailyCount(userId);
    _dailyReportCounts[userId] = currentCount + 1;
  }

  /// 清理过期的请求记录
  void _cleanupExpiredRequests(String userId) {
    final now = DateTime.now();
    final requestHistory = _userRequestHistory[userId];
    if (requestHistory != null) {
      requestHistory.removeWhere(
        (time) => now.difference(time) > _rateLimitWindow,
      );
    }
  }

  /// 获取下次重置时间
  DateTime _getNextResetTime(String userId) {
    final lastReset = _lastResetTime[userId];
    if (lastReset == null) {
      return DateTime.now().add(Duration(days: 1));
    }
    
    return DateTime(lastReset.year, lastReset.month, lastReset.day + 1);
  }

  /// 检查是否是同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 记录审计事件
  void _logAuditEvent(
    String userId,
    String reportId,
    ReportOperation operation,
    DateTime timestamp,
  ) {
    // 这里可以实现详细的审计日志记录
    // 例如写入日志文件或发送到日志服务
    print('AUDIT: User $userId performed $operation on report $reportId at $timestamp');
  }
}

/// 访问控制结果
class AccessControlResult {
  final bool allowed;
  final String? reason;
  final AccessDeniedCode? code;
  final Duration? retryAfter;

  const AccessControlResult._({
    required this.allowed,
    this.reason,
    this.code,
    this.retryAfter,
  });

  factory AccessControlResult.allowed() {
    return const AccessControlResult._(allowed: true);
  }

  factory AccessControlResult.denied({
    required String reason,
    required AccessDeniedCode code,
    Duration? retryAfter,
  }) {
    return AccessControlResult._(
      allowed: false,
      reason: reason,
      code: code,
      retryAfter: retryAfter,
    );
  }
}

/// 访问拒绝代码
enum AccessDeniedCode {
  noBasicAccess,        // 无基础访问权限
  notOwner,             // 非所有者
  reportUnavailable,    // 报告不可用
  rateLimitExceeded,    // 速率限制超出
  dailyLimitExceeded,   // 每日限制超出
  totalLimitExceeded,   // 总数限制超出
}

/// 报告操作类型
enum ReportOperation {
  create,   // 创建
  read,     // 读取
  update,   // 更新
  delete,   // 删除
}

/// 重置类型
enum ResetType {
  rateLimit,  // 速率限制
  dailyLimit, // 每日限制
  all,        // 全部
}

/// 用户访问统计
class UserAccessStats {
  final String userId;
  final int recentRequestCount;
  final int dailyReportCount;
  final int remainingDailyReports;
  final int remainingHourlyRequests;
  final DateTime nextResetTime;

  const UserAccessStats({
    required this.userId,
    required this.recentRequestCount,
    required this.dailyReportCount,
    required this.remainingDailyReports,
    required this.remainingHourlyRequests,
    required this.nextResetTime,
  });
}