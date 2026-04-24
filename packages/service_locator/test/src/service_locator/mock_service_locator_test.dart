// packages/services_locator/test/src/service_locator/mock_service_locator_test.dart
//
// Full-coverage test suite for [MockServiceLocator].
//
// Tracks surface changes to the mock that parallel the GetIt adapter:
//  • Timeouts now surface as [ServiceItemTimeout] (see Bug #7), not
//    [ServiceNotReady] — the two locators produce the same error type so
//    tests and production code agree.
//  • `_markFailed` populates the state callback's `error` and
//    `stackTrace` fields on every failure path (builder throw, explicit
//    hook call, reset-while-in-flight). Tests lock those payloads in.
//  • `_StateRecorder` matches the full [ReportServiceState] typedef so
//    it can be passed directly as a callback.

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/errors.dart'
    show
        DuplicateServiceEntry,
        ServiceItemTimeout,
        ServiceNotReady,
        ServiceNotRegistered;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_locator/mock_service_locator.dart'
    show MockServiceLocator;

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

// ---------------------------------------------------------------------------
// State recorder
// ---------------------------------------------------------------------------
//
// Matches the [ReportServiceState] typedef's full signature so it can be
// passed directly as a callback. Captures every parameter — tests can
// assert on transition sequence and on payload content (instance for
// ready, error + stackTrace for failed).

typedef _Event =
    ({
      LocatorStatus status,
      ServiceClass? instance,
      Object? error,
      StackTrace? stackTrace,
    });

class _StateRecorder {
  final List<_Event> events = [];

