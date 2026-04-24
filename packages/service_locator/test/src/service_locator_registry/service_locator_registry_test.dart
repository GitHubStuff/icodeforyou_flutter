// packages/services_locator/test/src/service_locator_registry/service_locator_registry_test.dart
//
// Full-coverage test suite for [ServiceLocatorRegistry]. Uses a scripted
// fake ServiceLocator so tests can drive state-change callbacks
// deterministically — including the error + stackTrace fields that
// `ReportServiceState` now carries on failed transitions.
//

// ignore_for_file: avoid_types_on_closure_parameters, cascade_invocations

import 'dart:async' show Completer;

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/errors.dart'
    show
        BlankServiceName,
        CircularDependency,
        DuplicateServiceEntry,
        DuplicateServiceType,
        InvalidServiceType,
        ServiceNotReady,
        ServiceNotRegistered,
        ServiceStartupFailed,
        ServiceTypeMismatch;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show LazyAsyncServiceDescriptor, ServiceClass, SyncServiceDescriptor;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;
import 'package:service_locator/src/service_locator_registry/service_locator_registry.dart'
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
  _SyncLogDescriptor({this.deps = const []});

  final List<Type> deps;

  @override
  String get name => 'log';

  @override
  List<Type> get dependencies => deps;

  @override
  _LogService Function() get builder => _FakeLog.new;
}

class _SyncDbDescriptor extends SyncServiceDescriptor<_DbService> {
  _SyncDbDescriptor({this.deps = const []});

  final List<Type> deps;

  @override
  String get name => 'db';

  @override
  List<Type> get dependencies => deps;

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

/// Descriptor whose builder throws — exercises the catch branch in
/// `_performRegister`. Uses `_LogService` so tests can combine it with a
/// healthy `_AuthService` descriptor without tripping the
/// `DuplicateServiceType` guard.
class _ThrowingLogDescriptor extends SyncServiceDescriptor<_LogService> {
  const _ThrowingLogDescriptor();

  @override
  String get name => 'throwing-log';

  @override
  _LogService Function() get builder =>
      () => throw StateError('descriptor refused to register');
}

/// Descriptor typed on the marker interface itself — locks in the Bug #6
/// `InvalidServiceType` guard. Staging this must fail because the marker
/// interface cannot key the `Type → name` index meaningfully.
///
/// The builder is never invoked — `stage()` rejects the descriptor before
/// it ever reaches `register()`, so the closure body is unreachable and
/// its exact return value doesn't matter.
class _WideTypeDescriptor extends SyncServiceDescriptor<ServiceClass> {
  const _WideTypeDescriptor();

  @override
  String get name => 'wide';

  @override
  ServiceClass Function() get builder =>
      () => _FakeAuth('unreachable');
}

// ---------------------------------------------------------------------------
// Scripted fake locator
//
// - registerServiceSync fires no state callback — the sync descriptor is
//   responsible for emitting `ready` after calling this method.
// - registerServiceLazyAsync captures the callback so tests can drive
//   `starting` / `ready` / `failed` / `staged` transitions on demand,
//   including the error + stackTrace fields now carried on the typedef.
// - getServiceAsync / getServiceSync return whatever was stored via
//   registerServiceSync or storeInstance.
// ---------------------------------------------------------------------------

typedef _FullReportState =
    void Function(
      LocatorStatus state, {
      ServiceClass? instance,
      Object? error,
      StackTrace? stackTrace,
    });

class _FakeLocator implements ServiceLocator {
  final Map<String, Object> _instances = {};

  /// Captured state callbacks per registered lazy-async name. Tests drive
  /// transitions by invoking `lazyCallbacks[name]!(status, instance: ...)`
  /// or `lazyCallbacks[name]!(status, error: ..., stackTrace: ...)`.
  final Map<String, _FullReportState> lazyCallbacks = {};

