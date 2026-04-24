// packages/services_locator/lib/src/service_locator/service_locator.dart
//
// Abstract interface for a service locator: four methods (two to
// register, two to resolve) and a callback typedef for lifecycle
// reporting. Concrete implementations live alongside this file —
// [GetItServiceLocator] for production, [MockServiceLocator] for tests.

import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;

/// Callback invoked by a [ServiceLocator] to report lifecycle state
/// transitions for a registered service.
///
/// [status] is the new status. For [LocatorStatus.ready], [instance]
/// must be non-null. For [LocatorStatus.failed], [error] must be
/// non-null and [stackTrace] should accompany it so the registry can
/// preserve the original failure site. For [LocatorStatus.starting] and
/// [LocatorStatus.staged] the three optional parameters are expected to
/// be null — those transitions carry no payload.
///
/// Implementations of [ServiceLocator] are expected to invoke this
/// callback synchronously from registration entry points (to emit
/// `starting`) and later from builder-resolution paths (to emit `ready`
/// or `failed`). The `ServiceLocatorRegistry` wires its
/// `_onLocatorStateChange` through this callback to drive
/// [ServiceRegistration]'s state machine.
typedef ReportServiceState =
    void Function(
      LocatorStatus status, {
      ServiceClass? instance,
      Object? error,
      StackTrace? stackTrace,
    });

/// Abstraction over an underlying service-registration backend.
///
/// Carves the registration surface into four methods — two to register
/// (sync eager, lazy async) and two to resolve (sync, async) — so the
/// rest of the package can depend on this interface instead of the
/// concrete backend. Implementations encapsulate backend-specific
/// quirks (get_it's ready-machinery, Map-based storage in the mock)
/// and translate backend errors into the locator's typed error surface
/// (`ServiceNotRegistered`, `ServiceNotReady`, `ServiceItemTimeout`,
/// `DuplicateServiceEntry`).
///
/// Two implementations ship with the package:
///
///  * `GetItServiceLocator` — production adapter backed by the `get_it`
///    package; suitable for real app startup and widget trees.
///  * `MockServiceLocator` — hand-rolled in-memory implementation for
///    tests, with deterministic hooks for controlling lazy-async
///    readiness (`completeLazyService`, `failLazyService`).
///
/// Callers typically do not hold a [ServiceLocator] directly — they
/// hold a `ServiceLocatorRegistry` or one of its narrower
/// `ServiceRegistrar` / `ServiceResolver` interfaces, which delegate
/// through to an injected [ServiceLocator] at the composition root.
abstract interface class ServiceLocator {
  //+ GET

  /// Resolves a registered service asynchronously, bounded by [timeout].
  ///
  /// For lazy-async registrations the first call triggers the builder;
  /// subsequent calls return the cached instance. Sync registrations
  /// return immediately regardless of [timeout]. Throws
  /// `ServiceNotRegistered` if [name] was never registered under [SRV],
  /// and `ServiceItemTimeout` if a lazy-async builder fails to settle
  /// within [timeout].
  ///
  /// Implementations must honor [timeout] as a hard upper bound — a
  /// builder that returns a [Future] which never completes must not
  /// strand the caller past the timeout.
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  });

  /// Resolves a registered service synchronously.
  ///
  /// Sync registrations return their stored instance immediately.
  /// Lazy-async registrations that have already been materialized
  /// (either by a prior [getServiceAsync] or a test hook on the mock)
  /// also return immediately. An unmaterialized lazy-async registration
  /// throws `ServiceNotReady` — callers needing to wait should use
  /// [getServiceAsync] instead. Throws `ServiceNotRegistered` if [name]
  /// was never registered under [SRV].
  SRV getServiceSync<SRV extends ServiceClass>({required String name});

  //+ REGISTER

  /// Registers a lazy-async service under [name].
  ///
  /// [builder] is stored and invoked on the first [getServiceAsync]
  /// call that reaches this locator. A successful completion caches
  /// the instance for all subsequent resolvers (including
  /// [getServiceSync]); a throw marks the registration terminally
  /// failed and propagates through the registry's
  /// `ServiceStartupFailed` wrapping.
  ///
  /// [serviceState] is the lifecycle callback the registry supplies so
  /// it can track status transitions. Implementations must invoke
  /// [serviceState] synchronously with [LocatorStatus.starting] during
  /// this method, then again with [LocatorStatus.ready] or
  /// [LocatorStatus.failed] once the builder settles.
  ///
  /// Throws `DuplicateServiceEntry` if the same `(SRV, name)` pair is
  /// already registered.
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  });

  /// Registers [instance] synchronously under [name] and returns it
  /// unchanged (so callers can chain the result into further wiring if
  /// needed).
  ///
  /// Deliberately does NOT accept a [ReportServiceState] callback —
  /// sync registrations transition straight to [LocatorStatus.ready]
  /// and the `SyncServiceDescriptor` emits that transition itself from
  /// descriptor code. Moving the emission into the locator would
  /// duplicate the signal.
  ///
  /// Throws `DuplicateServiceEntry` if the same `(SRV, name)` pair is
  /// already registered.
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  });
}
