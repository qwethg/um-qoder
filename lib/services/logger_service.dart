import 'package:logger/logger.dart';

// 创建一个全局可访问的 logger 实例，方便在应用的任何地方直接调用
final logger = LoggerService();

class LoggerService {
  // 使用单例模式确保全局只有一个 LoggerService 实例
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;

  late final Logger _logger;

  LoggerService._internal() {
    _logger = Logger(
      // 使用 PrettyPrinter 来获得美观、彩色的日志输出
      printer: PrettyPrinter(
        methodCount: 1, // 每个日志只显示1层调用堆栈
        errorMethodCount: 5, // 错误日志显示5层堆栈，方便溯源
        lineLength: 80, // 每行日志的最大长度
        colors: true, // 启用彩色日志
        printEmojis: true, // 在日志级别前打印 Emoji 图标
        printTime: false, // 不打印时间戳，保持简洁
      ),
      // 设置全局日志级别。在开发时可以使用 verbose，在发布前可以调整为 warning
      level: Level.verbose,
    );
  }

  // 定义不同级别的日志方法，方便调用
  void verbose(dynamic message) => _logger.v(message);
  void debug(dynamic message) => _logger.d(message);
  void info(dynamic message) => _logger.i(message);
  void warning(dynamic message) => _logger.w(message);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.wtf(message, error: error, stackTrace: stackTrace);
}