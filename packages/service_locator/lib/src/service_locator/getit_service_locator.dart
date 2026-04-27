// packages/services_locator/lib/src/service_locator/getit_service_locator.dart
//
// Adapter that implements [ServiceLocator] on top of the get_it package.
// Accepts an injected [GetIt] instance so tests can use a fresh registry
// per test via `GetIt.asNewInstance()` instead of the `GetIt.I` singleton.

import 'dart:async' show TimeoutException;

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:my_logger/my_logger.dart' show MyLogger;
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
import 'package:service_locator/src/service_registry/service_registration.dart'
    show ServiceRegistration;

/// [ServiceLocator] adapter backed by the `get_it` package.
///
/// Translates the locator abstraction's sync / lazy-async registration
/// modes onto get_it's `registerSingleton` / `registerLazySingletonAsync`
/// APIs, and translates get_it's error surface (Dart [Error] for
/// not-ready lookups, [WaitingTimeOutException] for internal timeouts)
/// into the locator's typed [ServiceNotReady] / [ServiceItemTimeout]
/// exceptions. Production code holds only the [ServiceLocator]
/// interface; this class is the composition-root concretion.
///
/// One behavioral quirk worth knowing: sync singletons registered here
/// are NOT wired into get_it's ready-machinery — calling
/// `_getIt.isReady<T>()` on a plain sync singleton hangs indefinitely.
/// [getServiceAsync] works around this by trying `get` first and only
/// falling back to `getAsync` for lazy-async singletons that still need
/// materialization. See [registerServiceSync] for why `signalsReady` is
/// not used.
class GetItServiceLocator implements ServiceLocator {
  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  /// Creates an adapter backed by [getIt] (or [GetIt.I] if omitted).
  ///
  /// Pass a fresh `GetIt.asNewInstance()` in tests to avoid bleed
  /// between test cases; production code typically uses the default
  /// singleton.
  GetItServiceLocator({GetIt? getIt}) : _getIt = getIt ?? GetIt.I;

  final GetIt _getIt;

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  /// Resolves a registered service asynchronously, bounded by [timeout].
  ///
  /// Lookup strategy: try `get` first (succeeds for sync singletons and
  /// already-materialized lazy-async); on [Error] fall through to
  /// `getAsync` with a Dart-level `.timeout(timeout)` at the Future
  /// layer. Translates both [TimeoutException] (Dart) and
  /// [WaitingTimeOutException] (get_it's own) into [ServiceItemTimeout]
  /// — only the get_it path carries diagnostic payload.
  ///
  /// Throws [ServiceNotRegistered] if [name] was never registered under
  /// the generic type [SRV].
  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    _assertRegistered<SRV>(name);

    // Sync / already-materialized-lazy: `get` returns immediately.
    // Not-yet-materialized lazy-async: `get` throws [Error], we fall
    // through to `getAsync`. See class-level dartdoc for why sync
    // singletons aren't retrievable via `isReady`. Catches [Error]
    // rather than [Exception] — get_it's contract for "not ready".
    try {
      return _getIt.get<SRV>(instanceName: name);

      /// Allowed here because it is a limitation of GetIt
      // ignore: avoid_catching_errors
    } on Error {
      // Lazy-async not yet materialized. Fall through.
    }

