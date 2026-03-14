// Original THDLog class - monolithic design with multiple responsibilities
// New design - separated concerns following SOLID principles with minimal
// public API

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart'
    show debugPrint, kDebugMode, kReleaseMode;
import 'package:my_logger/my_logger.dart' show LoggerLevel;

part 'debug_log_output.dart';
part 'default_log_filter.dart';
part 'default_log_formatter.dart';
part 'log_abstracts.dart';
part 'log_constants.dart';
part 'log_formatters.dart';
part 'log_message.dart';
part 'release_log_output.dart';

class MyLogger {

  factory MyLogger() => _instance ??= MyLogger._();

  MyLogger._({
    _LogFormatter? formatter,
    _LogOutput? output,
    _DefaultLogFilter? filter,
  }) : _formatter = formatter ?? _DefaultLogFormatter(),
       // Debug mode: kDebugMode=true, kProfileMode=false, kReleaseMode=false
       // Profile mode: kDebugMode=false, kProfileMode=true, kReleaseMode=false
       // Release mode: kDebugMode=false, kProfileMode=false, kReleaseMode=true
       _output = output ?? _getLogOutput(),
       _filter = filter ?? _DefaultLogFilter();
  static MyLogger? _instance;

  final _LogFormatter _formatter;
  final _LogOutput _output;
  final _DefaultLogFilter _filter;

  /// Determines the appropriate log output based on Flutter build mode
  static _LogOutput _getLogOutput() {
    if (kReleaseMode) {
      return _ReleaseLogOutput(); // Only in actual release builds
    } else {
      return _DebugLogOutput(); // Both debug AND profile modes show in IDE
    }
  }

  static void sample() {
    MyLogger.t('---------------------', showIcon: false);
    MyLogger.t('Trace Sample Message');
    MyLogger.d('Debug Sample Message');
    MyLogger.i('Info Sample Message');
    MyLogger.r('Refactor Sample Message');
    MyLogger.w('Warning Sample Message');
    MyLogger.c('Crashlytics Sample Message', sendToCrashlytics: false);
    MyLogger.e('Error Sample Message');
    MyLogger.f('Fatal Sample Message');
    MyLogger.o('Output Sample Message');
    MyLogger.t('---------------------', showIcon: false);
  }

  /// Sets a tag filter - only logs with matching tags will be displayed
  static void setTag(String tag) {
    final instance = MyLogger();
    instance._filter.setTag(tag);
  }

  /// Clears the tag filter - all logs will be displayed regardless of tag
  static void clearTag() {
    final instance = MyLogger();
    instance._filter.setTag(null);
  }

  /// Gets the current tag filter, returns null if no filter is set
  static String? get currentTagFilter {
    final instance = MyLogger();
    return instance._filter.currentTag;
  }

  /// For migrating... this method only exists to run message in parallel
  /// as debugPrint() is phased out.
  static void debug(String msg) => debugPrint('🐞 $msg');

  /// Logs a message with the specified level and optional parameters
  /// Returns the string that was sent to developer.log() or print()
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

    final instance = MyLogger();

    if (!instance._filter.shouldLog(logMessage)) return '';

    final formattedMessage = instance._formatter.format(logMessage);
    return instance._output.write(formattedMessage, logMessage);
  }

  // Single-letter convenience methods
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

  static String c(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    String tag = '',
    bool showIcon = true,
    bool showColor = true,
    int frames = 1,
    bool sendToCrashlytics = true,
  }) {
    final log = _log(
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
    if (sendToCrashlytics) {
      // When crashlytics is done
    }
    return log;
  }

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
