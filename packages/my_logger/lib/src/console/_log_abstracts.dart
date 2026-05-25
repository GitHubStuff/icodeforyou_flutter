// my_logger/lib/src/console/_log_abstracts.dart
// ignore_for_file: one_member_abstracts

part of 'my_logger.dart';

/// Contract for reporting errors and messages to Crashlytics.
abstract class CrashlyticsReporter {
  /// Reports a [message] to Crashlytics, with an optional [error]
  ///  and [stackTrace].
  void report(String message, Object? error, StackTrace? stackTrace);
}

/// Converts a [_LogMessage] into a formatted string for output.
abstract class _LogFormatter {
  /// Returns a formatted string representation of [message].
  String format(_LogMessage message);
}

/// Writes a formatted log message to an output destination.
abstract class _LogOutput {
  /// Writes [formattedMessage] derived from [message] to the
  /// output destination.
  String write(String formattedMessage, _LogMessage message);
}

/// Formats a [StackTrace] into a human-readable string.
abstract class _StackTraceFormatter {
  /// Returns a formatted stack trace string, limited to [frames] frames.
  ///
  /// [showColor] controls ANSI colour output. [tag] identifies the log source.
  String? format(
    StackTrace? stackTrace,
    int frames,
    // ignore: avoid_positional_boolean_parameters document_ignores
    bool showColor,
    String tag,
  );
}

/// Applies colour formatting to a log message string.
abstract class _ColorFormatter {
  /// Returns [message] wrapped in ANSI colour codes appropriate for [level].
  ///
  /// [showColor] controls whether colour codes are applied.
  // ignore: avoid_positional_boolean_parameters document_ignores
  String apply(String message, LoggerLevel level, bool showColor);
}

/// Determines whether a given [_LogMessage] should be emitted.
abstract class _LogFilter {
  /// Returns `true` if [message] passes the filter and should be logged.
  bool shouldLog(_LogMessage message);
}
