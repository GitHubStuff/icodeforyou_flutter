// packages/services_locator/test/src/service_locator/get_it_service_locator_test.dart
//
// Full-coverage test suite for [GetItServiceLocator]. Uses a fresh GetIt
// instance per test (no global singleton touched) to keep tests isolated
// and parallel-safe. Exercises every branch: sync + async registration,
// duplicate detection, get (sync + async), ServiceNotReady error paths,
// and both _assertRegistered branches.

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:services_locator/services_locator.dart'
    show GetItServiceLocator;
import 'package:services_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotReady, ServiceNotRegistered;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
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
      // This proves the null-coalescing branch in the constructor. We don't
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

      final readyEvents = recorder.events
          .where((e) => e.status == LocatorStatus.ready)
          .toList();
      expect(readyEvents, hasLength(1));
      expect(readyEvents.single.instance, same(auth));
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

    test('getServiceAsync throws on timeout when builder never completes', () {
      locator.registerServiceLazyAsync<_AuthService>(
        name: _authName,
        builder: () => Completer<_AuthService>().future,
        serviceState: _StateRecorder().call,
      );

      // GetIt.isReady throws a TimeoutException on timeout. We don't wrap it
      // here — this test locks down the pass-through contract.
      expect(
        () => locator.getServiceAsync<_AuthService>(
          name: _authName,
          timeout: _shortTimeout,
        ),
        throwsA(anything),
      );
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

    test('getServiceAsync throws ServiceNotRegistered', () {
      expect(
        () => locator.getServiceAsync<_AuthService>(
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
