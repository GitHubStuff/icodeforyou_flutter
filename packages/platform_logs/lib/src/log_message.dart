// packages/platform_logs/lib/src/log_message.dart

import 'package:platform_logs/src/log_color.dart' show LogColor;

/// Categorizes log entries by severity or intent, providing associated visual
/// cues such as emojis and terminal display colors.
///
/// Use each level to prefix or format output messages consistently across
/// the logging pipeline.
///
/// Example:
/// ```dart
/// void log(LogMessage type, String message) {
///   final formatted = '${type.emoji}$message';
///   print(type.color?.wrap(formatted) ?? formatted);
/// }
///
/// log(LogMessage.error, 'Database connection failed');
/// ```
enum LogMessage {
  /// Detailed diagnostics and debugging information.
  ///
  /// Represented by the 🐞 emoji and [LogColor.white].
  debug('🐞', LogColor.white),

  /// Standard runtime debug prints and routine tracing output.
  ///
  /// Represented by the 🖨️ emoji and muted [LogColor.grey].
  debugPrint('🖨️', LogColor.grey),

  /// Critical failures, unhandled exceptions, and fatal errors.
  ///
  /// Represented by the 💥 emoji and prominent [LogColor.red].
  error('💥', LogColor.red),

  /// Recoverable issues, unexpected states, or deprecation warnings.
  ///
  /// Represented by the ⚠️ emoji and cautionary [LogColor.yellow].
  warning('⚠️', LogColor.yellow),
  ;

  /// Creates a log category with a dedicated [emoji] indicator and
  /// terminal [color].
  const LogMessage(this.emoji, this.color);

  /// Visual indicator prefix representing the log level.
  final String emoji;

  /// The ANSI [LogColor] used to highlight the log message, or `null` if
  /// uncolored.
  final LogColor? color;
}
