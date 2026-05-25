// packages/services_locator/test/src/service_descriptor/service_descriptor_test.dart
//
// Full-coverage test suite for [ServiceDescriptor], [SyncServiceDescriptor],
// and [LazyAsyncServiceDescriptor]. Uses a recording fake locator so the
// descriptor contract can be verified in isolation from any real locator
// implementation.
//
// Revision history:
//   - Initial coverage for sealed hierarchy, registerWith delegation,
//     default vs. overridden getters, and toString().
//   - Added coverage for `serviceType` reified getter (survives generic
//     erasure under widened references).
//   - Added coverage for `toRegistration()` factory method.
//   - Updated `_StateRecorder` for the extended `ReportServiceState`
//     signature (now carries optional `error` / `stackTrace`).

// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show
        LazyAsyncServiceDescriptor,
        ServiceClass,
        ServiceDescriptor,
        SyncServiceDescriptor;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;
import 'package:service_locator/src/service_registry/service_registration.dart'
    show ServiceRegistration;

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
  String get name => 'auth-sync';

  @override
  _AuthService Function() get builder =>
      () => _FakeAuth('sync');
}

/// Sync descriptor that overrides every default.
class _CustomSyncAuthDescriptor extends SyncServiceDescriptor<_AuthService> {
  const _CustomSyncAuthDescriptor();

  @override
  String get name => 'auth-sync-custom';

  @override
  List<Type> get dependencies => const [_LogService];

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  _AuthService Function() get builder =>
      () => _FakeAuth('sync-custom');
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
// Instrumented descriptors for build-count assertions
// ---------------------------------------------------------------------------

class _CountingSyncDescriptor extends SyncServiceDescriptor<_AuthService> {
  _CountingSyncDescriptor({required this.onBuild});

  final void Function() onBuild;

  @override
  String get name => 'auth-count-sync';

  @override
  _AuthService Function() get builder => () {
    onBuild();
    return _FakeAuth('counted-sync');
  };
}

class _CountingLazyDescriptor extends LazyAsyncServiceDescriptor<_AuthService> {
  _CountingLazyDescriptor({required this.onBuild});

  final void Function() onBuild;

  @override
  String get name => 'auth-count-lazy';

  @override
  Future<_AuthService> Function() get builder => () async {
    onBuild();
    return _FakeAuth('counted-lazy');
  };
}

// ---------------------------------------------------------------------------
// Recording fake locator
// ---------------------------------------------------------------------------

class _AsyncCall {
  _AsyncCall({
    required this.type,
    required this.name,
    required this.builder,
  });
  final Type type;
  final String name;
  final Object builder; // Future<SRV> Function()
}

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
  final List<_AsyncCall> asyncCalls = [];
  final List<_LazyCall> lazyCalls = [];
  final List<_SyncCall> syncCalls = [];

  @override
  Future<SRV> registerServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
  }) async {
    {
      asyncCalls.add(
        _AsyncCall(
          type: SRV,
          name: name,
          builder: builder,
        ),
      );
    }
    return builder();
  }

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

class _StateEvent {
  const _StateEvent({
    required this.status,
    this.instance,
    this.error,
    this.stackTrace,
  });

  final LocatorStatus status;
  final ServiceClass? instance;
  final Object? error;
  final StackTrace? stackTrace;
}

class _StateRecorder {
  final List<_StateEvent> events = [];