    try {
      return await _getIt.getAsync<SRV>(instanceName: name).timeout(timeout);
    } on TimeoutException {
      // Translate Dart's async timeout into the locator-abstraction's own
      // [ServiceItemTimeout]. get_it's `getAsync` doesn't accept a timeout
      // argument, so we apply `.timeout(...)` at the Future level and
      // surface the result under the same error type production code
      // already handles. No `notReadyYet` diagnostic is available on this
      // path — the Dart-level `TimeoutException` doesn't carry one.
      throw ServiceItemTimeout(name, timeout);
      // coverage:ignore-start
      //
      // Defensive fallback: if get_it ever surfaces its own timeout here
      // (e.g. because an internal `isReady` is involved in `getAsync`'s
      // impl), translate it the same way — preserving the diagnostic
      // payload. get_it's current implementation does not produce this
      // exception from `getAsync`; the catch exists as a forward-compat
      // hedge against internal changes in the get_it package. Exercising
      // it would require mocking `GetIt` to fabricate a behavior it does
      // not actually have, which would test a fiction rather than real
      // production behavior. Excluded from coverage — if get_it's docs
      // ever reflect this path as reachable, remove the ignore-pragma
      // and write a real test.
    } on WaitingTimeOutException catch (e) {
      throw ServiceItemTimeout(
        name,
        timeout,
        notReadyYet: List<String>.unmodifiable(e.notReadyYet),
        waitedBy: Map<String, List<String>>.unmodifiable(e.areWaitedBy),
      );
      // coverage:ignore-end
    }
  }

  /// Resolves a registered service synchronously.
  ///
  /// Throws [ServiceNotRegistered] if [name] was never registered under
  /// [SRV]. Throws [ServiceNotReady] if a lazy-async registration has
  /// not yet been materialized — callers needing to wait for
  /// materialization should use [getServiceAsync] instead.
  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    _assertRegistered<SRV>(name);
    return _getOrThrowNotReady<SRV>(name);
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  @override
  Future<SRV> registerServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
  }) async {
    if (_getIt.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }
    _getIt.registerSingletonAsync(
      builder,
      instanceName: name,
    );
    try {
      await _getIt.isReady<SRV>(instanceName: name);
      //
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      debugPrint(e.toString());
    }
    return getServiceSync<SRV>(name: name);
  }

  /// Registers a lazy-async service under [name].
  ///
  /// Wires [builder] through [_runReportingBuilder] so a builder throw
  /// propagates both to get_it's ready-machinery and to the registry
  /// via [serviceState]. Emits [LocatorStatus.starting] synchronously
  /// before returning so the registry can update its state machine
  /// immediately.
  ///
  /// Throws [DuplicateServiceEntry] if [name] is already registered
  /// under [SRV].
  ///

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }
    _getIt.registerLazySingletonAsync<SRV>(
      () => _runReportingBuilder<SRV>(builder, serviceState),
      instanceName: name,
      onCreated: (service) {
        serviceState(LocatorStatus.ready, instance: service);
      },
    );
    serviceState(LocatorStatus.starting);
  }

  /// Registers a sync singleton [instance] under [name].
  ///
  /// Uses plain `registerSingleton` without `signalsReady: true`:
  /// `signalReady(instance)` looks the instance up in get_it's internal
  /// map by identity, and throws when the same instance is registered
  /// under two different names (a legitimate use case for the registry,
  /// which keys by name rather than by object identity). One consequence
  /// is that `isReady<SRV>(instanceName: name)` hangs on entries
  /// registered here — [getServiceAsync] works around this by trying
  /// `get` first.
  ///
  /// Throws [DuplicateServiceEntry] if [name] is already registered
  /// under [SRV]. Returns [instance] unchanged.
  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }
    // See class-level dartdoc and [registerServiceSync]'s dartdoc for
    // the full rationale: plain `registerSingleton` stores the instance
    // for immediate `get` retrieval without wiring into the
    // ready-machinery, and [getServiceAsync] compensates with its
    // try-`get`-first strategy. See get_it issue #210 for a related
    // race the simpler path also avoids.
    MyLogger.d('SRV: $SRV name: $name');
    return _getIt.registerSingleton<SRV>(instance, instanceName: name);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Throws [ServiceNotRegistered] when no service of type [SRV] is
  /// registered under [name]. Guards every public `get` so callers see
  /// a typed locator error rather than get_it's own assertion failure.
  void _assertRegistered<SRV extends ServiceClass>(String name) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) return;
    throw ServiceNotRegistered(name);
  }

  /// Wraps [builder] so that a failure is reported to the registry via
  /// [serviceState] before being rethrown to GetIt.
  ///
  /// Without this wrapper, a builder throw propagates to GetIt — which
  /// correctly surfaces it to `isReady` awaiters — but the registry's
  /// [ServiceRegistration] never leaves `starting`, blocking concurrent
  /// awaiters on [ServiceRegistration.pendingStart] indefinitely.
  ///
  /// Rethrow is unconditional: GetIt's internal bookkeeping still needs
  /// to see the failure so subsequent `isReady`/`get` calls behave
  /// correctly.
  Future<SRV> _runReportingBuilder<SRV extends ServiceClass>(
    Future<SRV> Function() builder,
    ReportServiceState serviceState,
  ) async {
    try {
      return await builder();
    } catch (error, stackTrace) {
      serviceState(
        LocatorStatus.failed,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Calls `_getIt.get<SRV>` and translates get_it's "not ready yet"
  /// [Error] into [ServiceNotReady].
  SRV _getOrThrowNotReady<SRV extends ServiceClass>(String name) {
    try {
      return _getIt.get<SRV>(instanceName: name);
      // permitted as it is a limitation of GetIt
      // ignore: avoid_catching_errors
    } on Error {
      // GetIt throws an Error (not Exception) when a singleton is not yet
      // ready. This is documented behaviour in the GetIt API.
      throw ServiceNotReady(name, status: 'GetIt.I.get<> failed');
    }
  }
}
