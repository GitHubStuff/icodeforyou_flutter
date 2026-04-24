// ignore_for_file: cascade_invocations, document_ignores

// packages/services_locator/test/src/service_locator_registry/service_locator_registry_test.dart
//
// Full-coverage test suite for [ServiceLocatorRegistry]. Uses a scripted
// fake ServiceLocator so tests can drive state-change callbacks
// deterministically, exercising every branch including the defensive
// StateError path in _onLocatorStateChange.

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:services_locator/src/errors.dart'
    show
        BlankServiceName,
        DuplicateServiceEntry,
        ServiceNotReady,
        ServiceNotRegistered,
        ServiceStartupFailed,
        ServiceTypeMismatch;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show LazyAsyncServiceDescriptor, ServiceClass, SyncServiceDescriptor;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;
import 'package:services_locator/src/service_locator_registry/service_locator_registry.dart'
    show ServiceLocatorRegistry;

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

abstract interface class _DbService implements ServiceClass {}

class _FakeDb implements _DbService {}

// ---------------------------------------------------------------------------
// Test doubles: descriptors
// ---------------------------------------------------------------------------

class _SyncAuthDescriptor extends SyncServiceDescriptor<_AuthService> {
  _SyncAuthDescriptor({
    this.descriptorName = 'auth',
    this.deps = const [],
    _AuthService Function()? buildFn,
  }) : _buildFn = buildFn ?? (() => _FakeAuth('built'));

  final String descriptorName;
  final List<Type> deps;
  final _AuthService Function() _buildFn;

  @override
  String get name => descriptorName;

  @override
  List<Type> get dependencies => deps;

  @override
  _AuthService Function() get builder => _buildFn;
}

class _SyncLogDescriptor extends SyncServiceDescriptor<_LogService> {
  const _SyncLogDescriptor();

  @override
  String get name => 'log';

  @override
  _LogService Function() get builder => _FakeLog.new;
}

class _SyncDbDescriptor extends SyncServiceDescriptor<_DbService> {
  const _SyncDbDescriptor();

  @override
  String get name => 'db';

  @override
  _DbService Function() get builder => _FakeDb.new;
}

class _LazyAuthDescriptor extends LazyAsyncServiceDescriptor<_AuthService> {
  const _LazyAuthDescriptor();

  @override
  String get name => 'auth-lazy';

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<_AuthService> Function() get builder =>
      () async => _FakeAuth('lazy-built');
}

/// Descriptor whose `builder` throws synchronously — used to exercise the
/// catch branch in `_performRegister`. Extends SyncServiceDescriptor so we
/// stay within the sealed hierarchy; the throw from the builder propagates
/// out of SyncServiceDescriptor.registerWith unchanged.
class _ThrowingDescriptor extends SyncServiceDescriptor<_AuthService> {
  const _ThrowingDescriptor();

  @override
  String get name => 'throwing';

  @override
  _AuthService Function() get builder =>
      () => throw StateError('descriptor refused to register');
}

// ---------------------------------------------------------------------------
// Scripted fake locator
//
// - registerServiceSync fires the `ready` callback synchronously (mirrors
//   what a real sync-registered service would do).
// - registerServiceLazyAsync captures the callback so tests can drive
//   `starting` / `ready` / `failed` / `staged` transitions on demand.
// - getServiceAsync / getServiceSync return whatever was stored via
//   registerServiceSync or storeInstance.
// ---------------------------------------------------------------------------

class _FakeLocator implements ServiceLocator {
  final Map<String, Object> _instances = {};
  final Map<String, ReportServiceState> lazyCallbacks = {};

