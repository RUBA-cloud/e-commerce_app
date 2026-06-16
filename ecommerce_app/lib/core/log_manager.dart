import 'package:logger/logger.dart';

class LogsManager {
  static final LogsManager _instance = LogsManager._internal();
  late final Logger _logger;

  factory LogsManager() {
    return _instance;
  }

  LogsManager._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static void logState(String message) {
    _instance._logInfo(message);
  }


  static void logSuccess(String message) {
    _instance._logSuccess(message);
  }

  static void logError(String message) {
    _instance._logError(message);
  }

  static void logInfo(String message) {
    _instance._logInfo(message);
  }

  void _logSuccess(String message) {
    _logger.i('SUCCESS: $message');
  }

  void _logError(String message) {
    _logger.e('ERROR: $message');
  }

  void _logInfo(String message) {
    _logger.i('INFO: $message');
  }
}