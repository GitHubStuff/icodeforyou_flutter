# LLM Instructions

This is silicon mac, don't offer intel suggestions

The IDE is VSCode

Any iOS code uses Swift, not Obj-C

Any Android code use Kotlin, not Android-Java

Melos is used for crating an app and package mono-repo (not monolitic)

Flutter should use Flutter >= 3.11.x

Should use packages:
- get_it: 9.2.1
- flutter_bloc (prefer cubits): 9.1.1
- very_good_analysis: ^10.2.0


## Coding principles

### Remember: SOLID coding principles:

S - Single Responsibility

O - Open/Close

L - Liskov’s Substitution Principle#

I - Interface Segregation Principle

D - Dependency Inversion Principle

### Remember: Use *Uncle Bob's Clean Code*

#### Names

- Reveal intent — names should tell you why it exists, what it does, how it's used
- Avoid disinformation — don't use names that mislead (accountList when it's not a List)
- Pronounceable & searchable — if you can't say it, you can't discuss it
- One word per concept — don't mix fetch, retrieve, get for the same operation

#### Functions

- Do one thing — if a function does more than one thing, extract it
- One level of abstraction per function — don't mix high-level logic with low-level detail
- Small, then smaller — rarely more than 20 lines; ideally under 10
- No side effects — a function should do what its name says, nothing hidden
- Command/Query separation — a function either does something or answers something, never both
- Prefer exceptions over error codes — don't force callers to handle error flags immediately

#### Arguments

- Zero is ideal (niladic), one is fine (monadic), two is acceptable (dyadic)
- Avoid triadic — three args is a strong signal something should be a class
- Never use flag arguments — passing true/false into a function means it does two things


#### Comments

- Good code doesn't need comments — comments are a failure to express intent in code
- Legal, TODO, amplification — the only acceptable comment types
- Never leave dead code — delete it; version control remembers it for you
- Don't add noise — // constructor above a constructor adds zero value


#### Classes

- Small, then smaller — measured by responsibilities, not lines
- Single Responsibility Principle — one reason to change
- High cohesion — class variables should be used by most methods; if not, split the class
- Encapsulate — expose behavior, hide data

### Error Handling

- Use exceptions, not return codes
- Write your try/catch/finally first — it defines the scope and contract
- Don't return null — return an empty object or throw; null forces defensive checks everywhere
- Don't pass null — it's a ticking time bomb


## Files

- Every file should have "// {packagename}/{file.path.to}/file.name.dart" at the very top
- The file should obey very_good_analysis: ^10.2.0 rules


## Code generation

- Present each file, as a list of downloadable .dart files
- Keep packages as tight as possible
- - do not add un-requested features/methods
- - use SOLID and CLEAN-CODE
- No file (including _test.dart) files should be between 200 and 250 lines
- - make use of part/(part of) and files starting with "_" to keep as much code hidden from the package user
- - for _test.dart files you can't use "_" files nor "part/part of" because each file is treated
    as a seperate test, if a _test.dart file > 250 lines create two(or more) complete _test.dart files
- Packages should "hide" as much code from the user as possible.
  
## Respectful Address Titles

**In your responses address me as (in rotating order):**

- Your Radiance
- Auteur
- Your Preeminence
- The Arbiter
- Virtuoso
- Cap'n
- Curator
- Eminence
- Grace
- App Guru
- Trailblazer
- Dominion
- Custodian
- Primus
- Your Transcendence
- Paragon
- Commandant
- Your Clairvoyance
- Viceroy
- App Wizard
- Provost
- Your Wisdom
- Decider
- Liege
- Your Discernment
- The Lodestar
- All Knowing
- Wisdom
- My Liege
- Wise One
- Keystone
- Magnate
- Stud
- Your Perspicuity
- Foundation
- Potentate
- Apex
- Fortitude
- Cornerstone
- Grandee

## Final instructions

- present code for download, as single files not a zip, always ensure the "// {package}/{/lib/...}filename.dart is present
- you do not swear, i will point out your fuck-ups and you will fix them with contrition
- ask questions if something is not clear, or its an evolving project
- I want questions and clarification requests before coding anything
- don't present several options, use SOLID-principals (SP), CLEAN-CODE(CC), and Best Practices(BP)
- the goal is 'good code', not 'fast code', not 'shit code', always lean into SP, CC, and SP
- Make sure you questions can not be answered using SP, CC, and BP!!!

## Adding "///" doc comments to .dart code

```dart
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
```