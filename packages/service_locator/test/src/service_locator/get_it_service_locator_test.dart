// packages/services_locator/test/src/service_locator/get_it_service_locator_test.dart
//
// Full-coverage test suite for [GetItServiceLocator]. Uses a fresh GetIt
// instance per test (no global singleton touched) to keep tests isolated
// and parallel-safe.
//
// Tracks surface changes to the adapter:
//  • sync registration no longer uses `signalsReady: true`/`signalReady`
//    (see Bug #1 notes in the adapter); tests verify the simpler path
//    still supports the same-instance-under-two-names use case that
//    motivated the change.
//  • `isReady`'s `WaitingTimeOutException` is translated into
//    [ServiceItemTimeout] (see Bug #7); tests assert on the translated
//    error type and its diagnostic fields rather than the raw get_it type.
//  • `ReportServiceState` carries `error` and `stackTrace` on failed
//    transitions; the test recorder records all four fields and tests
//    cover the failing-builder path that was previously uncovered.

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:service_locator/service_locator.dart' show GetItServiceLocator;
import 'package:service_locator/src/errors.dart'
    show
        DuplicateServiceEntry,
        ServiceItemTimeout,
        ServiceNotReady,
        ServiceNotRegistered;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;

// ---------------------------------------------------------------------------
// Test doubles: services
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
// Matches the `ReportServiceState` typedef's full signature so it can be
// passed directly as a callback. Captures every parameter so tests can
// assert not just on transition sequence but on payload content (instance
// on ready, error + stackTrace on failed).

typedef _Event = ({
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
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _shortTimeout = Duration(milliseconds: 50);
const _longTimeout = Duration(seconds: 5);
const _authName = 'auth';
const _altName = 'alt';

void main() {
  late GetIt getIt;
  late GetItServiceLocator locator;

  setUp(() {
    getIt = GetIt.asNewInstance();
    locator = GetItServiceLocator(getIt: getIt);
  });

  tearDown(() async {
    await getIt.reset();
  });

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  group('construction', () {
    test('defaults to GetIt.I when no instance provided', () {
      // Proves the null-coalescing branch in the constructor. We don't
      // exercise behavior through GetIt.I — just confirm the object builds.
      expect(GetItServiceLocator(), isA<GetItServiceLocator>());
    });

    test('uses the injected GetIt instance', () {
      // Prove isolation: registering on our locator must not leak into GetIt.I.
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('isolated'),
      );
      expect(
        GetIt.I.isRegistered<_AuthService>(instanceName: _authName),
        isFalse,
      );
    });
  });

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
      expect(
        getIt.isRegistered<_AuthService>(instanceName: _authName),
        isTrue,
      );
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
      // Sync registrations are auto-ready — no `signalsReady`/`signalReady`
      // dance needed. getServiceAsync's internal isReady() call resolves
      // instantly for an auto-ready singleton.
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

    test('allows the SAME instance under two different names', () {
      // Locks down the Bug #1 fix: the old implementation used
      // `signalsReady: true` + `signalReady(instance)`, which threw
      // `ArgumentError` when the same instance object was present in the
      // GetIt internal map under multiple names because signalReady could
      // not disambiguate. The plain-registerSingleton path now handles
      // this cleanly.
      final shared = _FakeAuth('shared');
      locator
        ..registerServiceSync<_AuthService>(name: _authName, instance: shared)
        ..registerServiceSync<_AuthService>(name: _altName, instance: shared);

      expect(
        locator.getServiceSync<_AuthService>(name: _authName),
        same(shared),
      );
      expect(
        locator.getServiceSync<_AuthService>(name: _altName),
        same(shared),
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
      expect(recorder.events.single.instance, isNull);
      expect(recorder.events.single.error, isNull);
      expect(recorder.events.single.stackTrace, isNull);
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
        builder: () => Completer<_AuthService>().future,
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
    test(
      'getServiceAsync throws ServiceItemTimeout when builder stalls',
      () async {
        // A lazy-async builder that never completes must surface as
        // [ServiceItemTimeout] rather than leaking get_it's internal error
        // types or hanging the caller. The adapter materializes the builder
        // via `getAsync` and applies a Dart-level `.timeout()` at the Future
        // layer; the resulting `TimeoutException` is translated into
        // `ServiceItemTimeout`.
        //
        // `notReadyYet` / `waitedBy` are checked as present (non-null) but
        // not required to be populated — the Dart-level `TimeoutException`
        // doesn't carry diagnostic data, so those fields come through as
        // their empty defaults on this path. The sibling
        // `WaitingTimeOutException` branch in the adapter is marked
        // `coverage:ignore` because get_it's current `getAsync` doesn't
        // surface that exception type; see the adapter's inline notes.
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
          throwsA(
            isA<ServiceItemTimeout>()
                .having((e) => e.notReadyYet, 'notReadyYet', isNotNull)
                .having((e) => e.waitedBy, 'waitedBy', isNotNull),
          ),
        );
      },
    );

    test('failing builder reports failed with error and stackTrace', () async {
      // Exercises [_runReportingBuilder]'s catch branch. The wrapper must
      // fire a `failed` state event carrying both the caught error object
      // and its stack trace before rethrowing so get_it's own bookkeeping
      // still observes the failure.
      //
      // The exact error type that escapes get_it on a failed async builder
      // is not part of this adapter's contract (get_it forwards the error
      // through its internal futures; whether it surfaces directly or is
      // wrapped is an implementation detail). What matters here is that
      // the state callback was fired with the original error + stack — the
      // rest of this test exercises that.
      final recorder = _StateRecorder();
      final boom = StateError('builder blew up');
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () async => throw boom,
        serviceState: recorder.call,
      );

      // Drive the builder by trying to resolve the service, and swallow
      // whatever escapes — we assert on recorder state, not thrown type.
      await expectLater(
        locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _longTimeout,
        ),
        throwsA(anything),
      );

      expect(
        recorder.statuses,
        containsAllInOrder([LocatorStatus.starting, LocatorStatus.failed]),
      );
      final failed = recorder.eventOf(LocatorStatus.failed);
      expect(failed.error, same(boom));
      expect(failed.stackTrace, isNotNull);
      expect(failed.instance, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Unregistered paths — exercises _assertRegistered's throwing branch
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

    test('type mismatch under same name is treated as unregistered', () {
      locator.registerServiceSync<_AuthService>(
        name: _authName,
        instance: _FakeAuth('x'),
      );
      // _LogService was never registered under this name, even though
      // _AuthService was. _assertRegistered is type-aware.
      expect(
        () => locator.getServiceSync<_LogService>(name: _authName),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });
  });
}
