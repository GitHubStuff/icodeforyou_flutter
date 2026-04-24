// packages/services_locator/lib/src/service_locator_registry/service_locator_registry_interfaces.dart
//
// The write-side ([ServiceRegistrar]) and read-side ([ServiceResolver])
// interfaces that [ServiceLocatorRegistry] implements. Split out so
// composition-root code and downstream consumers can depend on whichever
// narrow interface fits their role without pulling in the full concrete
// registry class.

import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:service_locator/src/errors.dart'
    show
        BlankServiceName,
        CircularDependency,
        DuplicateServiceEntry,
        DuplicateServiceType,
        ServiceNotReady,
        ServiceStartupFailed;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceDescriptor;

// ───────────────────────────────────────────────────────────────────
// Public interfaces (ISP)
// ───────────────────────────────────────────────────────────────────
//
// Two narrow interfaces carve the registry into its write-side and
// read-side responsibilities. Composition-root code holds a
// [ServiceRegistrar] (or the concrete `ServiceLocatorRegistry`) to
// stage and register services. Downstream code (widgets, services,
// anything that only needs to resolve dependencies) holds a
// [ServiceResolver] and cannot accidentally stage new services.

/// Write-side view of the registry: declaring services and kicking off
/// their registration with the underlying locator.
///
/// Held by composition-root code that owns service configuration —
/// typically an app bootstrapper or a top-level `main`. Downstream
/// callers that only resolve services should hold [ServiceResolver]
/// instead, which makes it a compile-time error to stage or register
/// new entries from consumer code.
abstract interface class ServiceRegistrar {
  /// Stages [descriptor] for later registration.
  ///
  /// Staging is the first step of the registration lifecycle: the
  /// descriptor is stored in the registry's `Name → Registration` and
  /// `Type → Name` indices, but no builder runs and no locator is
  /// touched. Call [register] afterwards to transition the registration
  /// from `staged` to `ready` (or `failed`).
  ///
  /// Throws [BlankServiceName] if the descriptor's name is empty or
  /// whitespace-only. Throws [DuplicateServiceEntry] if the name is
  /// already staged. Throws [DuplicateServiceType] if the same service
  /// type is already staged under a different name. Throws
  /// `InvalidServiceType` if the descriptor's type parameter resolves
  /// to [ServiceClass] itself rather than a concrete subtype.
  void stage<SRV extends ServiceClass>(ServiceDescriptor<SRV> descriptor);

  /// Returns whether a descriptor with [name] has been staged.
  ///
  /// Useful for idempotent staging during hot-reload or test setup,
  /// where the alternative is exception-driven control flow over
  /// [DuplicateServiceEntry].
  bool isStaged(String name);

  /// Registers a staged service (and its dependencies) with the locator.
  ///
  /// For sync services, transitions the registration straight to
  /// [LocatorStatus.ready]. For lazy-async services, hands the builder
  /// to the locator and leaves the registration at
  /// [LocatorStatus.starting] — the builder fires on the first
  /// [ServiceResolver.getAsync] call.
  ///
  /// Idempotent for ready / starting registrations. Terminally failed
  /// registrations rethrow the canonical [ServiceStartupFailed] on
  /// every subsequent call. Throws [CircularDependency] if the
  /// dependency graph reachable from the staged set contains a cycle.
  Future<void> register(String name);
}

/// Read-side view of the registry: retrieving registered service
/// instances.
///
/// Held by widgets, services, and any downstream consumer that needs
/// to resolve dependencies without the authority to stage or register
/// new ones. The ISP split prevents accidental mutation of the registry
/// from deep inside the object graph.
abstract interface class ServiceResolver {
  /// Resolves a registered service asynchronously.
  ///
  /// For `staged` registrations this triggers registration before
  /// resolving (so callers can "pull" a service into existence without
  /// an explicit prior `register(name)` call). For lazy-async services
  /// the call waits for the builder to complete within the descriptor's
  /// timeout. Throws the same errors as [ServiceRegistrar.register]
  /// plus `ServiceItemTimeout` if a lazy-async builder doesn't settle
  /// in time.
  Future<SRV> getAsync<SRV extends ServiceClass>(String name);

  /// Resolves a registered service synchronously.
  ///
  /// Only returns successfully when the registration is already
  /// [LocatorStatus.ready]. Throws [ServiceNotReady] for `staged` or
  /// `starting` registrations — callers needing to wait should use
  /// [getAsync] instead. Throws [ServiceStartupFailed] for terminally
  /// failed registrations.
  SRV getSync<SRV extends ServiceClass>(String name);
}