  /// Completers that `getServiceAsync` awaits when the instance isn't
  /// available yet. Completed when the test fires the `ready` callback
  /// through [lazyCallbacks] (see the registration in
  /// [registerServiceLazyAsync] below).
  final Map<String, Completer<Object>> _pendingGets = {};

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    _instances[name] = instance;
    _completePending(name, instance);
    return instance;
  }

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    // Wrap the test-driven callback so that when a test fires `ready`
    // with an instance, pending getServiceAsync awaiters are resolved.
    lazyCallbacks[name] = (LocatorStatus state, {Object? instance}) {
      if (state == LocatorStatus.ready && instance != null) {
        _instances[name] = instance;
        _completePending(name, instance);
      }
      serviceState(state, instance: instance);
    };
  }

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    final existing = _instances[name];
    if (existing is SRV) return existing;

    // Block until the test fires `ready` via the lazy callback.
    final completer = _pendingGets.putIfAbsent(name, Completer<Object>.new);
    final resolved = await completer.future;
    if (resolved is SRV) return resolved;
    throw StateError(
      'resolved instance for "$name" is not $SRV '
      '(got ${resolved.runtimeType})',
    );
  }

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    final instance = _instances[name];
    if (instance is SRV) return instance;
    throw StateError('no instance for "$name"');
  }

  void storeInstance(String name, Object instance) {
    _instances[name] = instance;
    _completePending(name, instance);
  }

  void _completePending(String name, Object instance) {
    final pending = _pendingGets.remove(name);
    if (pending != null && !pending.isCompleted) {
      pending.complete(instance);
    }
  }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _authName = 'auth';
const _logName = 'log';
const _dbName = 'db';
const _lazyName = 'auth-lazy';