  /// Completers that `getServiceAsync` awaits when the instance isn't
  /// available yet. Completed when a test fires the `ready` callback
  /// through [lazyCallbacks] (see the wrapper installed in
  /// [registerServiceLazyAsync]).
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
    // with an instance, pending getServiceAsync awaiters are resolved;
    // when it fires `failed` with an error, pending awaiters are
    // rejected. Forwards all four ReportServiceState fields so tests
    // can exercise the failed-path error/stackTrace contracts.
    lazyCallbacks[name] =
        (
          LocatorStatus state, {
          ServiceClass? instance,
          Object? error,
          StackTrace? stackTrace,
        }) {
          if (state == LocatorStatus.ready && instance != null) {
            _instances[name] = instance;
            _completePending(name, instance);
          } else if (state == LocatorStatus.failed && error != null) {
            _failPending(name, error, stackTrace);
          }
          serviceState(
            state,
            instance: instance,
            error: error,
            stackTrace: stackTrace,
          );
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

  void _failPending(String name, Object error, StackTrace? stackTrace) {
    final pending = _pendingGets.remove(name);
    if (pending != null && !pending.isCompleted) {
      pending.completeError(error, stackTrace);
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
const _throwingName = 'throwing-log';

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

    test('isStaged returns true for a staged descriptor', () {
      registry.stage(_SyncAuthDescriptor());
      expect(registry.isStaged(_authName), isTrue);
    });

    test('isStaged returns false for an unstaged name', () {
      expect(registry.isStaged('ghost'), isFalse);
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

    test(
      'throws DuplicateServiceType on second stage with same service type',
      () {
        registry.stage(_SyncAuthDescriptor());

        // Second descriptor for _AuthService under a different name —
        // collides on the _typeToName index.
        expect(
          () => registry.stage(
            _SyncAuthDescriptor(descriptorName: 'auth-alt'),
          ),
          throwsA(isA<DuplicateServiceType>()),
        );
      },
    );

    test(
      'throws InvalidServiceType when descriptor is typed on the marker',
      () {
        // Locks down the Bug #6 guard: `SyncServiceDescriptor<ServiceClass>`
        // cannot participate in the Type → name index.
        expect(
          () => registry.stage(const _WideTypeDescriptor()),
          throwsA(isA<InvalidServiceType>()),
        );
      },
    );
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
  // register — happy paths
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

    test('registers dependencies before the dependent service', () async {
      registry.stage(_SyncLogDescriptor());
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

      // Unstaged deps are a graph-level configuration error, surfaced by
      // the stage-time cycle check's `dependenciesOf` call before any
      // registration work begins. Symmetric with cycle handling: both
      // kinds of graph error leave the registration at `staged` so the
      // config can be fixed and `register` retried without a dangling
      // `failed` state.
      await expectLater(
        registry.register(_authName),
        throwsA(isA<ServiceNotRegistered>()),
      );

      expect(
        registry.registrationFor<_AuthService>(_authName).status,
        LocatorStatus.staged,
      );
    });

    test('registers a chain of dependencies transitively', () async {
      registry.stage(_SyncDbDescriptor());
      registry.stage(_SyncLogDescriptor());
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

    test(
      'register on a failed service rethrows ServiceStartupFailed',
      () async {
        registry.stage(const _ThrowingLogDescriptor());

        // First call — _performRegister catches, marks failed, rethrows.
        await expectLater(
          registry.register(_throwingName),
          throwsA(isA<ServiceStartupFailed>()),
        );

        // Second call — hits the `failed` switch arm via _awaitNonStaged
        // and rethrows the canonical wrapper directly.
        await expectLater(
          registry.register(_throwingName),
          throwsA(isA<ServiceStartupFailed>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // register — cycle detection  (Bug #5)
  // ---------------------------------------------------------------------------
  //
  // Cycles are detected at `register` entry by running a DFS graph check
  // over all currently-staged descriptors — cheap, synchronous, and run
  // once per public `register` call before any registration work begins.
  // Stage order is independent; a cycle only matters when `register` is
  // called and walks the graph. Affected registrations stay at `staged`
  // (they never transitioned past it) so a later `register` call after
  // the cycle is resolved can retry from a clean slate.

  group('register — cycle detection', () {
    test('self-cycle throws CircularDependency', () async {
      // A service can't depend on itself.
      registry.stage(_SyncAuthDescriptor(deps: const [_AuthService]));

      await expectLater(
        registry.register(_authName),
        throwsA(isA<CircularDependency>()),
      );
    });

    test('two-node cycle throws CircularDependency', () async {
      registry.stage(_SyncAuthDescriptor(deps: const [_LogService]));
      registry.stage(_SyncLogDescriptor(deps: const [_AuthService]));

      await expectLater(
        registry.register(_authName),
        throwsA(isA<CircularDependency>()),
      );
    });

    test('three-node cycle throws CircularDependency', () async {
      registry.stage(_SyncAuthDescriptor(deps: const [_LogService]));
      registry.stage(_SyncLogDescriptor(deps: const [_DbService]));
      registry.stage(_SyncDbDescriptor(deps: const [_AuthService]));

      await expectLater(
        registry.register(_authName),
        throwsA(isA<CircularDependency>()),
      );
    });

    test(
      'chain with a cycle reports the chain in order',
      () async {
        registry.stage(_SyncAuthDescriptor(deps: const [_LogService]));
        registry.stage(_SyncLogDescriptor(deps: const [_AuthService]));

        await expectLater(
          registry.register(_authName),
          throwsA(
            isA<CircularDependency>().having(
              (e) => e.chain,
              'chain',
              [_authName, _logName, _authName],
            ),
          ),
        );
      },
    );

    test('cycle-detected registrations remain in staged state', () async {
      registry.stage(_SyncAuthDescriptor(deps: const [_LogService]));
      registry.stage(_SyncLogDescriptor(deps: const [_AuthService]));

      await expectLater(
        registry.register(_authName),
        throwsA(isA<CircularDependency>()),
      );

      // Both registrations stay at `staged` — cycle detection runs at
      // `register` entry, before any `markStarting` transition, so nothing
      // needs to be rolled back. A later `register` call after the cycle
      // is resolved starts from a clean slate.
      expect(
        registry.registrationFor<_AuthService>(_authName).status,
        LocatorStatus.staged,
      );
      expect(
        registry.registrationFor<_LogService>(_logName).status,
        LocatorStatus.staged,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // register — concurrency  (Bugs #2 and #8)
  // ---------------------------------------------------------------------------

  group('register — concurrency', () {
    test(
      'concurrent register calls on a starting service share pendingStart',
      () async {
        registry.stage(const _LazyAuthDescriptor());

        final first = registry.register(_lazyName);
        final second = registry.register(_lazyName);

        // Let microtasks settle so the lazy callback is captured.
        await Future<void>.delayed(Duration.zero);

        // Drive ready via the captured callback.
        final built = _FakeAuth('lazy-drive');
        fakeLocator.storeInstance(_lazyName, built);
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.ready,
          instance: built,
        );

        await Future.wait<void>([first, second]);

        expect(
          registry.registrationFor<_AuthService>(_lazyName).status,
          LocatorStatus.ready,
        );
      },
    );

    test(
      'register after a post-handoff failure surfaces ServiceStartupFailed',
      () async {
        // For lazy-async services, `pendingStart` resolves when the
        // locator handoff finishes — which happens BEFORE the builder
        // runs (or fails). Registration stays in `starting` after the
        // handoff resolves; a later background-driven `failed` (builder
        // threw, external fail-injection) flips status to `failed`.
        //
        // This test asserts the invariant: once a registration reaches
        // terminal `failed`, every subsequent `register` call surfaces
        // the canonical `ServiceStartupFailed` — regardless of whether
        // the caller hits the `starting → await → isFailed` recheck
        // path (Bug #8) or the direct `failed` arm of `_awaitNonStaged`.
        // Both routes converge on the same `asStartupFailed()` call.
        registry.stage(const _LazyAuthDescriptor());

        // First caller completes the handoff fully. Status lands at
        // `starting`, `pendingStart` resolves successfully.
        await registry.register(_lazyName);

        // Simulate a background failure (e.g. builder threw after
        // materialization was triggered elsewhere). Registration flips
        // to `failed`.
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.failed,
          error: StateError('builder failed after handoff'),
          stackTrace: StackTrace.current,
        );

        // A later register call observes the failure.
        await expectLater(
          registry.register(_lazyName),
          throwsA(isA<ServiceStartupFailed>()),
        );
      },
    );

    test(
      'concurrent register observes failure flipped between handoff and resume',
      () async {
        // Exercises the Bug #8 inner-switch `failed` arm of
        // [_awaitNonStaged]: a concurrent caller enters the `starting`
        // branch and awaits `pendingStart`. The status then flips to
        // `failed` AFTER `pendingStart` resolves but BEFORE the awaiter's
        // microtask runs. When the awaiter resumes, the inner switch
        // observes `failed` and throws the canonical `ServiceStartupFailed`.
        //
        // The timing window this targets is narrow but deterministic for
        // lazy-async services: the handoff's completer resolves inside
        // `_performRegister` right after the fake locator stores the
        // builder callback; any subsequent callback firing (synchronous,
        // in the test's own turn) lands before pending microtasks drain.
        // This exact ordering is why the defensive post-await recheck
        // exists — without it, the inner arm would fall through to
        // `starting` and silently return while the real failure goes
        // unreported.
        registry.stage(const _LazyAuthDescriptor());

        // First caller drives the handoff to completion. Status settles
        // at `starting`, `pendingStart` is resolved.
        await registry.register(_lazyName);

        // Second caller enters `_awaitNonStaged.starting` and awaits
        // `pendingStart`. Because `pendingStart` is already resolved, the
        // continuation is scheduled as a microtask — it will NOT run
        // until the current synchronous turn finishes.
        final secondRegister = registry.register(_lazyName);

        // Before yielding (i.e. before the microtask queue drains), flip
        // the registration to `failed`. This synchronous callback runs
        // in the current turn, BEFORE the second caller's microtask.
        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.failed,
          error: StateError('builder failed after handoff'),
          stackTrace: StackTrace.current,
        );

        // Now drain the microtask queue. The second caller's await
        // resumes, observes `failed` in the inner switch, and throws.
        await expectLater(
          secondRegister,
          throwsA(isA<ServiceStartupFailed>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // ServiceStartupFailed identity  (Bug #2-cosmetic)
  // ---------------------------------------------------------------------------
  //
  // Every observer of a given failure event — the original thrower, later
  // getAsync/getSync/register queries, concurrent awaiters — must receive
  // the same exception object. `asStartupFailed()` returns the canonical
  // wrapper constructed once inside `markFailed`.

  group('ServiceStartupFailed identity', () {
    test(
      'repeated register on a failed service returns the same exception',
      () async {
        registry.stage(const _ThrowingLogDescriptor());

        ServiceStartupFailed? first;
        ServiceStartupFailed? second;
        try {
          await registry.register(_throwingName);
        } on ServiceStartupFailed catch (e) {
          first = e;
        }
        try {
          await registry.register(_throwingName);
        } on ServiceStartupFailed catch (e) {
          second = e;
        }

        expect(first, isNotNull);
        expect(second, same(first));
      },
    );

    test(
      'register and getSync on a failed service return the same exception',
      () async {
        registry.stage(const _ThrowingLogDescriptor());

        ServiceStartupFailed? fromRegister;
        ServiceStartupFailed? fromGetSync;
        try {
          await registry.register(_throwingName);
        } on ServiceStartupFailed catch (e) {
          fromRegister = e;
        }
        try {
          registry.getSync<_LogService>(_throwingName);
        } on ServiceStartupFailed catch (e) {
          fromGetSync = e;
        }

        expect(fromRegister, isNotNull);
        expect(fromGetSync, same(fromRegister));
      },
    );

    test(
      'register and getAsync on a failed service return the same exception',
      () async {
        registry.stage(const _ThrowingLogDescriptor());

        ServiceStartupFailed? fromRegister;
        ServiceStartupFailed? fromGetAsync;
        try {
          await registry.register(_throwingName);
        } on ServiceStartupFailed catch (e) {
          fromRegister = e;
        }
        try {
          await registry.getAsync<_LogService>(_throwingName);
        } on ServiceStartupFailed catch (e) {
          fromGetAsync = e;
        }

        expect(fromRegister, isNotNull);
        expect(fromGetAsync, same(fromRegister));
      },
    );
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

    test(
      'getAsync on a starting service surfaces post-handoff failure',
      () async {
        // Bug #8 coverage via `_resolveStartingAsync`: after awaiting
        // `pendingStart`, the registry re-checks `isFailed` before
        // delegating to the locator. This matters when the registration
        // transitioned to `failed` between the handoff completing and
        // the caller's await resuming.
        //
        // Setup: drive registration through the handoff to `starting`
        // (pendingStart resolves), then flip to `failed` via the
        // callback. The registration is now terminally failed, but
        // `pendingStart` already resolved successfully.
        registry.stage(const _LazyAuthDescriptor());
        await registry.register(_lazyName);

        fakeLocator.lazyCallbacks[_lazyName]!(
          LocatorStatus.failed,
          error: StateError('builder failed after handoff'),
          stackTrace: StackTrace.current,
        );

        // A getAsync call now routes to the `failed` arm directly —
        // asStartupFailed wraps the canonical ServiceStartupFailed.
        await expectLater(
          registry.getAsync<_AuthService>(_lazyName),
          throwsA(isA<ServiceStartupFailed>()),
        );
      },
    );

    test('throws ServiceStartupFailed when service failed', () async {
      registry.stage(const _ThrowingLogDescriptor());

      await expectLater(
        registry.register(_throwingName),
        throwsA(isA<ServiceStartupFailed>()),
      );

      await expectLater(
        registry.getAsync<_LogService>(_throwingName),
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
      registry.stage(const _ThrowingLogDescriptor());

      await expectLater(
        registry.register(_throwingName),
        throwsA(isA<ServiceStartupFailed>()),
      );

      expect(
        () => registry.getSync<_LogService>(_throwingName),
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

    test('ready callback without an instance throws StateError', () async {
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      // Null instance on `ready` trips the guard in _markReadyOrThrow.
      expect(
        () => fakeLocator.lazyCallbacks[_lazyName]!(LocatorStatus.ready),
        throwsStateError,
      );

      // Cleanup with a real ready.
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: _FakeAuth('cleanup'),
      );
      await registerFuture;
    });

    test('failed callback with error marks registration as failed', () async {
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      final error = StateError('builder failed');
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.failed,
        error: error,
        stackTrace: StackTrace.current,
      );

      final reg = registry.registrationFor<_AuthService>(_lazyName);
      expect(reg.status, LocatorStatus.failed);
      expect(reg.error, same(error));

      // Silence the register future — it now resolves with the failure.
      await registerFuture.catchError((_) {});
    });

    test('failed callback without error throws StateError', () async {
      // Locks down the `_markFailedOrThrow` null-error guard — a locator
      // that reports `failed` must also provide an error object.
      registry.stage(const _LazyAuthDescriptor());
      final registerFuture = registry.register(_lazyName);
      await Future<void>.delayed(Duration.zero);

      expect(
        () => fakeLocator.lazyCallbacks[_lazyName]!(LocatorStatus.failed),
        throwsStateError,
      );

      // Cleanup.
      fakeLocator.lazyCallbacks[_lazyName]!(
        LocatorStatus.ready,
        instance: _FakeAuth('cleanup'),
      );
      await registerFuture;
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
      registry.stage(_SyncLogDescriptor());

      final out = registry.toString();
      expect(out, contains('2 entries'));
      expect(out, contains(_authName));
      expect(out, contains(_logName));
    });
  });
}
