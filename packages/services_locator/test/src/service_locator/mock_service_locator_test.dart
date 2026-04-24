// packages/services_locator/test/src/service_locator/mock_service_locator_test.dart
//
// Full-coverage test suite for [MockServiceLocator]. Exercises every branch:
// registration (lazy + sync), duplicate detection, type-keying, sync/async
// retrieval, timeout, builder success, builder failure, manual completion,
// manual failure, race guards (hook wins over builder, hook-after-error),
// idempotent hooks, reset, and introspection.

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:services_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotReady, ServiceNotRegistered;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:services_locator/src/service_locator/mock_service_locator.dart'
    show MockServiceLocator;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState;

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

abstract interface class _LogService implements ServiceClass {
  void log(String message);
}

class _FakeLog implements _LogService {
  @override
  void log(String message) {}
}

/// Captures [ReportServiceState] invocations for assertions.
class _StateRecorder {
  final List<({LocatorStatus status, Object? instance})> events = [];

  void call(LocatorStatus status, {Object? instance}) {
    events.add((status: status, instance: instance));
  }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _shortTimeout = Duration(milliseconds: 50);
const _longTimeout = Duration(seconds: 5);
const _authName = 'auth';
const _logName = 'log';
const _altName = 'alt';

void main() {
  late MockServiceLocator locator;

  setUp(() => locator = MockServiceLocator());

  // ---------------------------------------------------------------------------
  // Sync registration + retrieval
  // ---------------------------------------------------------------------------

  group('registerServiceSync', () {
    test('registers and returns the instance', () {
      final auth = _FakeAuth('abc');
      final returned = locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: auth,
      );

      expect(returned, same(auth));
    });

    test('makes service immediately available via getServiceSync', () {
      final auth = _FakeAuth('abc');
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: auth,
      );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName),
        same(auth),
      );
    });

    test('makes service immediately available via getServiceAsync', () async {
      final auth = _FakeAuth('abc');
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: auth,
      );

      final resolved = await locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );
      expect(resolved, same(auth));
    });

    test('throws DuplicateServiceEntry on same type + name', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('first'),
      );

      expect(
        () => locator.registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('second'),
        ),
        throwsA(isA<DuplicateServiceEntry>()),
      );
    });

    test('allows same name under a different type', () {
      locator
        ..registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('a'),
        )
        ..registerServiceSync<_LogService>(
          name: _authName,
          instance: _FakeLog(),
        );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName),
        isA<_FakeAuth>(),
      );
      expect(
        locator.getServiceSync<_LogService>(name: _authName),
        isA<_FakeLog>(),
      );
    });

    test('allows same type under a different name', () {
      locator
        ..registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('a'),
        )
        ..registerServiceSync<_AuthService>(
          name: _altName,
          instance: _FakeAuth('b'),
        );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName).token,
        'a',
      );
      expect(
        locator.getServiceSync<_AuthService>(name: _altName).token,
        'b',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Lazy async registration
  // ---------------------------------------------------------------------------

  group('registerServiceLazyAsync', () {
    test('emits LocatorStatus.starting synchronously', () {
      final recorder = _StateRecorder();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('x'),
        serviceState: recorder.call,
      );

      expect(recorder.events, hasLength(1));
      expect(recorder.events.single.status, LocatorStatus.starting);
      expect(recorder.events.single.instance, isNull);
    });

    test('throws DuplicateServiceEntry on same type + name', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('x'),
        serviceState: _StateRecorder().call,
      );

      expect(
        () => locator.registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => _FakeAuth('y'),
          serviceState: _StateRecorder().call,
        ),
        throwsA(isA<DuplicateServiceEntry>()),
      );
    });

    test('builder runs on first getServiceAsync and emits ready', () async {
      final recorder = _StateRecorder();
      final auth = _FakeAuth('built');
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => auth,
        serviceState: recorder.call,
      );

      final resolved = await locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      expect(resolved, same(auth));
      expect(recorder.events, hasLength(2));
      expect(recorder.events.last.status, LocatorStatus.ready);
      expect(recorder.events.last.instance, same(auth));
    });

    test(
      'builder runs exactly once under concurrent getServiceAsync',
      () async {
        var buildCount = 0;
        final gate = Completer<_AuthService>();
        locator.registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async {
            buildCount++;
            return gate.future;
          },
          serviceState: _StateRecorder().call,
        );

        final f1 = locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _longTimeout,
        );
        final f2 = locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _longTimeout,
        );

        gate.complete(_FakeAuth('once'));
        final results = await Future.wait<_AuthService>([f1, f2]);

        expect(buildCount, 1);
        expect(results[0], same(results[1]));
      },
    );

    test('getServiceAsync returns cached instance once ready', () async {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('cached'),
        serviceState: _StateRecorder().call,
      );

      final first = await locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );
      final second = await locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      expect(first, same(second));
    });

    test('getServiceSync after builder completes returns instance', () async {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('ready'),
        serviceState: _StateRecorder().call,
      );

      await locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName).token,
        'ready',
      );
    });

    test('getServiceSync before ready throws ServiceNotReady', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('slow'),
        serviceState: _StateRecorder().call,
      );

      expect(
        () => locator.getServiceSync<_AuthService>(name: _authName),
        throwsA(isA<ServiceNotReady>()),
      );
    });

    test('getServiceAsync throws ServiceNotReady on timeout', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: _StateRecorder().call,
      );

      expect(
        () => locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _shortTimeout,
        ),
        throwsA(isA<ServiceNotReady>()),
      );
    });

    test('getServiceAsync rethrows when builder throws', () async {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => throw StateError('boom'),
        serviceState: _StateRecorder().call,
      );

      await expectLater(
        locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _longTimeout,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Unregistered paths
  // ---------------------------------------------------------------------------

  group('unregistered access', () {
    test('getServiceSync throws ServiceNotRegistered', () {
      expect(
        () => locator.getServiceSync<_AuthService>(name: _authName),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('getServiceAsync throws ServiceNotRegistered', () {
      expect(
        () => locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _longTimeout,
        ),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('completeLazyService throws ServiceNotRegistered', () {
      expect(
        () => locator.completeLazyService<_AuthService>(
          name: _authName,
          instance: _FakeAuth('x'),
        ),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('failLazyService throws ServiceNotRegistered', () {
      expect(
        () => locator.failLazyService<_AuthService>(
          name: _authName,
          error: StateError('nope'),
        ),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Test hooks: completeLazyService
  // ---------------------------------------------------------------------------

  group('completeLazyService', () {
    test('satisfies awaiters without invoking builder', () async {
      final recorder = _StateRecorder();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => throw StateError('builder must not run'),
        serviceState: recorder.call,
      );

      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      final injected = _FakeAuth('injected');
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: injected,
      );

      expect(await pending, same(injected));
      expect(recorder.events.last.status, LocatorStatus.ready);
      expect(recorder.events.last.instance, same(injected));
    });

    test('is idempotent when already ready (isReady guard)', () {
      final recorder = _StateRecorder();
      locator
        ..registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => _FakeAuth('irrelevant'),
          serviceState: recorder.call,
        )
        ..completeLazyService<_AuthService>(
          name: _authName,
          instance: _FakeAuth('first'),
        );
      final readyEventsAfterFirst = recorder.events
          .where((e) => e.status == LocatorStatus.ready)
          .length;

      // Second call must not throw and must not emit another ready event.
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: _FakeAuth('second'),
      );
      final readyEventsAfterSecond = recorder.events
          .where((e) => e.status == LocatorStatus.ready)
          .length;

      expect(readyEventsAfterFirst, 1);
      expect(readyEventsAfterSecond, 1);
    });

    test('makes getServiceSync succeed', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('unused'),
        serviceState: _StateRecorder().call,
      );

      final injected = _FakeAuth('sync-ready');
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: injected,
      );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName),
        same(injected),
      );
    });

    test('hook completion wins over a builder that later succeeds', () async {
      final recorder = _StateRecorder();
      final gate = Completer<_AuthService>();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => gate.future, // stays in flight until released
        serviceState: recorder.call,
      );

      // Start the builder by calling getServiceAsync, then resolve via hook.
      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      final injected = _FakeAuth('hook-wins');
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: injected,
      );

      expect(await pending, same(injected));

      // Now release the builder. Its result must be dropped by the race guard
      // in _maybeStartBuilder.run's success branch — no second ready event,
      // no "Bad state: Future already completed".
      gate.complete(_FakeAuth('ignored'));
      await Future<void>.delayed(Duration.zero);

      final readyEvents = recorder.events
          .where((e) => e.status == LocatorStatus.ready)
          .toList();
      expect(readyEvents, hasLength(1));
      expect(readyEvents.single.instance, same(injected));
      expect(
        locator.getServiceSync<_AuthService>(name: _authName),
        same(injected),
      );
    });

    test('hook completion wins over a builder that later throws', () async {
      final recorder = _StateRecorder();
      final gate = Completer<_AuthService>();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async {
          await gate.future;
          throw StateError('builder threw after hook resolved');
        },
        serviceState: recorder.call,
      );

      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      final injected = _FakeAuth('hook-wins');
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: injected,
      );

      expect(await pending, same(injected));

      // Release the builder so its throw reaches the error-branch race guard.
      gate.complete(_FakeAuth('ignored'));
      await Future<void>.delayed(Duration.zero);

      final readyEvents = recorder.events
          .where((e) => e.status == LocatorStatus.ready)
          .toList();
      expect(readyEvents, hasLength(1));
      expect(readyEvents.single.instance, same(injected));
    });
  });

  // ---------------------------------------------------------------------------
  // Test hooks: failLazyService
  // ---------------------------------------------------------------------------

  group('failLazyService', () {
    test('propagates error to pending awaiters', () async {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: _StateRecorder().call,
      );

      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      final error = StateError('injected failure');
      locator.failLazyService<_AuthService>(name: _authName, error: error);

      await expectLater(pending, throwsA(same(error)));
    });

    test('is a no-op when already ready (isReady guard)', () {
      locator
        ..registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => _FakeAuth('done'),
          serviceState: _StateRecorder().call,
        )
        ..completeLazyService<_AuthService>(
          name: _authName,
          instance: _FakeAuth('done'),
        );

      expect(
        () => locator.failLazyService<_AuthService>(
          name: _authName,
          error: StateError('late'),
        ),
        returnsNormally,
      );
    });

    test(
      'is a no-op when completer already errored (isCompleted guard)',
      () async {
        locator.registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => throw StateError('first'),
          serviceState: _StateRecorder().call,
        );

        // Drive the builder to error, completing the completer but leaving
        // isReady == false. This is the only path that reaches the
        // `entry.completer!.isCompleted` guard in failLazyService.
        await expectLater(
          locator.getServiceAsync<_AuthService>(
            name: _authName,
            timeout: _longTimeout,
          ),
          throwsA(isA<StateError>()),
        );

        expect(
          () => locator.failLazyService<_AuthService>(
            name: _authName,
            error: StateError('second'),
          ),
          returnsNormally,
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Introspection + reset
  // ---------------------------------------------------------------------------

  group('isRegistered', () {
    test('returns false when nothing is registered', () {
      expect(
        locator.isRegistered<_AuthService>(name: _authName),
        isFalse,
      );
    });

    test('returns true after sync registration', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('x'),
      );
      expect(locator.isRegistered<_AuthService>(name: _authName), isTrue);
    });

    test('returns true after lazy async registration', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('x'),
        serviceState: _StateRecorder().call,
      );
      expect(locator.isRegistered<_AuthService>(name: _authName), isTrue);
    });

    test('discriminates by type and name', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('x'),
      );
      expect(locator.isRegistered<_LogService>(name: _authName), isFalse);
      expect(locator.isRegistered<_AuthService>(name: _altName), isFalse);
    });
  });

  group('reset', () {
    test('clears every registration', () {
      locator
        ..registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('x'),
        )
        ..registerServiceLazyAsync<_LogService>(
          name: _logName,
          builder: () async => _FakeLog(),
          serviceState: _StateRecorder().call,
        )
        ..reset();

      expect(locator.isRegistered<_AuthService>(name: _authName), isFalse);
      expect(locator.isRegistered<_LogService>(name: _logName), isFalse);
    });

    test('allows re-registration of the same key after clearing', () {
      locator
        ..registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('first'),
        )
        ..reset()
        ..registerServiceSync<_AuthService>(
          name: _authName,
          instance: _FakeAuth('second'),
        );

      expect(
        locator.getServiceSync<_AuthService>(name: _authName).token,
        'second',
      );
    });
  });
}
