// lib/src/console/my_logger.dart

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

class MyLogger {
  MyLogger._({
    _LogFormatter? formatter,
    _LogOutput? output,
    _DefaultLogFilter? filter,
  })  : _formatter = formatter ?? const _DefaultLogFormatter(),
        _output = output ??
            (kReleaseMode
                ? const _ReleaseLogOutput()
                : const _DebugLogOutput()),
        _filter = filter ?? _DefaultLogFilter();

  @visibleForTesting
  static void overrideForTesting({bool useReleaseOutput = false}) {
    _instance = MyLogger._(
      output: useReleaseOutput
          ? const _ReleaseLogOutput()
          : const _DebugLogOutput(),
    );
  }

  @visibleForTesting
  static void resetForTesting() => _instance = null;

  static MyLogger? _instance;

  final _LogFormatter _formatter;
  final _LogOutput _output;
  final _DefaultLogFilter _filter;
  CrashlyticsReporter? _crashlyticsReporter;

  // ignore: prefer_constructors_over_static_methods
  static MyLogger get _i => _instance ??= MyLogger._();

  // ignore: use_setters_to_change_properties
  static void init({CrashlyticsReporter? crashlyticsReporter}) {
    _i._crashlyticsReporter = crashlyticsReporter;
  }

  static set tag(String? value) => _i._filter.tag = value;
  static String? get tag => _i._filter.tag;

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
