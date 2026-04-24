// packages/services_locator/lib/src/service_descriptor/service_descriptor.dart
//
// Descriptor hierarchy declaring how a service is registered with a
// [ServiceLocator]. The sealed base [ServiceDescriptor] and its two
// concrete subclasses — [SyncServiceDescriptor] (eager, synchronous) and
// [LazyAsyncServiceDescriptor] (builder-on-first-access) — cover every
// registration mode the locator supports.

import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;
import 'package:service_locator/src/service_locator_registry/service_registration.dart'
    show ServiceRegistration;

/// Marker interface every service contract must implement.
///
/// The locator's generic APIs are bounded on `extends ServiceClass`, so
/// domain types registered with the registry must conform either directly
/// (e.g. `abstract interface class AuthService implements ServiceClass`)
/// or transitively. The marker carries no members — it exists to give
/// generics like [ServiceLocator.getServiceSync] a compile-time handle
/// on "something registered here" without falling back to `dynamic`.
abstract interface class ServiceClass {}

/// Sealed base describing how a service is registered with a
/// [ServiceLocator].
///
/// A descriptor is a declarative value: it names the service, lists its
/// dependencies, declares its timeout, and knows how to hand itself to a
/// locator. Descriptors hold no runtime state — instances, status, and
/// pending futures live on [ServiceRegistration].
///
/// The hierarchy is sealed so the registry can reason about every
/// registration mode at compile time:
///
///  * [SyncServiceDescriptor] — builder runs eagerly during
///    `registerWith`; registration transitions straight to
///    [LocatorStatus.ready].
///  * [LazyAsyncServiceDescriptor] — builder is handed to the locator
///    and runs on first `getServiceAsync` access; registration stays at
///    [LocatorStatus.starting] until the builder resolves.
///
/// New registration modes must be added as additional sealed subclasses
/// so every exhaustive switch in the registry is forced to handle them.
/// Subclasses are expected to be `const` where possible so descriptor
/// instances can live in `const` composition-root lists.
sealed class ServiceDescriptor<SRV extends ServiceClass> {
  /// Base constructor for sealed subclasses. Prefer `const` forwarders
  /// so concrete descriptors can live in `const` lists.
  const ServiceDescriptor();

  /// Default timeout applied when a subclass does not override [timeout].
  ///
  /// Used by [LazyAsyncServiceDescriptor] via
  /// [ServiceLocator.getServiceAsync] to bound how long the registry
  /// will wait for a builder to complete. [SyncServiceDescriptor]
  /// ignores this — its builder runs synchronously and cannot time out.
  ///
  /// Thirty seconds is chosen to be comfortably longer than plausible
  /// cold-start I/O (database warm-up, remote config fetch, platform
  /// channel handshake) while still flagging stuck builders.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Unique identifier for this service within the registry.
  ///
  /// The primary registration key: `register(name)`, `getAsync(name)`,
  /// and `getSync(name)` all look entries up by this string. Blank or
  /// whitespace-only names are rejected at
  /// `ServiceLocatorRegistry.stage` with `BlankServiceName`; duplicates
  /// raise `DuplicateServiceEntry`.
  String get name;

  /// Types this service depends on.
  ///
  /// The registry walks this list during `register(name)` and recurses
  /// to register each dependency before the dependent. Each listed type
  /// must match a staged descriptor whose [serviceType] equals the
  /// listed type; the registry resolves types to names through its
  /// internal `Type → name` index.
  List<Type> get dependencies => const [];

  /// Maximum time a [LazyAsyncServiceDescriptor]'s builder is given to
  /// complete before the registry throws `ServiceItemTimeout`. Defaults
  /// to [defaultTimeout].
  Duration get timeout => defaultTimeout;

  /// The concrete service type this descriptor registers.
  ///
  /// Captured from the generic parameter [SRV] at the point where the
  /// descriptor's concrete subclass is defined, so the type survives
  /// even when callers hold this descriptor through a widened reference
  /// (e.g. `ServiceDescriptor<ServiceClass>` when iterating a list).
  ///
  /// The registry uses this to key its `Type → name` index, avoiding
  /// the generic-erasure collapse that would occur if it relied on the
  /// call-site [SRV] of `stage<SRV>(...)`.
  Type get serviceType => SRV;

