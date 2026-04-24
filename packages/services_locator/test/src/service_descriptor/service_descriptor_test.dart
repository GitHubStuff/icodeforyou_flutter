// packages/services_locator/test/src/service_descriptor/service_descriptor_test.dart
//
// Full-coverage test suite for [ServiceDescriptor], [SyncServiceDescriptor],
// and [LazyAsyncServiceDescriptor]. Uses a recording fake locator so the
// descriptor contract can be verified in isolation from any real locator
// implementation.

// ignore_for_file: cascade_invocations, document_ignores

import 'package:flutter_test/flutter_test.dart';
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show
        LazyAsyncServiceDescriptor,
        ServiceClass,
        ServiceDescriptor,
        SyncServiceDescriptor;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

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
// Test doubles: descriptors
// ---------------------------------------------------------------------------

/// Sync descriptor that accepts every default (dependencies, timeout).
class _DefaultSyncAuthDescriptor extends SyncServiceDescriptor<_AuthService> {
  const _DefaultSyncAuthDescriptor();

  @override
  String get name => 'auth';

  @override
  _AuthService Function() get builder =>
      () => _FakeAuth('built');
}

/// Sync descriptor that overrides every default.
class _CustomSyncAuthDescriptor extends SyncServiceDescriptor<_AuthService> {
  const _CustomSyncAuthDescriptor();

  @override
  String get name => 'auth-custom';

  @override
  List<Type> get dependencies => const [_LogService];

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  _AuthService Function() get builder =>
      () => _FakeAuth('custom');
}

/// Lazy async descriptor that accepts every default.
class _DefaultLazyAuthDescriptor
    extends LazyAsyncServiceDescriptor<_AuthService> {
  const _DefaultLazyAuthDescriptor();

  @override
  String get name => 'auth-lazy';

  @override
  Future<_AuthService> Function() get builder =>
      () async => _FakeAuth('lazy');
}

/// Lazy async descriptor that overrides every default.
class _CustomLazyLogDescriptor extends LazyAsyncServiceDescriptor<_LogService> {
  const _CustomLazyLogDescriptor();

  @override
  String get name => 'log-lazy';

  @override
  List<Type> get dependencies => const [_AuthService];

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<_LogService> Function() get builder =>
      () async => _FakeLog();
}

// ---------------------------------------------------------------------------
// Recording fake locator
// ---------------------------------------------------------------------------

class _SyncCall {
  _SyncCall({required this.type, required this.name, required this.instance});
  final Type type;
  final String name;
  final Object instance;
}

class _LazyCall {
  _LazyCall({
    required this.type,
    required this.name,
    required this.builder,
    required this.serviceState,
  });
  final Type type;
  final String name;
  final Object builder; // Future<SRV> Function()
  final ReportServiceState serviceState;
}

class _RecordingLocator implements ServiceLocator {
  final List<_SyncCall> syncCalls = [];
  final List<_LazyCall> lazyCalls = [];

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    syncCalls.add(_SyncCall(type: SRV, name: name, instance: instance));
    return instance;
  }

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    lazyCalls.add(
      _LazyCall(
        type: SRV,
        name: name,
        builder: builder,
        serviceState: serviceState,
      ),
    );
  }

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) {
    throw UnimplementedError('not used by descriptor tests');
  }

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    throw UnimplementedError('not used by descriptor tests');
  }
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