  void call(
    LocatorStatus status, {
    ServiceClass? instance,
    Object? error,
    StackTrace? stackTrace,
  }) {
    events.add(
      _StateEvent(
        status: status,
        instance: instance,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _RecordingLocator locator;
  late _StateRecorder recorder;

  setUp(() {
    locator = _RecordingLocator();
    recorder = _StateRecorder();
  });

  // ─────────────────────────────────────────────────────────────────────
  // ServiceDescriptor (base class defaults & identity)
  // ─────────────────────────────────────────────────────────────────────

  group('ServiceDescriptor defaults', () {
    test('dependencies defaults to empty list', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor.dependencies, isEmpty);
    });

    test('timeout defaults to defaultTimeout (30 seconds)', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor.timeout, ServiceDescriptor.defaultTimeout);
      expect(descriptor.timeout, const Duration(seconds: 30));
    });

    test('defaults apply to lazy descriptors too', () {
      const descriptor = _DefaultLazyAuthDescriptor();
      expect(descriptor.dependencies, isEmpty);
      expect(descriptor.timeout, const Duration(seconds: 30));
    });

    test('overrides are respected on sync descriptors', () {
      const descriptor = _CustomSyncAuthDescriptor();
      expect(descriptor.dependencies, const [_LogService]);
      expect(descriptor.timeout, const Duration(seconds: 10));
    });

    test('overrides are respected on lazy descriptors', () {
      const descriptor = _CustomLazyLogDescriptor();
      expect(descriptor.dependencies, const [_AuthService]);
      expect(descriptor.timeout, const Duration(seconds: 5));
    });
  });

  group('ServiceDescriptor.toString', () {
    test('reflects name, dependencies, and timeout in seconds', () {
      const descriptor = _CustomSyncAuthDescriptor();
      expect(
        descriptor.toString(),
        'ServiceDescriptor(name: "auth-sync-custom", '
        'deps: [_LogService], timeout: 10s)',
      );
    });

    test('formats empty dependencies correctly', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(
        descriptor.toString(),
        'ServiceDescriptor(name: "auth-sync", deps: [], timeout: 30s)',
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // ServiceDescriptor.serviceType  (BUG-6 coverage)
  // ─────────────────────────────────────────────────────────────────────

  group('ServiceDescriptor.serviceType', () {
    test('returns the concrete SRV for sync descriptors', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      expect(descriptor.serviceType, _AuthService);
    });

    test('returns the concrete SRV for lazy descriptors', () {
      const descriptor = _CustomLazyLogDescriptor();
      expect(descriptor.serviceType, _LogService);
    });

    test('survives widened reference (generic erasure)', () {
      // This is the pivotal test: when callers hold descriptors through
      // a widened type (e.g. iterating a list), the call-site SRV erases
      // to ServiceClass. `serviceType` must still return the concrete
      // subclass type because it is captured at subclass definition,
      // not at the call site.
      final descriptors = <ServiceDescriptor<ServiceClass>>[
        const _DefaultSyncAuthDescriptor(),
        const _CustomLazyLogDescriptor(),
      ];

      expect(descriptors[0].serviceType, _AuthService);
      expect(descriptors[1].serviceType, _LogService);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // ServiceDescriptor.toRegistration  (BUG-6 coverage, pt. 2)
  // ─────────────────────────────────────────────────────────────────────

  group('ServiceDescriptor.toRegistration', () {
    test('returns a ServiceRegistration wrapping this descriptor', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      final registration = descriptor.toRegistration();

      expect(registration, isA<ServiceRegistration<_AuthService>>());
      expect(registration.descriptor, same(descriptor));
    });

    test('new registration starts in staged status', () {
      const descriptor = _DefaultLazyAuthDescriptor();
      final registration = descriptor.toRegistration();

      expect(registration.status, LocatorStatus.staged);
      expect(registration.instance, isNull);
      expect(registration.error, isNull);
      expect(registration.stackTrace, isNull);
    });

    test(
      'produces a correctly reified registration under widened reference',
      () {
        // The whole point: calling toRegistration() through a
        // ServiceDescriptor<ServiceClass> reference must still produce
        // a ServiceRegistration<ConcreteType>, not ServiceRegistration
        // <ServiceClass>. The subtype check validates the reified type.
        const ServiceDescriptor<ServiceClass> widened =
            _DefaultSyncAuthDescriptor();
        final registration = widened.toRegistration();

        expect(registration, isA<ServiceRegistration<_AuthService>>());
        expect(
          registration,
          isNot(
            isA<ServiceRegistration<_LogService>>(),
          ),
          reason:
              'reified type must be the concrete subclass binding, '
              'not a sibling service type',
        );
      },
    );

    test('each call returns a fresh registration', () {
      const descriptor = _DefaultSyncAuthDescriptor();
      final first = descriptor.toRegistration();
      final second = descriptor.toRegistration();

      expect(first, isNot(same(second)));
      expect(first.descriptor, same(second.descriptor));
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // SyncServiceDescriptor.registerWith
  // ─────────────────────────────────────────────────────────────────────

  group('SyncServiceDescriptor.registerWith', () {
    test('invokes builder, registers instance, and emits ready', () {
      const descriptor = _DefaultSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.syncCalls, hasLength(1));
      expect(locator.syncCalls.single.type, _AuthService);
      expect(locator.syncCalls.single.name, 'auth-sync');
      expect(locator.syncCalls.single.instance, isA<_FakeAuth>());

      expect(recorder.events, hasLength(1));
      expect(recorder.events.single.status, LocatorStatus.ready);
      expect(recorder.events.single.instance, isA<_FakeAuth>());
      expect(
        recorder.events.single.instance,
        same(locator.syncCalls.single.instance),
      );
    });

    test('passes the same instance to locator and serviceState callback', () {
      const descriptor = _DefaultSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      final registeredInstance = locator.syncCalls.single.instance;
      final emittedInstance = recorder.events.single.instance;
      expect(emittedInstance, same(registeredInstance));
    });

    test('does not touch registerServiceLazyAsync', () {
      const descriptor = _DefaultSyncAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.lazyCalls, isEmpty);
    });

    test('invokes builder exactly once per registerWith call', () {
      var buildCount = 0;
      final descriptor = _CountingSyncDescriptor(
        onBuild: () => buildCount++,
      );

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(buildCount, 1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // LazyAsyncServiceDescriptor.registerWith
  // ─────────────────────────────────────────────────────────────────────

  group('LazyAsyncServiceDescriptor.registerWith', () {
    test('forwards to registerServiceLazyAsync without running builder', () {
      var buildCount = 0;
      final descriptor = _CountingLazyDescriptor(
        onBuild: () => buildCount++,
      );

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.lazyCalls, hasLength(1));
      expect(locator.lazyCalls.single.type, _AuthService);
      expect(locator.lazyCalls.single.name, 'auth-count-lazy');
      // Critical: the descriptor must NOT run the builder during
      // registration. Lazy means lazy — builder runs only on first
      // access via the locator, not at registration time.
      expect(buildCount, 0);
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
        final built = await forwardedBuilder();

        expect(buildCount, 1);
        expect(built, isA<_FakeAuth>());
      },
    );

    test('forwards the serviceState callback verbatim', () {
      const descriptor = _DefaultLazyAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      final forwardedCallback = locator.lazyCalls.single.serviceState;
      // Invoke through the forwarded reference and confirm the events
      // arrive in the original recorder. This proves the descriptor
      // does not wrap or adapt the callback.
      forwardedCallback(LocatorStatus.starting);
      forwardedCallback(
        LocatorStatus.ready,
        instance: _FakeAuth('forwarded'),
      );

      expect(recorder.events, hasLength(2));
      expect(recorder.events[0].status, LocatorStatus.starting);
      expect(recorder.events[0].instance, isNull);
      expect(recorder.events[1].status, LocatorStatus.ready);
      expect(recorder.events[1].instance, isA<_FakeAuth>());
    });

    test('forwards failure reports with error and stackTrace', () {
      // Verifies the extended ReportServiceState signature: the failed
      // state carries error and stackTrace through the forwarded
      // callback unchanged.
      const descriptor = _DefaultLazyAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      final forwardedCallback = locator.lazyCalls.single.serviceState;
      final cause = Exception('builder blew up');
      final trace = StackTrace.current;

      forwardedCallback(
        LocatorStatus.failed,
        error: cause,
        stackTrace: trace,
      );

      expect(recorder.events, hasLength(1));
      expect(recorder.events.single.status, LocatorStatus.failed);
      expect(recorder.events.single.error, same(cause));
      expect(recorder.events.single.stackTrace, same(trace));
    });

    test('does not touch registerServiceSync', () {
      const descriptor = _DefaultLazyAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(locator.syncCalls, isEmpty);
    });

    test('does not emit serviceState directly during registration', () {
      // The sync descriptor emits `ready` from its own registerWith.
      // The lazy descriptor must NOT — emission is the locator's
      // responsibility (via onCreated on GetIt, or via _markReady on
      // the mock) once the builder completes.
      const descriptor = _DefaultLazyAuthDescriptor();

      descriptor.registerWith(locator, serviceState: recorder.call);

      expect(recorder.events, isEmpty);
    });
  });
}
