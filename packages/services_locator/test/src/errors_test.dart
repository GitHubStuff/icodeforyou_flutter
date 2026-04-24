// test/src/errors_test.dart
//
// Unit tests for the ServiceError sealed hierarchy.
//
// Coverage goals:
//   - Every concrete error constructs and carries the expected message.
//   - Every concrete error is both a ServiceError and a StateError.
//   - ServiceStartupFailed preserves its structured fields and overrides
//     toString() to include the cause stack trace.
//   - Messages contain the identifying name so they remain useful in logs.

import 'package:flutter_test/flutter_test.dart';
import 'package:services_locator/services_locator.dart';

void main() {
  group('ServiceError hierarchy', () {
    test('every concrete error is a ServiceError and a StateError', () {
      final errors = <ServiceError>[
        BlankServiceName(),
        DuplicateServiceEntry('x'),
        ServiceNotRegistered('x'),
        UnknownServiceEntry('x'),
        ServiceTypeMismatch('x', expected: int, actual: String),
        ServiceNotReady('x', status: 'waiting'),
        ServiceItemTimeout('x', const Duration(milliseconds: 100)),
        ServiceRegistrationError('x', cause: Exception('boom')),
        ServiceStartupFailed(
          'x',
          cause: Exception('boom'),
          causeStackTrace: StackTrace.current,
        ),
        InvalidStatusTransition('x', from: 'ready', to: 'waiting'),
        UnknownServiceStatus('x', status: 'mystery'),
      ];

      for (final error in errors) {
        expect(error, isA<ServiceError>());
        expect(error, isA<StateError>());
      }
    });
  });

  group('BlankServiceName', () {
    test('message explains that empty strings are invalid', () {
      final error = BlankServiceName();
      expect(
        error.message,
        'An empty string is not a valid service name',
      );
    });
  });

  group('DuplicateServiceEntry', () {
    test('message quotes the offending name', () {
      final error = DuplicateServiceEntry('database');
      expect(error.message, '"database" is already registered');
    });

    test('handles empty string without crashing', () {
      final error = DuplicateServiceEntry('');
      expect(error.message, '"" is already registered');
    });
  });

  group('ServiceNotRegistered', () {
    test('message quotes the missing name', () {
      final error = ServiceNotRegistered('database');
      expect(error.message, '"database" is not registered');
    });
  });

  group('UnknownServiceEntry', () {
    test('message distinguishes itself from ServiceNotRegistered', () {
      final error = UnknownServiceEntry('database');
      expect(error.message, 'Unknown service entry "database"');
    });
  });

  group('ServiceTypeMismatch', () {
    test('message includes name, expected, and actual types', () {
      final error = ServiceTypeMismatch(
        'database',
        expected: int,
        actual: String,
      );
      expect(
        error.message,
        'Type mismatch on "database": expected "int", actual "String"',
      );
    });

    test('handles same type on both sides (degenerate but legal)', () {
      final error = ServiceTypeMismatch(
        'database',
        expected: int,
        actual: int,
      );
      expect(
        error.message,
        'Type mismatch on "database": expected "int", actual "int"',
      );
    });
  });

  group('ServiceNotReady', () {
    test('message includes name and status', () {
      final error = ServiceNotReady('database', status: 'waiting');
      expect(error.message, '"database" is not ready (status: waiting)');
    });

    test('works for any status string', () {
      final error = ServiceNotReady('database', status: 'starting');
      expect(error.message, '"database" is not ready (status: starting)');
    });
  });

  group('ServiceItemTimeout', () {
    test('message reports timeout in milliseconds', () {
      final error = ServiceItemTimeout(
        'database',
        const Duration(milliseconds: 500),
      );
      expect(error.message, 'Timeout on service "database" after 500ms');
    });

    test('reports zero-duration timeouts correctly', () {
      final error = ServiceItemTimeout('database', Duration.zero);
      expect(error.message, 'Timeout on service "database" after 0ms');
    });

    test('converts larger durations to milliseconds', () {
      final error = ServiceItemTimeout(
        'database',
        const Duration(seconds: 2),
      );
      expect(error.message, 'Timeout on service "database" after 2000ms');
    });
  });

  group('ServiceRegistrationError', () {
    test('message includes name and stringified cause', () {
      final cause = Exception('disk full');
      final error = ServiceRegistrationError('database', cause: cause);
      expect(
        error.message,
        '"database" registration error: Exception: disk full',
      );
    });

    test('accepts non-Exception causes', () {
      final error = ServiceRegistrationError('database', cause: 'raw string');
      expect(
        error.message,
        '"database" registration error: raw string',
      );
    });
  });

  group('ServiceStartupFailed', () {
    test('message includes name and cause', () {
      final stackTrace = StackTrace.current;
      final error = ServiceStartupFailed(
        'database',
        cause: Exception('connection refused'),
        causeStackTrace: stackTrace,
      );
      expect(
        error.message,
        '"database" failed to start: Exception: connection refused',
      );
    });

    test('preserves the serviceName field', () {
      final error = ServiceStartupFailed(
        'database',
        cause: Exception('boom'),
        causeStackTrace: StackTrace.current,
      );
      expect(error.serviceName, 'database');
    });

    test('preserves the cause field as-is (identity)', () {
      final cause = Exception('connection refused');
      final error = ServiceStartupFailed(
        'database',
        cause: cause,
        causeStackTrace: StackTrace.current,
      );
      expect(identical(error.cause, cause), isTrue);
    });

    test('preserves the causeStackTrace field as-is (identity)', () {
      final stackTrace = StackTrace.current;
      final error = ServiceStartupFailed(
        'database',
        cause: Exception('boom'),
        causeStackTrace: stackTrace,
      );
      expect(identical(error.causeStackTrace, stackTrace), isTrue);
    });

    test('toString() includes the message and the stack trace', () {
      final stackTrace = StackTrace.fromString('frame0\nframe1\nframe2');
      final error = ServiceStartupFailed(
        'database',
        cause: Exception('connection refused'),
        causeStackTrace: stackTrace,
      );
      final rendered = error.toString();
      expect(rendered, contains('ServiceStartupFailed:'));
      expect(
        rendered,
        contains('"database" failed to start: Exception: connection refused'),
      );
      expect(rendered, contains('Caused by:'));
      expect(rendered, contains('frame0'));
      expect(rendered, contains('frame1'));
      expect(rendered, contains('frame2'));
    });

    test('toString() format: message then "Caused by:" then stack trace', () {
      final stackTrace = StackTrace.fromString('my-frame');
      final error = ServiceStartupFailed(
        'database',
        cause: Exception('boom'),
        causeStackTrace: stackTrace,
      );
      expect(
        error.toString(),
        'ServiceStartupFailed: "database" failed to start: Exception: boom\n'
        'Caused by:\n'
        'my-frame',
      );
    });
  });

  group('InvalidStatusTransition', () {
    test('message includes name, from, and to', () {
      final error = InvalidStatusTransition(
        'database',
        from: 'ready',
        to: 'waiting',
      );
      expect(
        error.message,
        '"database" cannot transition from "ready" to "waiting"',
      );
    });

    test('handles same from/to (degenerate but legal)', () {
      final error = InvalidStatusTransition(
        'database',
        from: 'ready',
        to: 'ready',
      );
      expect(
        error.message,
        '"database" cannot transition from "ready" to "ready"',
      );
    });
  });

  group('UnknownServiceStatus', () {
    test('message includes name and offending status', () {
      final error = UnknownServiceStatus('database', status: 'mystery');
      expect(error.message, '"database" is in unhandled status: "mystery"');
    });
  });

  group('throw/catch semantics', () {
    test('can be caught as ServiceError', () {
      expect(
        () => throw DuplicateServiceEntry('database'),
        throwsA(isA<ServiceError>()),
      );
    });

    test('can be caught as StateError', () {
      expect(
        () => throw DuplicateServiceEntry('database'),
        throwsA(isA<StateError>()),
      );
    });

    test('can be caught as the specific concrete subtype', () {
      expect(
        () => throw DuplicateServiceEntry('database'),
        throwsA(isA<DuplicateServiceEntry>()),
      );
    });

    test('sealed base cannot be confused with unrelated StateErrors', () {
      final stateError = StateError('something else');
      expect(stateError, isNot(isA<ServiceError>()));
    });
  });
}
