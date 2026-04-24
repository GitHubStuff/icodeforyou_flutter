// packages/services_locator/test/src/service_locator_registry/service_registration_test.dart
//
// Full-coverage test suite for [ServiceRegistration]. Exercises every
// state transition, every convenience getter, both toString branches,
// and the assertion in asStartupFailed.

// ignore_for_file: cascade_invocations, document_ignores

import 'package:flutter_test/flutter_test.dart';
import 'package:services_locator/src/errors.dart' show ServiceStartupFailed;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, SyncServiceDescriptor;
import 'package:services_locator/src/service_locator_registry/service_registration.dart'
    show ServiceRegistration;

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

abstract interface class _AuthService implements ServiceClass {
  String get token;
}

class _FakeAuth implements _AuthService {
  _FakeAuth(this.token);
  @override
  final String token;
}

class _AuthDescriptor extends SyncServiceDescriptor<_AuthService> {
  const _AuthDescriptor({this.descriptorName = 'auth'});

  final String descriptorName;

  @override
  String get name => descriptorName;

  @override
  _AuthService Function() get builder =>
      () => _FakeAuth('built');
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _authName = 'auth';

void main() {
  late ServiceRegistration<_AuthService> registration;

  setUp(() {
    registration = ServiceRegistration<_AuthService>(const _AuthDescriptor());
  });

  // ---------------------------------------------------------------------------
  // Construction + initial state
  // ---------------------------------------------------------------------------

  group('initial state', () {
    test('status starts as staged', () {
      expect(registration.status, LocatorStatus.staged);
    });

    test('instance starts as null', () {
      expect(registration.instance, isNull);
    });

    test('error starts as null', () {
      expect(registration.error, isNull);
    });

    test('stackTrace starts as null', () {
      expect(registration.stackTrace, isNull);
    });

    test('pendingStart starts as null', () {
      expect(registration.pendingStart, isNull);
    });

    test('name is derived from the descriptor', () {
      expect(registration.name, _authName);
    });

    test('descriptor is exposed as provided', () {
      expect(registration.descriptor, isA<_AuthDescriptor>());
    });
  });

  // ---------------------------------------------------------------------------
  // Convenience status getters
  // ---------------------------------------------------------------------------

  group('status convenience getters', () {
    test('isStaged is true initially, others are false', () {
      expect(registration.isStaged, isTrue);
      expect(registration.isStarting, isFalse);
      expect(registration.isReady, isFalse);
      expect(registration.isFailed, isFalse);
    });

    test('isStarting is true after markStarting', () {
      registration.markStarting(Future<void>.value());

      expect(registration.isStarting, isTrue);
      expect(registration.isStaged, isFalse);
      expect(registration.isReady, isFalse);
      expect(registration.isFailed, isFalse);
    });

    test('isStarting is true after markStartingReported', () {
      registration.markStartingReported();

      expect(registration.isStarting, isTrue);
      expect(registration.isStaged, isFalse);
      expect(registration.isReady, isFalse);
      expect(registration.isFailed, isFalse);
    });

    test('isReady is true after markReady', () {
      registration.markReady(_FakeAuth('ready'));

      expect(registration.isReady, isTrue);
      expect(registration.isStaged, isFalse);
      expect(registration.isStarting, isFalse);
      expect(registration.isFailed, isFalse);
    });

    test('isFailed is true after markFailed', () {
      registration.markFailed(StateError('boom'), StackTrace.current);

      expect(registration.isFailed, isTrue);
      expect(registration.isStaged, isFalse);
      expect(registration.isStarting, isFalse);
      expect(registration.isReady, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // markStarting
  // ---------------------------------------------------------------------------

  group('markStarting', () {
    test('transitions status to starting', () {
      registration.markStarting(Future<void>.value());
      expect(registration.status, LocatorStatus.starting);
    });

    test('stores the pending future', () {
      final pending = Future<void>.value();
      registration.markStarting(pending);
      expect(registration.pendingStart, same(pending));
    });
  });

  // ---------------------------------------------------------------------------
  // markStartingReported
  // ---------------------------------------------------------------------------

  group('markStartingReported', () {
    test('transitions status to starting', () {
      registration.markStartingReported();
      expect(registration.status, LocatorStatus.starting);
    });

    test('does not set pendingStart', () {
      registration.markStartingReported();
      expect(registration.pendingStart, isNull);
    });

    test('does not clear a previously-set pendingStart', () {
      // If the registry already set a pendingStart via markStarting and the
      // locator later reports its own starting, the registry's pendingStart
      // should remain intact so concurrent awaiters still resolve correctly.
      final pending = Future<void>.value();
      registration.markStarting(pending);

      registration.markStartingReported();

      expect(registration.pendingStart, same(pending));
    });
  });

  // ---------------------------------------------------------------------------
  // markReady
  // ---------------------------------------------------------------------------

  group('markReady', () {
    test('transitions status to ready', () {
      registration.markReady(_FakeAuth('x'));
      expect(registration.status, LocatorStatus.ready);
    });

    test('stores the instance', () {
      final instance = _FakeAuth('stored');
      registration.markReady(instance);
      expect(registration.instance, same(instance));
    });

    test('clears any previously-recorded error', () {
      registration.markFailed(StateError('was failing'), StackTrace.current);
      expect(registration.error, isNotNull);
      expect(registration.stackTrace, isNotNull);

      registration.markReady(_FakeAuth('recovered'));

      expect(registration.error, isNull);
      expect(registration.stackTrace, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // markFailed
  // ---------------------------------------------------------------------------

  group('markFailed', () {
    test('transitions status to failed', () {
      registration.markFailed(StateError('boom'), StackTrace.current);
      expect(registration.status, LocatorStatus.failed);
    });

    test('stores the error', () {
      final error = StateError('stored error');
      registration.markFailed(error, StackTrace.current);
      expect(registration.error, same(error));
    });

    test('stores the stack trace', () {
      final stack = StackTrace.current;
      registration.markFailed(StateError('x'), stack);
      expect(registration.stackTrace, same(stack));
    });
  });

  // ---------------------------------------------------------------------------
  // asStartupFailed
  // ---------------------------------------------------------------------------

  group('asStartupFailed', () {
    test('builds a ServiceStartupFailed from the recorded error', () {
      final error = StateError('root cause');
      final stack = StackTrace.current;
      registration.markFailed(error, stack);

      final exception = registration.asStartupFailed();

      expect(exception, isA<ServiceStartupFailed>());
      expect(exception.cause, same(error));
      expect(exception.causeStackTrace, same(stack));
    });

    test('asserts in debug builds when called on a staged registration', () {
      expect(
        registration.asStartupFailed,
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts in debug builds when called on a starting registration', () {
      registration.markStarting(Future<void>.value());

      expect(
        registration.asStartupFailed,
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts in debug builds when called on a ready registration', () {
      registration.markReady(_FakeAuth('ready'));

      expect(
        registration.asStartupFailed,
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // toString
  // ---------------------------------------------------------------------------

  group('toString', () {
    test('reports name and status when staged (no instance, no error)', () {
      expect(registration.toString(), 'auth [staged]');
    });

    test('appends ✓ when an instance is present', () {
      registration.markReady(_FakeAuth('ready'));

      expect(registration.toString(), 'auth [ready] ✓');
    });

    test('appends ✗ and the error when an error is present', () {
      registration.markFailed(StateError('kaboom'), StackTrace.current);

      final out = registration.toString();
      expect(out, startsWith('auth [failed] ✗ '));
      expect(out, contains('kaboom'));
    });

    test(
      'reflects the descriptor name when it differs from the default',
      () {
        final custom = ServiceRegistration<_AuthService>(
          const _AuthDescriptor(descriptorName: 'custom-name'),
        );

        expect(custom.toString(), 'custom-name [staged]');
      },
    );
  });
}
