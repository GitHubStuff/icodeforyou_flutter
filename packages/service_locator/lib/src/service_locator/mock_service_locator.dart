// packages/services_locator/lib/src/service_locator/mock_service_locator.dart
//
// A hand-rolled, GetIt-free implementation of [ServiceLocator] intended
// for unit tests, widget tests, and local development. Provides
// deterministic control over service readiness via [completeLazyService]
// and [failLazyService] test hooks, so tests never need to race against
// real async builders.

// ignore_for_file: comment_references

import 'dart:async' show Completer, TimeoutException, unawaited;

import 'package:service_locator/src/errors.dart'
    show
        DuplicateServiceEntry,
        ServiceItemTimeout,
        ServiceNotReady,
        ServiceNotRegistered;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

/// Composite key pairing a service [Type] with its string name.
///
/// Entries are keyed by `(type, name)` rather than name alone so two
/// registrations that share a name but differ in type — unusual but
/// legal in principle — do not collide. Matches the GetIt adapter's
/// `isRegistered<SRV>(instanceName: name)` shape.
typedef _Key = ({Type type, String name});

// ---------------------------------------------------------------------------
// Entry hierarchy
// ---------------------------------------------------------------------------
//
// Two distinct lifecycles live in the registry map, so they get two
// distinct types. Mirrors the public [ServiceDescriptor] sealed hierarchy
// and removes the nullable-field + bang-operator smell of a single
// combined class.

/// Sealed base for an entry stored in [MockServiceLocator._entries].
sealed class _Entry {
  _Entry();
}

/// Entry for sync registrations: the instance is already built and
/// stored; no lifecycle machinery is needed.
class _SyncEntry extends _Entry {
  _SyncEntry({required this.instance});

  /// Typed as [Object] because the entry map holds entries for many
  /// service types; the generic [SRV] at read time narrows it.
  Object instance;
}

/// Entry for lazy-async registrations: carries a [Completer] that
/// pending `getServiceAsync` awaiters wait on, a stored `builder` that
/// runs on first access, and a `reportState` hook the registry
/// subscribes to for lifecycle transitions.
class _LazyAsyncEntry extends _Entry {
  _LazyAsyncEntry({required this.builder, required this.reportState})
    : completer = Completer<Object>() {
    // Silence the completer's error channel so a failure (from the
    // builder, from a [failLazyService] hook, or from [reset] while the
    // builder is in flight) does not surface as an unhandled async error
    // in the common case where no awaiter is subscribed.
    //
    // `getServiceAsync` installs its own listener on this future, so a
    // subscribed caller will still see errors through their own await.
    // [Future.ignore] only suppresses the unhandled-error channel — it
    // does not swallow errors seen by explicit listeners.
    //
    // Mirrors the same pattern used by `ServiceLocatorRegistry`'s
    // `_registerStaged` for its `pendingStart` completer.
    completer.future.ignore();
  }

  /// Resolves with the built instance on success, or with an error on
  /// failure. Shared across all concurrent `getServiceAsync` awaiters.
  final Completer<Object> completer;

  /// Factory producing the service instance on first access. Runs at
  /// most once per entry lifetime, lazily triggered by
  /// [MockServiceLocator._maybeStartBuilder].
  final Future<Object> Function() builder;

  /// Lifecycle callback provided at registration time. The locator
  /// fires this with `starting` at registration and with `ready` /
  /// `failed` once the builder (or a test hook) settles the entry.
  final ReportServiceState reportState;

  /// Cached instance once the builder
  /// (or [MockServiceLocator.completeLazyService]
  /// hook) resolves successfully. `null` until [isReady] flips to `true`.
  Object? instance;

  /// Whether the entry has settled into a ready state. Distinguishes
  /// "builder resolved successfully" from "completer in some other
  /// state"; failure paths leave this `false` and read `isCompleted`
  /// on the completer instead.
  bool isReady = false;

  /// Whether [MockServiceLocator._maybeStartBuilder] has already kicked
  /// the builder off. Prevents double-invocation when multiple
  /// `getServiceAsync` calls race before the first builder resolves.
  bool builderStarted = false;
}

/// In-memory [ServiceLocator] for tests.
///
/// Implements the full [ServiceLocator] contract without a get_it
/// dependency, and adds deterministic test hooks so tests can control
/// exactly when a lazy-async service becomes ready or failed instead of
/// racing against a real async builder:
///
///  * [completeLazyService] — manually resolves a lazy-async entry with
///    a test-provided instance.
///  * [failLazyService] — manually fails a lazy-async entry with a
///    test-provided error.
///  * [reset] — clears every registration and unblocks any in-flight
///    awaiters with a [StateError], for `tearDown` isolation.
///
/// The mock matches the GetIt adapter's error surface — same
/// [DuplicateServiceEntry] on collisions, same [ServiceItemTimeout] on
/// async timeouts, same [ServiceNotReady] on sync-before-ready — so
/// tests assert against the same error types production code observes.
class MockServiceLocator implements ServiceLocator {
  /// Creates a fresh mock with an empty registry. Tests typically
  /// create one per test or call [reset] in `tearDown`.
  MockServiceLocator();

