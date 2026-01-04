import 'package:stack_trace/stack_trace.dart';

/// Defines the severity levels for log messages.
enum LogLevel {
  /// Detailed information for debugging purposes.
  debug,

  /// General operational information about the application state.
  info,

  /// potentially harmful situations that should be investigated.
  warning,

  /// Error events that might still allow the application to continue running.
  error,
}

/// A global logger that asserts strict formatting and color requirements.
///
/// This logger outputs messages in the format:
/// `[Time] [File:Line] [Level] Message`
///
/// Colors:
/// - Time: Green
/// - File:Line: Violet
/// - Debug: Grey
/// - Info: Blue
/// - Warning: Orange
/// - Error: Red
class VarianceLogger {
  // ANSI Color Codes
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _violet = '\x1B[35m';
  static const String _grey = '\x1B[90m';
  static const String _blue = '\x1B[34m';
  static const String _orange = '\x1B[33m'; // Yellow/Orange
  static const String _red = '\x1B[31m';

  ///Logs a message at the [LogLevel.debug] level.
  ///
  /// Parameters:
  /// - [message]: The message to log.
  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// Logs a message at the [LogLevel.info] level.
  ///
  /// Parameters:
  /// - [message]: The message to log.
  static void info(String message) {
    _log(LogLevel.info, message);
  }

  /// Logs a message at the [LogLevel.warning] level.
  ///
  /// Parameters:
  /// - [message]: The message to log.
  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// Logs a message at the [LogLevel.error] level.
  ///
  /// Parameters:
  /// - [message]: The message to log.
  static void error(String message) {
    _log(LogLevel.error, message);
  }

  /// Internal log handler that constructs the formatted string.
  static void _log(LogLevel level, String message) {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Get the caller frame.
    // We skip frames to get to the actual caller of debug/info/etc.
    // hierarchy: _log -> public method (e.g. debug) -> caller
    final trace = Trace.current();
    final frame = trace.frames.length > 2
        ? trace.frames[2]
        : trace.frames.first;
    final fileInfo = '${frame.uri.pathSegments.last}:${frame.line}';

    final color = _getLevelColor(level);
    final levelName = '[${level.toString().split('.').last[0].toUpperCase()}]';

    // Construct the formatted string
    // [HH:mm] file:line LEVEL message
    final formattedLog =
        '$_green[$timeString]$_reset $_violet[$fileInfo]$_reset $color$levelName $message$_reset';

    // Use developer.log to ensure it appears in Dart DevTools/Console reliably
    // We print purely for the ANSI colors in terminal, developer.log for structure tools
    // However, stdout is better for raw terminal color visibility.
    // For this specific requirement "single line, with colors" in terminal:
    // ignore: avoid_print
    print(formattedLog);
  }

  static String _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _grey;
      case LogLevel.info:
        return _blue;
      case LogLevel.warning:
        return _orange;
      case LogLevel.error:
        return _red;
    }
  }
}