  /// Constructs a [ServiceRegistration] reified to this descriptor's
  /// concrete [SRV] type.
  ///
  /// Used by the registry instead of `ServiceRegistration<SRV>(descriptor)`
  /// at the `stage` call site. When callers stage descriptors through a
  /// widened reference (e.g. `for (final d in listOfDescriptors) ...`),
  /// the call-site `SRV` erases to [ServiceClass] and would produce a
  /// `ServiceRegistration<ServiceClass>` — which later fails the
  /// `is ServiceRegistration<ConcreteType>` check inside
  /// `registrationFor`. Dispatching through this method instead binds
  /// `SRV` at the concrete subclass level, where it is known exactly.
  ServiceRegistration<SRV> toRegistration() =>
      ServiceRegistration<SRV>(this);

  /// Registers this descriptor's service with [locator], reporting
  /// lifecycle transitions through [serviceState].
  ///
  /// Called by the registry once per successful `register(name)` call
  /// after dependency resolution completes. Subclasses implement the
  /// two supported flows: [SyncServiceDescriptor] builds and fires
  /// `ready` before returning; [LazyAsyncServiceDescriptor] hands the
  /// builder off and lets the locator drive transitions from first
  /// `getServiceAsync`.
  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  });

  /// Debug representation including name, declared dependencies, and
  /// timeout in seconds. Not a stable API; format may evolve.
  @override
  String toString() =>
      'ServiceDescriptor(name: "$name", deps: $dependencies, '
      'timeout: ${timeout.inSeconds}s)';
}

/// Descriptor for services whose builder runs eagerly and synchronously
/// at registration time.
///
/// Use this mode for cheap instances with no async initialization:
/// value objects, in-memory repositories, configuration holders, pure
/// utility classes. The registration transitions straight to
/// [LocatorStatus.ready] inside [registerWith] and is immediately
/// retrievable via both `getServiceSync` and `getServiceAsync`.
///
/// For anything that performs I/O or needs to resolve a [Future],
/// prefer [LazyAsyncServiceDescriptor] instead.
abstract class SyncServiceDescriptor<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  /// Base constructor for concrete sync descriptors.
  const SyncServiceDescriptor();

  /// Factory that produces the service instance.
  ///
  /// Invoked exactly once per [registerWith] call. A throw propagates
  /// to the registry's `_performRegister` catch, which marks the
  /// registration failed and wraps the error in `ServiceStartupFailed`.
  /// Must be synchronous — returning a `Future` defeats the "eager"
  /// contract of this descriptor type.
  SRV Function() get builder;

  /// Builds the instance, registers it with [locator] as a sync
  /// singleton, and fires [LocatorStatus.ready] — all before returning.
  /// A throw from [builder] propagates uncaught so the registry can
  /// apply its canonical failure handling.
  @override
  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  }) {
    final instance = builder();
    locator.registerServiceSync<SRV>(name: name, instance: instance);
    serviceState(LocatorStatus.ready, instance: instance);
  }
}

/// Descriptor for services whose builder returns a [Future] and runs
/// only when the service is first requested.
///
/// Use this mode for anything that performs I/O during startup —
/// database connections, remote config fetches, hardware probing,
/// platform channel initialization. The registry hands the builder to
/// the locator during [registerWith]; the builder does not run until a
/// caller invokes `getServiceAsync` for the first time, at which point
/// the locator drives the lifecycle:
///
///  * [LocatorStatus.starting] — handoff done, builder not yet fired.
///  * [LocatorStatus.ready] — builder resolved; instance cached for
///    every subsequent caller, including `getServiceSync`.
///  * [LocatorStatus.failed] — builder threw; every subsequent resolve
///    rethrows the canonical `ServiceStartupFailed`.
///
/// Timeouts are enforced at `getServiceAsync` against [timeout]; a
/// builder that fails to complete within that window surfaces as
/// `ServiceItemTimeout`.
abstract class LazyAsyncServiceDescriptor<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  /// Base constructor for concrete lazy-async descriptors.
  const LazyAsyncServiceDescriptor();

  /// Factory that produces the service instance asynchronously.
  ///
  /// Invoked at most once across the life of a registration — on the
  /// first `getServiceAsync` call, or never if no caller requests the
  /// service. The returned [Future] is shared across all subsequent
  /// callers; successful completion caches the instance for sync
  /// retrieval, a throw marks the registration terminally
  /// [LocatorStatus.failed].
  Future<SRV> Function() get builder;

  /// Hands [builder] to the locator's lazy-async registration API and
  /// returns immediately.
  ///
  /// Unlike [SyncServiceDescriptor.registerWith], this method does NOT
  /// emit [LocatorStatus.ready] — the locator drives the registration
  /// from `starting` to its terminal state once the builder actually
  /// runs. The locator invokes [serviceState] with `starting` during
  /// this method and with `ready`/`failed` later.
  @override
  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  }) {
    locator.registerServiceLazyAsync<SRV>(
      name: name,
      builder: builder,
      serviceState: serviceState,
    );
  }
}