void main() {
  late _FakeLocator fakeLocator;
  late ServiceLocatorRegistry registry;

  setUp(() {
    fakeLocator = _FakeLocator();
    registry = ServiceLocatorRegistry(locator: fakeLocator);
  });

  // ---------------------------------------------------------------------------
  // stage
  // ---------------------------------------------------------------------------

  group('stage', () {
    test('stages a descriptor', () {
      registry.stage(_SyncAuthDescriptor());

      expect(
        () => registry.registrationFor<_AuthService>(_authName),
        returnsNormally,
      );
    });

    test('throws BlankServiceName when name is empty', () {
      expect(
        () => registry.stage(_SyncAuthDescriptor(descriptorName: '')),
        throwsA(isA<BlankServiceName>()),
      );
    });

    test('throws BlankServiceName when name is whitespace only', () {
      expect(
        () => registry.stage(_SyncAuthDescriptor(descriptorName: '   ')),
        throwsA(isA<BlankServiceName>()),
      );
    });

    test('throws DuplicateServiceEntry on second stage with same name', () {
      registry.stage(_SyncAuthDescriptor());

      expect(
        () => registry.stage(_SyncAuthDescriptor()),
        throwsA(isA<DuplicateServiceEntry>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // registrationFor
  // ---------------------------------------------------------------------------

  group('registrationFor', () {
    test('returns registration for a staged descriptor', () {
      registry.stage(_SyncAuthDescriptor());

      final reg = registry.registrationFor<_AuthService>(_authName);
      expect(reg.name, _authName);
      expect(reg.status, LocatorStatus.staged);
    });

    test('throws ServiceNotRegistered when name is unknown', () {
      expect(
        () => registry.registrationFor<_AuthService>('ghost'),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('throws ServiceTypeMismatch when type does not match', () {
      registry.stage(_SyncAuthDescriptor());

      expect(
        () => registry.registrationFor<_LogService>(_authName),
        throwsA(isA<ServiceTypeMismatch>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // register
  // ---------------------------------------------------------------------------

  group('register', () {
    test('throws ServiceNotRegistered when name is unknown', () async {
      await expectLater(
        registry.register('ghost'),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('staged sync service registers and becomes ready', () async {
      registry.stage(_SyncAuthDescriptor());

      await registry.register(_authName);

      final reg = registry.registrationFor<_AuthService>(_authName);
      expect(reg.status, LocatorStatus.ready);
    });

    test('calling register twice on a ready service is a no-op', () async {
      registry.stage(_SyncAuthDescriptor());
      await registry.register(_authName);

      // Second call hits the `ready` arm and returns immediately.
      await expectLater(registry.register(_authName), completes);
    });

    test(
      'concurrent register calls on a starting service share pendingStart',
      () async {
        registry.stage(const _LazyAuthDescriptor());

        final first = registry.register(_lazyName);
        final second = registry.register(_lazyName);

        // Let microtasks settle so the lazy callback is captured.
        await Future<void>.delayed(Duration.zero);

        // Drive ready via the captured callback.
        fakeLocator.storeInstance(_lazyName, _FakeAuth('lazy-drive'));
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.ready,
          instance: _FakeAuth('lazy-drive'),
        );

        await Future.wait<void>([first, second]);

        expect(
          registry.registrationFor<_AuthService>(_lazyName).status,
          LocatorStatus.ready,
        );
      },
    );

    test(
      'register on a failed service rethrows ServiceStartupFailed',
      () async {
        registry.stage(const _ThrowingDescriptor());

        // First call — _performRegister catches, marks failed, rethrows.
        await expectLater(
          registry.register('throwing'),
          throwsA(isA<ServiceStartupFailed>()),
        );

        // Second call — hits the `failed` switch arm and rethrows directly.
        await expectLater(
          registry.register('throwing'),
          throwsA(isA<ServiceStartupFailed>()),
        );
      },
    );

    test('registers dependencies before the dependent service', () async {
      registry.stage(const _SyncLogDescriptor());
      registry.stage(_SyncAuthDescriptor(deps: const [_LogService]));

      await registry.register(_authName);

      expect(
        registry.registrationFor<_LogService>(_logName).status,
        LocatorStatus.ready,
      );
      expect(
        registry.registrationFor<_AuthService>(_authName).status,
        LocatorStatus.ready,
      );
    });

    test('fails when a dependency was never staged', () async {
      registry.stage(_SyncAuthDescriptor(deps: const [_DbService]));

      await expectLater(
        registry.register(_authName),
        throwsA(isA<ServiceStartupFailed>()),
      );

      expect(
        registry.registrationFor<_AuthService>(_authName).status,
        LocatorStatus.failed,
      );
    });

    test('registers a chain of dependencies transitively', () async {
      registry.stage(const _SyncDbDescriptor());
      registry.stage(const _SyncLogDescriptor());
      registry.stage(
        _SyncAuthDescriptor(deps: const [_LogService, _DbService]),
      );

      await registry.register(_authName);

      expect(
        registry.registrationFor<_DbService>(_dbName).status,
        LocatorStatus.ready,
      );
      expect(
        registry.registrationFor<_LogService>(_logName).status,
        LocatorStatus.ready,
      );
      expect(
        registry.registrationFor<_AuthService>(_authName).status,
        LocatorStatus.ready,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getAsync
  // ---------------------------------------------------------------------------

  group('getAsync', () {
    test('returns from locator when service is ready', () async {
      registry.stage(_SyncAuthDescriptor());
      await registry.register(_authName);

      final result = await registry.getAsync<_AuthService>(_authName);
      expect(result, isA<_FakeAuth>());
    });

    test('registers and returns when service is staged', () async {
      registry.stage(_SyncAuthDescriptor());

      // No explicit register() call — getAsync should trigger it via
      // the `staged` arm.
      final result = await registry.getAsync<_AuthService>(_authName);
      expect(result, isA<_FakeAuth>());
    });

    test(
      'awaits pendingStart for a starting lazy-async service',
      () async {
        registry.stage(const _LazyAuthDescriptor());

        // Kick off register and getAsync concurrently. getAsync enters
        // the `starting` arm and awaits registration.pendingStart.
        final registerFuture = registry.register(_lazyName);
        final getFuture = registry.getAsync<_AuthService>(_lazyName);

        await Future<void>.delayed(Duration.zero);

        final built = _FakeAuth('via-getAsync');
        fakeLocator.storeInstance(_lazyName, built);
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.ready,
          instance: built,
        );

        await registerFuture;
        final result = await getFuture;
        expect(result, same(built));
      },
    );

    test('throws ServiceStartupFailed when service failed', () async {
      registry.stage(const _ThrowingDescriptor());

      await expectLater(
        registry.register('throwing'),
        throwsA(isA<ServiceStartupFailed>()),
      );

      await expectLater(
        registry.getAsync<_AuthService>('throwing'),
        throwsA(isA<ServiceStartupFailed>()),
      );
    });

    test('throws ServiceNotRegistered for unknown name', () async {
      await expectLater(
        registry.getAsync<_AuthService>('ghost'),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test(
      'throws ServiceTypeMismatch when requested type does not match',
      () async {
        registry.stage(_SyncAuthDescriptor());

        await expectLater(
          registry.getAsync<_LogService>(_authName),
          throwsA(isA<ServiceTypeMismatch>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // getSync
  // ---------------------------------------------------------------------------

  group('getSync', () {
    test('returns from locator when service is ready', () async {
      registry.stage(_SyncAuthDescriptor());
      await registry.register(_authName);

      expect(registry.getSync<_AuthService>(_authName), isA<_FakeAuth>());
    });

    test('throws ServiceNotReady when service is staged', () {
      registry.stage(_SyncAuthDescriptor());

      expect(
        () => registry.getSync<_AuthService>(_authName),
        throwsA(isA<ServiceNotReady>()),
      );
    });

    test('throws ServiceNotReady when service is starting', () async {
      registry.stage(const _LazyAuthDescriptor());

      // Kick register but don't await its completion — the lazy callback
      // hasn't fired `ready` yet, so status sits at `starting`.
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      expect(
        () => registry.getSync<_AuthService>(_lazyName),
        throwsA(isA<ServiceNotReady>()),
      );

      // Cleanup so the pending register resolves.
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: _FakeAuth('cleanup'),
      );
      await registerFuture;
    });

    test('throws ServiceStartupFailed when service failed', () async {
      registry.stage(const _ThrowingDescriptor());

      await expectLater(
        registry.register('throwing'),
        throwsA(isA<ServiceStartupFailed>()),
      );

      expect(
        () => registry.getSync<_AuthService>('throwing'),
        throwsA(isA<ServiceStartupFailed>()),
      );
    });

    test('throws ServiceNotRegistered for unknown name', () {
      expect(
        () => registry.getSync<_AuthService>('ghost'),
        throwsA(isA<ServiceNotRegistered>()),
      );
    });

    test('throws ServiceTypeMismatch when requested type does not match', () {
      registry.stage(_SyncAuthDescriptor());

      expect(
        () => registry.getSync<_LogService>(_authName),
        throwsA(isA<ServiceTypeMismatch>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // _onLocatorStateChange — exercised via lazy-async callbacks
  // ---------------------------------------------------------------------------

  group('locator state-change handling', () {
    test('starting callback marks registration as starting', () async {
      registry.stage(const _LazyAuthDescriptor());

      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      // Lazy descriptor's registerWith fires `starting` via the callback
      // during _performRegister — the registration is in `starting` now.
      expect(
        registry.registrationFor<_AuthService>(_lazyName).status,
        LocatorStatus.starting,
      );

      // Cleanup.
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: _FakeAuth('cleanup'),
      );
      await registerFuture;
    });

    test('ready callback marks registration as ready', () async {
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      final built = _FakeAuth('ready-drive');
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: built,
      );

      await registerFuture;

      final reg = registry.registrationFor<_AuthService>(_lazyName);
      expect(reg.status, LocatorStatus.ready);
      expect(reg.instance, same(built));
    });

    test(
      'ready callback without a ServiceClass instance throws StateError',
      () async {
        registry.stage(const _LazyAuthDescriptor());
        final registerFuture = registry.register(_lazyName);
        await Future<void>.delayed(Duration.zero);

        // Pass a non-ServiceClass value as `instance` — trips the
        // `instance is! ServiceClass` guard in _onLocatorStateChange.
        expect(
          () => fakeLocator.lazyCallbacks[_lazyName]!(
            LocatorStatus.ready,
            instance: 'not-a-service',
          ),
          throwsStateError,
        );

        // Cleanup with a real ready.
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.ready,
          instance: _FakeAuth('cleanup'),
        );
        await registerFuture;
      },
    );

    test('failed callback marks registration as failed', () async {
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      fakeLocator.lazyCallbacks[_lazyName]!(LocatorStatus.failed);
      await Future<void>.delayed(Duration.zero);

      expect(
        registry.registrationFor<_AuthService>(_lazyName).status,
        LocatorStatus.failed,
      );

      // The pending register future may still be in flight — silence it.
      await registerFuture.catchError((_) {});
    });

    test('staged callback is a no-op and does not crash', () async {
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      expect(
        () => fakeLocator.lazyCallbacks[_lazyName]!(LocatorStatus.staged),
        returnsNormally,
      );

      // Cleanup.
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: _FakeAuth('cleanup'),
      );
      await registerFuture;
    });
  });

  // ---------------------------------------------------------------------------
  // toString
  // ---------------------------------------------------------------------------

  group('toString', () {
    test('reports empty when no registrations', () {
      expect(registry.toString(), 'ServiceLocatorRegistry: <empty>');
    });

    test('reports count and entries when populated', () {
      registry.stage(_SyncAuthDescriptor());
      registry.stage(const _SyncLogDescriptor());

      final out = registry.toString();
      expect(out, contains('2 entries'));
      expect(out, contains(_authName));
      expect(out, contains(_logName));
    });
  });
}

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------

/// Fire-and-forget helper so tests can kick off a Future without awaiting.
// ignore: unreachable_from_main
void unawaited(Future<void> future) => future.ignore();
