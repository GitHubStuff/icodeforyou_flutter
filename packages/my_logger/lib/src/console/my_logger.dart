// my_logger/lib/src/console/my_logger.dart

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kReleaseMode, visibleForTesting;

part '_log_level.dart';
part '_log_abstracts.dart';
part '_log_constants.dart';
part '_log_message.dart';
part '_log_formatters.dart';
part '_default_log_formatter.dart';
part '_default_log_filter.dart';
part '_debug_log_output.dart';
part '_release_log_output.dart';

/// A structured, level-based logger with optional Crashlytics integration.
///
/// [MyLogger] is a singleton that routes log messages through a configurable
/// [_LogFormatter], [_LogOutput], and [_DefaultLogFilter] pipeline. In debug
/// builds the [_DebugLogOutput] is used; in release builds the
/// [_ReleaseLogOutput] is substituted automatically.
///
/// Usage:
/// ```dart
/// MyLogger.init(crashlyticsReporter: myCrashlyticsReporter);
/// MyLogger.d('Something happened');
/// MyLogger.e('Oops', error: err, stackTrace: st);
/// ```
class MyLogger {
  MyLogger._({
    _LogFormatter? formatter,
    _LogOutput? output,
    _DefaultLogFilter? filter,
  }) : _formatter = formatter ?? const _DefaultLogFormatter(),
       _output =
           output ??
           (kReleaseMode ? const _ReleaseLogOutput() : const _DebugLogOutput()),
       _filter = filter ?? _DefaultLogFilter();

  /// Replaces the singleton with a test-friendly instance.
  ///
  /// Set [useReleaseOutput] to `true` to exercise the release output path
  /// in tests. Must be paired with [resetForTesting] in `tearDown`.
  @visibleForTesting
  static void overrideForTesting({bool useReleaseOutput = false}) {
    _instance = MyLogger._(
      output: useReleaseOutput
          ? const _ReleaseLogOutput()
          : const _DebugLogOutput(),
    );
  }

  /// Restores the singleton to its default state after a test.
  @visibleForTesting
  static void resetForTesting() => _instance = null;

  static MyLogger? _instance;

  final _LogFormatter _formatter;
  final _LogOutput _output;
  final _DefaultLogFilter _filter;
  CrashlyticsReporter? _crashlyticsReporter;

  // ignore: prefer_constructors_over_static_methods document_ignores
  static MyLogger get _i => _instance ??= MyLogger._();

  /// Configures the logger with an optional [CrashlyticsReporter].
  ///
  /// Call once at application startup before any log statements are issued.
  // ignore: use_setters_to_change_properties
  static void init({CrashlyticsReporter? crashlyticsReporter}) {
    _i._crashlyticsReporter = crashlyticsReporter;
  }

  /// Sets the active tag used to filter log output.
  ///
  /// When non-null, only messages whose tag matches this value are emitted.
  /// Set to `null` to disable tag filtering.
  static set tag(String? value) => _i._filter.tag = value;

  /// The currently active tag filter, or `null` if filtering is disabled.
  static String? get tag => _i._filter.tag;

  /// Emits one log line at every [LoggerLevel] to verify the full pipeline.
  ///
  /// Useful during development to confirm formatter, filter, and output
  /// are wired correctly.
  static void sample() {
    MyLogger.t('---------------------', showIcon: false);
    MyLogger.t('Trace Sample Message');
    MyLogger.d('Debug Sample Message');
    MyLogger.i('Info Sample Message');
    MyLogger.r('Refactor Sample Message');
    MyLogger.w('Warning Sample Message');
    MyLogger.c('Crashlytics Sample Message');
    MyLogger.e('Error Sample Message');
    MyLogger.f('Fatal Sample Message');
    MyLogger.o('Output Sample Message');
    MyLogger.t('---------------------', showIcon: false);
  }

  /// Core logging pipeline shared by all public log methods.
  ///
  /// Constructs a [_LogMessage], passes it through the filter, formats it,
  /// and delegates to the configured [_LogOutput]. Returns the formatted
  /// string, or an empty string if the filter suppressed the message.
  static String _log(
    LoggerLevel level,
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) {
    assert(
      frames >= _LogConstants.minFrames,
      'frames must be >= ${_LogConstants.minFrames}',
    );

    final logMessage = _LogMessage(
      level: level,
      message: message,
      tag: tag,
      time: time ?? DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      showIcon: showIcon,
      showColor: showColor,
      frames: frames,
    );

    if (!_i._filter.shouldLog(logMessage)) return '';

    final formatted = _i._formatter.format(logMessage);
    return _i._output.write(formatted, logMessage);
  }

  /// Logs a [LoggerLevel.trace] message.
  ///
  /// Use for fine-grained diagnostic output during active development.
  static String t(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.trace,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.debug] message.
  ///
  /// Use for information helpful when diagnosing unexpected behaviour.
  static String d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.debug,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.info] message.
  ///
  /// Use for high-level application lifecycle events and notable state changes.
  static String i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.info,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.refactor] message.
  ///
  /// Use as a temporary breadcrumb during active refactoring work; remove
  /// before merging.
  static String r(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.refactor,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.warning] message.
  ///
  /// Use when the application encounters a recoverable unexpected condition
  /// that does not require immediate action but should be investigated.
  static String w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.warning,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.crashlytics] message and forwards it to Crashlytics.
  ///
  /// Behaves identically to [e] but additionally calls
  /// [CrashlyticsReporter.report] when a reporter has been registered via
  /// [init]. Use for errors that must be captured in the crash-reporting
  /// pipeline even if they do not terminate the app.
  static String c(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) {
    final logged = _log(
      LoggerLevel.crashlytics,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      tag: tag,
      showIcon: showIcon,
      showColor: showColor,
      frames: frames,
    );
    _i._crashlyticsReporter?.report(logged, error, stackTrace);
    return logged;
  }

  /// Logs a [LoggerLevel.error] message.
  ///
  /// Use for caught exceptions and other conditions that indicate a failure
  /// in a discrete operation. Provide [error] and [stackTrace] whenever
  /// available.
  static String e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.error,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.fatal] message.
  ///
  /// Use when the application has entered an unrecoverable state. A fatal
  /// log should always be accompanied by [error] and [stackTrace].
  static String f(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.fatal,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );

  /// Logs a [LoggerLevel.output] message.
  ///
  /// Use to emit structured output intended for machine consumption or
  /// display in a developer console, distinct from diagnostic log noise.
  static String o(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
  }) => _log(
    LoggerLevel.output,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    tag: tag,
    showIcon: showIcon,
    showColor: showColor,
    frames: frames,
  );
}