  final Map<_Key, _Entry> _entries = <_Key, _Entry>{};

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  /// Resolves a registered service asynchronously.
  ///
  /// Sync entries return their stored instance immediately. Lazy-async
  /// entries kick off their builder on first call (once per entry) and
  /// await the shared completer bounded by [timeout]; subsequent calls
  /// receive the already-materialized instance. Throws
  /// [ServiceNotRegistered] if the `(SRV, name)` pair is unknown and
  /// [ServiceItemTimeout] if the builder doesn't settle in time.
  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    final entry = _assertRegistered<SRV>(name);

    switch (entry) {
      case _SyncEntry(:final instance):
        return instance as SRV;

      case _LazyAsyncEntry():
        if (entry.isReady) return entry.instance! as SRV;
        _maybeStartBuilder<SRV>(entry: entry);
        try {
          final built = await entry.completer.future.timeout(timeout);
          return built as SRV;
        } on TimeoutException {
          // Match the GetIt adapter's behavior: translate the async
          // timeout into the locator-abstraction's [ServiceItemTimeout]
          // so tests using this mock assert against the same error type
          // production code will see.
          throw ServiceItemTimeout(name, timeout);
        }
    }
  }

  /// Resolves a registered service synchronously.
  ///
  /// Sync entries return their stored instance immediately. Lazy-async
  /// entries throw [ServiceNotReady] if they haven't been resolved yet
  /// — callers needing to wait should use [getServiceAsync] or settle
  /// the entry first via [completeLazyService]. Throws
  /// [ServiceNotRegistered] if the `(SRV, name)` pair is unknown.
  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    final entry = _assertRegistered<SRV>(name);

    switch (entry) {
      case _SyncEntry(:final instance):
        return instance as SRV;

      case _LazyAsyncEntry():
        if (!entry.isReady) {
          throw ServiceNotReady(name, status: 'sync get before ready');
        }
        return entry.instance! as SRV;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  /// Registers an eager-async service under [name].
  ///
  /// Awaits [builder] to completion and stores the resolved instance as
  /// a sync entry, so subsequent [getServiceSync] / [getServiceAsync]
  /// calls return the materialized instance directly rather than the
  /// builder's [Future]. Throws [DuplicateServiceEntry] if `(SRV, name)`
  /// is already registered.
  @override
  Future<SRV> registerServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
  }) async {
    final key = _keyOf<SRV>(name);
    if (_entries.containsKey(key)) throw DuplicateServiceEntry(name);

    final instance = await builder();
    _entries[key] = _SyncEntry(instance: instance);
    return instance;
  }

  /// Registers a lazy-async service under [name].
  ///
  /// The builder does not run until a caller invokes [getServiceAsync];
  /// tests that want full control over readiness can skip the builder
  /// entirely by calling [completeLazyService] or [failLazyService]
  /// before any resolve. Emits [LocatorStatus.starting] through
  /// [serviceState] synchronously before returning. Throws
  /// [DuplicateServiceEntry] if `(SRV, name)` is already registered.
  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    final key = _keyOf<SRV>(name);
    if (_entries.containsKey(key)) throw DuplicateServiceEntry(name);

    _entries[key] = _LazyAsyncEntry(
      builder: builder,
      reportState: serviceState,
    );
    serviceState(LocatorStatus.starting);
  }

  /// Registers a sync service under [name], storing [instance] directly.
  ///
  /// Returns [instance] unchanged to match the [ServiceLocator]
  /// contract. Throws [DuplicateServiceEntry] if `(SRV, name)` is
  /// already registered.
  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    final key = _keyOf<SRV>(name);
    if (_entries.containsKey(key)) throw DuplicateServiceEntry(name);

    // The [ServiceLocator] interface does not plumb a [ReportServiceState]
    // through `registerServiceSync` — by design. [SyncServiceDescriptor]
    // signals `ready` directly from descriptor code, so the locator never
    // needs to emit it. Hence `_SyncEntry` carries no callback.
    _entries[key] = _SyncEntry(instance: instance);
    return instance;
  }

  // ---------------------------------------------------------------------------
  // Test hooks
  // ---------------------------------------------------------------------------

  /// Manually completes a lazy-async service with [instance], firing the
  /// registered [ReportServiceState] with [LocatorStatus.ready]. Use
  /// this in tests when you want full control over when a service
  /// becomes available rather than relying on the registered builder.
  ///
  /// No-op if the entry is already ready — repeated calls are safe.
  /// Throws [ServiceNotRegistered] if `(SRV, name)` is unknown and
  /// [StateError] if the entry was registered as sync (the hook is
  /// only meaningful for lazy-async).
  void completeLazyService<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    final entry = _assertLazyAsync<SRV>(name);
    if (entry.isReady) return;
    _markReady<SRV>(entry: entry, instance: instance);
  }

  /// Manually fails a lazy-async service. Future awaiters will receive
  /// [error]. No-op if the service has already been completed (either
  /// by the builder or a prior hook call).
  ///
  /// Reports [LocatorStatus.failed] to the registered [ReportServiceState]
  /// so the registry transitions its [ServiceRegistration] out of
  /// `starting` and stops blocking concurrent awaiters. Throws
  /// [ServiceNotRegistered] if `(SRV, name)` is unknown and [StateError]
  /// if the entry was registered as sync.
  void failLazyService<SRV extends ServiceClass>({
    required String name,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final entry = _assertLazyAsync<SRV>(name);
    if (entry.isReady) return;
    if (entry.completer.isCompleted) return;
    _markFailed(
      entry: entry,
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// Clears every registration. Call from `tearDown` to isolate tests.
  ///
  /// In-flight lazy-async entries (builder started, completer not yet
  /// resolved) are completed with a [StateError] so pending awaiters
  /// unblock instead of hanging past the end of the test.
  void reset() {
    for (final entry in _entries.values) {
      if (entry is _LazyAsyncEntry && !entry.completer.isCompleted) {
        entry.completer.completeError(
          StateError('MockServiceLocator reset while builder in flight'),
        );
      }
    }
    _entries.clear();
  }

  /// Returns whether a service is registered under `(SRV, name)`.
  /// Introspection helper for tests that want to assert registration
  /// state without triggering a resolve.
  bool isRegistered<SRV extends ServiceClass>({required String name}) =>
      _entries.containsKey(_keyOf<SRV>(name));

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Builds the composite `(type, name)` key used by [_entries].
  _Key _keyOf<SRV extends ServiceClass>(String name) => (type: SRV, name: name);

  /// Looks up an entry by generic [SRV] and [name]; throws
  /// [ServiceNotRegistered] when missing. Guards every public `get`
  /// and test hook path so callers see a typed locator error.
  _Entry _assertRegistered<SRV extends ServiceClass>(String name) {
    final entry = _entries[_keyOf<SRV>(name)];
    if (entry == null) throw ServiceNotRegistered(name);
    return entry;
  }

  /// Resolves [name] to a [_LazyAsyncEntry] or throws [StateError] if
  /// the registration was sync (test hooks only make sense for lazy).
  _LazyAsyncEntry _assertLazyAsync<SRV extends ServiceClass>(String name) {
    final entry = _assertRegistered<SRV>(name);
    if (entry is! _LazyAsyncEntry) {
      throw StateError(
        '"$name" is registered as sync; lazy-async test hook not applicable',
      );
    }
    return entry;
  }

  /// Kicks off [entry]'s stored builder if it hasn't already run.
  /// Idempotent: guarded by [_LazyAsyncEntry.builderStarted] so racing
  /// `getServiceAsync` calls all wait on the same completer.
  ///
  /// If a test hook (`completeLazyService` / `failLazyService`) settles
  /// the entry while the builder is in flight, the builder's eventual
  /// result is dropped — the injected outcome wins.
  void _maybeStartBuilder<SRV extends ServiceClass>({
    required _LazyAsyncEntry entry,
  }) {
    if (entry.builderStarted) return;
    entry.builderStarted = true;

    Future<void> run() async {
      try {
        final built = await entry.builder();
        // A test hook may have completed the entry while the builder was in
        // flight; in that case the injected instance wins and we drop the
        // builder's result.
        if (entry.isReady || entry.completer.isCompleted) return;
        _markReady<SRV>(entry: entry, instance: built as SRV);
      } on Object catch (error, stackTrace) {
        // Same race: if the entry was already resolved by a hook, swallow
        // the builder error rather than crashing on a double-complete.
        if (entry.isReady || entry.completer.isCompleted) return;
        _markFailed(entry: entry, error: error, stackTrace: stackTrace);
      }
    }

    unawaited(run());
  }

  /// Marks [entry] as ready: caches the instance, flips `isReady`,
  /// resolves the completer for pending awaiters, and notifies the
  /// registry via [ReportServiceState].
  void _markReady<SRV extends ServiceClass>({
    required _LazyAsyncEntry entry,
    required SRV instance,
  }) {
    entry
      ..instance = instance
      ..isReady = true;
    entry.completer.complete(instance);
    entry.reportState(LocatorStatus.ready, instance: instance);
  }

  /// Marks [entry] as failed: completes the completer with [error] and
  /// notifies the registry via [ReportServiceState] so the registration
  /// transitions from `starting` to `failed` and concurrent awaiters on
  /// [ServiceRegistration.pendingStart] unblock.
  void _markFailed({
    required _LazyAsyncEntry entry,
    required Object error,
    required StackTrace stackTrace,
  }) {
    entry.completer.completeError(error, stackTrace);
    entry.reportState(
      LocatorStatus.failed,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