/// main test body
void main() {
  late _RecordingLocator locator;
  late _StateRecorder recorder;

  setUp(() {
    locator = _RecordingLocator();
    recorder = _StateRecorder();
  });

  // ---------------------------------------------------------------------------
  // Base class: default getters + toString
  // ---------------------------------------------------------------------------

  group('ServiceDescriptor base defaults', () {
    test('dependencies defaults to empty list', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor.dependencies, isEmpty);
    });

    test('timeout defaults to 30 seconds', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor.timeout, const Duration(seconds: 30));
    });

    test('dependencies can be overridden', () {
      const descriptor = _CustomSyncAuthDescriptor();
      expect(descriptor.dependencies, const [_LogService]);
    });

    test('timeout can be overridden', () {
      const descriptor = _CustomSyncAuthDescriptor();
      expect(descriptor.timeout, const Duration(seconds: 10));
    });

    test('toString with defaults', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(
        descriptor.toString(),
        'ServiceDescriptor(name: "auth", deps: [], timeout: 30s)',
      );
    });

    test('toString with overrides', () {
      const descriptor = _CustomSyncAuthDescriptor();
      expect(
        descriptor.toString(),
        'ServiceDescriptor(name: "auth-custom", deps: [_LogService], '
        'timeout: 10s)',
      );
    });

    test('toString for lazy descriptor uses same format', () {
      const descriptor = _CustomLazyLogDescriptor();
      expect(
        descriptor.toString(),
        'ServiceDescriptor(name: "log-lazy", deps: [_AuthService], '
        'timeout: 5s)',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Sealed type: base is reachable as a type
  // ---------------------------------------------------------------------------

  group('ServiceDescriptor sealed hierarchy', () {
    test('sync descriptor is a ServiceDescriptor', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor, isA<ServiceDescriptor<_AuthService>>());
    });

    test('lazy descriptor is a ServiceDescriptor', () {
      const descriptor = _DefaultLazyAuthDescriptor();
      expect(descriptor, isA<ServiceDescriptor<_AuthService>>());
    });
  });

  // ---------------------------------------------------------------------------
  // SyncServiceDescriptor.registerWith
  // ---------------------------------------------------------------------------

  group('SyncServiceDescriptor.registerWith', () {
    test('invokes builder and forwards to registerServiceSync', () {
      const descriptor = _DefaultSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.syncCalls, hasLength(1));
      expect(locator.lazyCalls, isEmpty);

      final call = locator.syncCalls.single;
      expect(call.type, _AuthService);
      expect(call.name, 'auth');
      expect(call.instance, isA<_FakeAuth>());
      expect((call.instance as _FakeAuth).token, 'built');
    });

    test('emits LocatorStatus.ready with the built instance', () {
      const descriptor = _DefaultSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(recorder.events, hasLength(1));
      final event = recorder.events.single;
      expect(event.status, LocatorStatus.ready);
      expect(event.instance, isA<_FakeAuth>());
      expect(event.instance, same(locator.syncCalls.single.instance));
    });

    test('invokes builder exactly once per registerWith call', () {
      var buildCount = 0;
      final descriptor = _CountingSyncDescriptor(
        onBuild: () => buildCount++,
      );

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(buildCount, 1);
    });

    test('uses overridden name when registering', () {
      const descriptor = _CustomSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.syncCalls.single.name, 'auth-custom');
    });
  });

  // ---------------------------------------------------------------------------
  // LazyAsyncServiceDescriptor.registerWith
  // ---------------------------------------------------------------------------

  group('LazyAsyncServiceDescriptor.registerWith', () {
    test(
      'forwards to registerServiceLazyAsync without running builder',
      () async {
        var buildCount = 0;
        final descriptor = _CountingLazyDescriptor(
          onBuild: () => buildCount++,
        );

        descriptor.registerWith(locator, serviceState: recorder.call);

        expect(locator.lazyCalls, hasLength(1));
        expect(locator.syncCalls, isEmpty);
        expect(buildCount, 0, reason: 'lazy builder must not run at register');

        final call = locator.lazyCalls.single;
        expect(call.type, _AuthService);
        expect(call.name, 'lazy-counting');
      },
    );

    test('forwards the serviceState callback verbatim', () {
      const descriptor = _DefaultLazyAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      // Simulate the locator firing state transitions back through the
      // forwarded callback to prove it's the same function reference.
      final _ = locator.lazyCalls.single.serviceState
        ..call(LocatorStatus.starting)
        ..call(LocatorStatus.ready, instance: _FakeAuth('forwarded'));

      expect(recorder.events, hasLength(2));
      expect(recorder.events[0].status, LocatorStatus.starting);
      expect(recorder.events[1].status, LocatorStatus.ready);
      expect((recorder.events[1].instance! as _FakeAuth).token, 'forwarded');
    });

    test(
      'forwards the builder reference so the locator can run it later',
      () async {
        var buildCount = 0;
        final descriptor = _CountingLazyDescriptor(
          onBuild: () => buildCount++,
        );

        descriptor.registerWith(locator, serviceState: recorder.call);

        final forwardedBuilder =
            locator.lazyCalls.single.builder as Future<_AuthService> Function();
        final result = await forwardedBuilder();

        expect(buildCount, 1);
        expect(result, isA<_FakeAuth>());
      },
    );

    test('uses overridden name when registering', () {
      const descriptor = _CustomLazyLogDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.lazyCalls.single.name, 'log-lazy');
      expect(locator.lazyCalls.single.type, _LogService);
    });
  });
}

// ---------------------------------------------------------------------------
// Instrumented descriptors for build-count assertions
// ---------------------------------------------------------------------------

class _CountingSyncDescriptor extends SyncServiceDescriptor<_AuthService> {
  _CountingSyncDescriptor({required this.onBuild});

  final void Function() onBuild;

  @override
  String get name => 'sync-counting';

  @override
  _AuthService Function() get builder => () {
    onBuild();
    return _FakeAuth('counted');
  };
}

class _CountingLazyDescriptor extends LazyAsyncServiceDescriptor<_AuthService> {
  _CountingLazyDescriptor({required this.onBuild});

  final void Function() onBuild;

  @override
  String get name => 'lazy-counting';

  @override
  Future<_AuthService> Function() get builder => () async {
    onBuild();
    return _FakeAuth('counted');
  };
}
