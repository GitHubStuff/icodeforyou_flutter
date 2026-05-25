// test/src/console/my_logger_test.dart

// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_logger/my_logger.dart';

// ---------------------------------------------------------------------------
// Test doubles — package-private seams are accessible via the part graph only
// from within the library. We test behaviour through the public API and the
// injectable constructor parameters exposed by MyLogger._.
// ---------------------------------------------------------------------------

class _FakeCrashlyticsReporter implements CrashlyticsReporter {
  String? lastMessage;
  Object? lastError;
  StackTrace? lastStackTrace;

  @override
  void report(String message, Object? error, StackTrace? stackTrace) {
    lastMessage = message;
    lastError = error;
    lastStackTrace = stackTrace;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _resetSingleton() {
  MyLogger.resetForTesting();
}

void main() {
  setUp(_resetSingleton);

  // -------------------------------------------------------------------------
  // LoggerLevel
  // -------------------------------------------------------------------------
  group('LoggerLevel', () {
    test('has 10 values', () {
      expect(LoggerLevel.values, hasLength(10));
    });

    test('value ordering is correct', () {
      expect(LoggerLevel.all.value, 0);
      expect(LoggerLevel.trace.value, 1000);
      expect(LoggerLevel.debug.value, 2000);
      expect(LoggerLevel.info.value, 3000);
      expect(LoggerLevel.refactor.value, 4000);
      expect(LoggerLevel.warning.value, 5000);
      expect(LoggerLevel.crashlytics.value, 6000);
      expect(LoggerLevel.error.value, 7000);
      expect(LoggerLevel.fatal.value, 8000);
      expect(LoggerLevel.output.value, 9000);
    });

    test('icon is non-empty for levels with icons', () {
      expect(LoggerLevel.trace.icon, isNotEmpty);
      expect(LoggerLevel.debug.icon, isNotEmpty);
      expect(LoggerLevel.all.icon, isEmpty);
    });

    test('color is non-empty for every level', () {
      for (final level in LoggerLevel.values) {
        expect(level.color, isNotEmpty);
      }
    });

    test('fat flag is set correctly', () {
      expect(LoggerLevel.trace.fat, isTrue);
      expect(LoggerLevel.debug.fat, isTrue);
      expect(LoggerLevel.info.fat, isFalse);
      expect(LoggerLevel.all.fat, isFalse);
    });

    group('operator <', () {
      test('returns true when left is lower', () {
        expect(LoggerLevel.trace < LoggerLevel.debug, isTrue);
      });
      test('returns false when left is higher', () {
        expect(LoggerLevel.debug < LoggerLevel.trace, isFalse);
      });
      test('returns false when equal', () {
        expect(LoggerLevel.debug < LoggerLevel.debug, isFalse);
      });
    });

    group('operator <=', () {
      test('returns true when left is lower', () {
        expect(LoggerLevel.trace <= LoggerLevel.debug, isTrue);
      });
      test('returns true when equal', () {
        expect(LoggerLevel.debug <= LoggerLevel.debug, isTrue);
      });
      test('returns false when left is higher', () {
        expect(LoggerLevel.debug <= LoggerLevel.trace, isFalse);
      });
    });

    group('operator >', () {
      test('returns true when left is higher', () {
        expect(LoggerLevel.debug > LoggerLevel.trace, isTrue);
      });
      test('returns false when left is lower', () {
        expect(LoggerLevel.trace > LoggerLevel.debug, isFalse);
      });
      test('returns false when equal', () {
        expect(LoggerLevel.debug > LoggerLevel.debug, isFalse);
      });
    });

    group('operator >=', () {
      test('returns true when left is higher', () {
        expect(LoggerLevel.debug >= LoggerLevel.trace, isTrue);
      });
      test('returns true when equal', () {
        expect(LoggerLevel.debug >= LoggerLevel.debug, isTrue);
      });
      test('returns false when left is lower', () {
        expect(LoggerLevel.trace >= LoggerLevel.debug, isFalse);
      });
    });
  });

  // -------------------------------------------------------------------------
  // MyLogger — singleton
  // -------------------------------------------------------------------------
  group('MyLogger singleton', () {
    test('sample() runs without throwing', () {
      expect(() => MyLogger.sample(), returnsNormally);
    });

    test('tag setter and getter round-trip', () {
      MyLogger.tag = 'auth';
      expect(MyLogger.tag, 'auth');
    });

    test('tag = null clears the filter', () {
      MyLogger.tag = 'auth';
      MyLogger.tag = null;
      expect(MyLogger.tag, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // MyLogger — init / CrashlyticsReporter
  // -------------------------------------------------------------------------
  group('MyLogger.init', () {
    test('c() does not throw when no reporter is registered', () {
      expect(() => MyLogger.c('boom'), returnsNormally);
    });

    test('c() calls reporter.report when reporter is registered', () {
      final reporter = _FakeCrashlyticsReporter();
      MyLogger.init(crashlyticsReporter: reporter);

      final error = Exception('test');
      final trace = StackTrace.current;
      MyLogger.c('crash msg', error: error, stackTrace: trace);

      expect(reporter.lastMessage, isNotNull);
      expect(reporter.lastError, error);
      expect(reporter.lastStackTrace, trace);

      // Cleanup — remove reporter for subsequent tests.
      MyLogger.init();
    });

    test('c() does not call reporter after init() with null', () {
      final reporter = _FakeCrashlyticsReporter();
      MyLogger.init(crashlyticsReporter: reporter);
      MyLogger.init();
      MyLogger.c('no reporter now');
      expect(reporter.lastMessage, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // MyLogger — tag filter
  // -------------------------------------------------------------------------
  group('MyLogger tag filter', () {
    test('logs below warning are suppressed when tag does not match', () {
      MyLogger.tag = 'network';
      final result = MyLogger.d('filtered out', tag: 'auth');
      expect(result, isEmpty);
    });

    test('logs below warning pass when tag matches', () {
      MyLogger.tag = 'auth';
      final result = MyLogger.d('visible', tag: 'auth');
      expect(result, isNotEmpty);
    });

    test('warning and above always pass regardless of tag filter', () {
      MyLogger.tag = 'network';
      final result = MyLogger.w('always visible', tag: 'auth');
      expect(result, isNotEmpty);
    });

    test('logs pass when no tag filter is set', () {
      MyLogger.tag = null;
      final result = MyLogger.d('no filter');
      expect(result, isNotEmpty);
    });

    test('empty tag normalizes to default tag log', () {
      MyLogger.tag = 'log';
      final result = MyLogger.d('default tag', tag: '');
      expect(result, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // MyLogger — convenience methods
  // -------------------------------------------------------------------------
  group('MyLogger convenience methods', () {
    test('t() returns non-empty string', () {
      expect(MyLogger.t('trace'), isNotEmpty);
    });

    test('d() returns non-empty string', () {
      expect(MyLogger.d('debug'), isNotEmpty);
    });

    test('i() returns non-empty string', () {
      expect(MyLogger.i('info'), isNotEmpty);
    });

    test('r() returns non-empty string', () {
      expect(MyLogger.r('refactor'), isNotEmpty);
    });

    test('w() returns non-empty string', () {
      expect(MyLogger.w('warning'), isNotEmpty);
    });

    test('c() returns non-empty string', () {
      expect(MyLogger.c('crashlytics'), isNotEmpty);
    });

    test('e() returns non-empty string', () {
      expect(MyLogger.e('error'), isNotEmpty);
    });

    test('f() returns non-empty string', () {
      expect(MyLogger.f('fatal'), isNotEmpty);
    });

    test('o() returns non-empty string', () {
      expect(MyLogger.o('output'), isNotEmpty);
    });

    test('showIcon=false suppresses icon', () {
      final withIcon = MyLogger.t('msg', showIcon: true);
      final withoutIcon = MyLogger.t('msg', showIcon: false);
      expect(withIcon.length, greaterThan(withoutIcon.length));
    });

    test('showColor=false omits ANSI codes', () {
      final result = MyLogger.d('msg', showColor: false);
      expect(result, isNot(contains('\x1B[')));
    });

    test('showColor=true includes ANSI codes', () {
      final result = MyLogger.d('msg', showColor: true);
      expect(result, contains('\x1B['));
    });

    test('custom tag is accepted without throwing', () {
      final result = MyLogger.e('msg', tag: 'mytag', showColor: false);
      expect(result, isNotEmpty);
    });

    test('custom time is used', () {
      final time = DateTime(2024, 6, 1, 9, 5, 3, 7);
      final result = MyLogger.i('msg', time: time, showColor: false);
      expect(result, contains('09:05:03.007'));
    });

    test('frames=1 with stackTrace includes stack in output', () {
      final result = MyLogger.e(
        'with stack',
        stackTrace: StackTrace.current,
        frames: 1,
        showColor: false,
      );
      expect(result, contains('\n'));
    });

    test('frames>1 with stackTrace formats multiple frames', () {
      final result = MyLogger.e(
        'multi frame',
        stackTrace: StackTrace.current,
        frames: 3,
        showColor: false,
      );
      expect(result, contains('StackTrace('));
    });

    test('frames>1 with stackTrace and showColor=true includes ANSI', () {
      final result = MyLogger.e(
        'multi frame colored',
        stackTrace: StackTrace.current,
        frames: 3,
        showColor: true,
      );
      expect(result, contains('\x1B['));
    });

    test('frames=1 with showColor=true colors the single frame', () {
      final result = MyLogger.e(
        'single frame colored',
        stackTrace: StackTrace.current,
        frames: 1,
        showColor: true,
      );
      expect(result, contains('\x1B[31m'));
    });
  });

  // -------------------------------------------------------------------------
  // MyLogger — _log with error
  // -------------------------------------------------------------------------
  group('MyLogger _log with error object', () {
    test('error object is passed through', () {
      final result = MyLogger.e(
        'error msg',
        error: Exception('oops'),
        showColor: false,
      );
      expect(result, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // CrashlyticsReporter contract
  // -------------------------------------------------------------------------
  group('CrashlyticsReporter', () {
    test('concrete implementation can be instantiated', () {
      final reporter = _FakeCrashlyticsReporter();
      expect(reporter, isA<CrashlyticsReporter>());
    });

    test('report() receives correct arguments', () {
      final reporter = _FakeCrashlyticsReporter();
      final error = Exception('x');
      final trace = StackTrace.current;
      reporter.report('msg', error, trace);
      expect(reporter.lastMessage, 'msg');
      expect(reporter.lastError, error);
      expect(reporter.lastStackTrace, trace);
    });
  });

  // -------------------------------------------------------------------------
  // _ReleaseLogOutput — exercised via overrideForTesting
  // -------------------------------------------------------------------------
  group('_ReleaseLogOutput', () {
    tearDown(() {
      // Restore default singleton after each override test.
      MyLogger.resetForTesting();
    });

    test('write without error returns [tag] message and prints it', () {
      final printed = <String>[];
      MyLogger.overrideForTesting(useReleaseOutput: true);

      runZoned(
        () => MyLogger.d('hello', tag: 'test', showColor: false),
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => printed.add(line),
        ),
      );

      expect(printed, hasLength(1));
      expect(printed.first, contains('[test]'));
      expect(printed.first, contains('hello'));
    });

    test('write with error appends error line', () {
      final printed = <String>[];
      MyLogger.overrideForTesting(useReleaseOutput: true);

      runZoned(
        () => MyLogger.e(
          'boom',
          tag: 'test',
          error: Exception('oops'),
          showColor: false,
        ),
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => printed.add(line),
        ),
      );

      expect(printed, hasLength(1));
      expect(printed.first, contains('Error:'));
    });
  });
}