  void call(
    LocatorStatus status, {
    ServiceClass? instance,
    Object? error,
    StackTrace? stackTrace,
  }) {
    events.add((
      status: status,
      instance: instance,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  List<LocatorStatus> get statuses => events.map((e) => e.status).toList();

  _Event eventOf(LocatorStatus status) =>
      events.firstWhere((e) => e.status == status);

  int countOf(LocatorStatus status) =>
      events.where((e) => e.status == status).length;
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
  // Lazy async registration — success paths
  // ---------------------------------------------------------------------------

  group('registerServiceLazyAsync', () {
    test('emits LocatorStatus.starting synchronously', () {
      final recorder = _StateRecorder();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => _FakeAuth('x'),
        serviceState: recorder.call,
      );

      expect(recorder.statuses, [LocatorStatus.starting]);
      final starting = recorder.events.single;
      expect(starting.instance, isNull);
      expect(starting.error, isNull);
      expect(starting.stackTrace, isNull);
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
      expect(
        recorder.statuses,
        [LocatorStatus.starting, LocatorStatus.ready],
      );
      expect(recorder.eventOf(LocatorStatus.ready).instance, same(auth));
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
  });

  // ---------------------------------------------------------------------------
  // Lazy async registration — failure paths
  // ---------------------------------------------------------------------------

  group('registerServiceLazyAsync — failures', () {
    test('getServiceAsync throws ServiceItemTimeout on timeout', () async {
      // Post-Bug-#7: the mock translates its internal Dart [TimeoutException]
      // into [ServiceItemTimeout], matching the GetIt adapter. Tests and
      // production code assert against the same error type.
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: _StateRecorder().call,
      );

      await expectLater(
        locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _shortTimeout,
        ),
        throwsA(isA<ServiceItemTimeout>()),
      );
    });

    test(
      'builder throw propagates and reports failed with error + stackTrace',
      () async {
        // Exercises [_maybeStartBuilder]'s catch branch. The error and
        // stack must flow through to the state callback so the registry
        // can drive its [ServiceRegistration] into terminal `failed`.
        final recorder = _StateRecorder();
        final boom = StateError('builder blew up');
        locator.registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => throw boom,
          serviceState: recorder.call,
        );

        await expectLater(
          locator.getServiceAsync<_AuthService>(
            name: _authName,
            timeout: _longTimeout,
          ),
          throwsA(same(boom)),
        );

        expect(
          recorder.statuses,
          [LocatorStatus.starting, LocatorStatus.failed],
        );
        final failed = recorder.eventOf(LocatorStatus.failed);
        expect(failed.error, same(boom));
        expect(failed.stackTrace, isNotNull);
        expect(failed.instance, isNull);
      },
    );
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

    test('getServiceAsync throws ServiceNotRegistered', () async {
      await expectLater(
        locator.getServiceAsync<_AuthService>(
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
  // Sync-vs-lazy type guard
  // ---------------------------------------------------------------------------
  //
  // Lazy-async test hooks are rejected at the type boundary when the
  // registration is sync. The `_assertLazyAsync` helper throws so a test
  // author's mistake is caught immediately rather than silently no-op'd.

  group('lazy-async hooks on sync registrations', () {
    test('completeLazyService throws StateError on sync registration', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('x'),
      );

      expect(
        () => locator.completeLazyService<_AuthService>(
          name: _authName,
          instance: _FakeAuth('y'),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('failLazyService throws StateError on sync registration', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('x'),
      );

      expect(
        () => locator.failLazyService<_AuthService>(
          name: _authName,
          error: StateError('nope'),
        ),
        throwsA(isA<StateError>()),
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
      expect(recorder.eventOf(LocatorStatus.ready).instance, same(injected));
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
      final readyEventsAfterFirst = recorder.countOf(LocatorStatus.ready);

      // Second call must not throw and must not emit another ready event.
      locator.completeLazyService<_AuthService>(
        name: _authName,
        instance: _FakeAuth('second'),
      );
      final readyEventsAfterSecond = recorder.countOf(LocatorStatus.ready);

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

      expect(recorder.countOf(LocatorStatus.ready), 1);
      expect(recorder.eventOf(LocatorStatus.ready).instance, same(injected));
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

      expect(recorder.countOf(LocatorStatus.ready), 1);
      expect(recorder.eventOf(LocatorStatus.ready).instance, same(injected));
      // The builder's post-hoc error must NOT have surfaced as a failed
      // event — the entry was already terminal before the throw landed.
      expect(recorder.countOf(LocatorStatus.failed), 0);
    });
  });

  // ---------------------------------------------------------------------------
  // Test hooks: failLazyService
  // ---------------------------------------------------------------------------

  group('failLazyService', () {
    test('propagates error to pending awaiters and reports failed', () async {
      final recorder = _StateRecorder();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: recorder.call,
      );

      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      final error = StateError('injected failure');
      locator.failLazyService<_AuthService>(name: _authName, error: error);

      await expectLater(pending, throwsA(same(error)));

      final failed = recorder.eventOf(LocatorStatus.failed);
      expect(failed.error, same(error));
      expect(failed.stackTrace, isNotNull);
      expect(failed.instance, isNull);
    });

    test('uses provided stackTrace when one is passed', () async {
      final recorder = _StateRecorder();
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: recorder.call,
      );

      final error = StateError('failure with stack');
      final trace = StackTrace.fromString('synthetic stack frame');
      locator.failLazyService<_AuthService>(
        name: _authName,
        error: error,
        stackTrace: trace,
      );

      expect(recorder.eventOf(LocatorStatus.failed).stackTrace, same(trace));
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
        final recorder = _StateRecorder();
        final firstError = StateError('first');
        locator.registerServiceLazyAsync<_AuthService>(
          name: _authName,
          builder: () async => throw firstError,
          serviceState: recorder.call,
        );

        // Drive the builder to error, completing the completer but leaving
        // isReady == false. This is the only path that reaches the
        // `entry.completer.isCompleted` guard in failLazyService.
        await expectLater(
          locator.getServiceAsync<_AuthService>(
            name: _authName,
            timeout: _longTimeout,
          ),
          throwsA(same(firstError)),
        );

        expect(
          () => locator.failLazyService<_AuthService>(
            name: _authName,
            error: StateError('second'),
          ),
          returnsNormally,
        );

        // Recorder still reflects only the original failure — the no-op'd
        // second call must not emit a second `failed` event.
        expect(recorder.countOf(LocatorStatus.failed), 1);
        expect(recorder.eventOf(LocatorStatus.failed).error, same(firstError));
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

    test('unblocks in-flight awaiters with a StateError', () async {
      // Covers the reset-while-builder-in-flight cleanup. Without it, a
      // pending awaiter would hang past the end of the test that owns the
      // mock, potentially masking later failures behind a timeout.
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: _StateRecorder().call,
      );

      final pending = locator.getServiceAsync<_AuthService>(
        name: _authName,
        timeout: _longTimeout,
      );

      locator.reset();

      await expectLater(pending, throwsA(isA<StateError>()));
    });
  });
}
