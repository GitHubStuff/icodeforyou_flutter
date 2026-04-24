// packages/services_locator/lib/src/errors.dart
//
// Sealed hierarchy of service-locator errors. Every failure mode the
// registry, locator adapters, or mock surface to callers is modeled as a
// subclass of [ServiceError], itself a subclass of [StateError] — so
// callers can catch at whatever precision they need (specific subtype
// for targeted handling, [ServiceError] for "anything from this package",
// [StateError] for broad defensive code).

/// Base class for all service-locator-related errors.
///
/// Extends [StateError] because every failure mode here represents the
/// service registry being in an unexpected state relative to the
/// caller's request (service absent, already registered, not yet ready,
/// etc.). Sealed so the registry can reason about the full failure
/// surface at compile time and exhaustive switches catch new additions.
sealed class ServiceError extends StateError {
  /// Forwards [message] to [StateError]'s constructor. Concrete
  /// subclasses build a descriptive message including whatever
  /// identifying context the error carries.
  ServiceError(super.message);
}

/// Thrown when a service name is blank or whitespace-only.
///
/// Names are the primary registration key; an empty name would cause
/// every lookup to collide. Rejected at `ServiceLocatorRegistry.stage`
/// before the name reaches the internal indices.
class BlankServiceName extends ServiceError {
  /// Builds the error with a fixed diagnostic message — there is no
  /// per-instance context to preserve (the offending name is, by
  /// definition, empty).
  BlankServiceName() : super('An empty string is not a valid service name');
}

/// Thrown when attempting to register a service whose name is already taken.
///
/// Raised either by `ServiceLocatorRegistry.stage` when a second
/// descriptor claims the same name, or by `ServiceLocator`
/// implementations when the underlying backend already has a
/// registration for the `(SRV, name)` pair.
class DuplicateServiceEntry extends ServiceError {
  /// Builds the error tagging the offending [name] in the message for
  /// diagnosis.
  DuplicateServiceEntry(String name) : super('"$name" is already registered');
}

/// Thrown when attempting to stage a second descriptor for the same service
/// type.
///
/// The registry maintains a `Type → name` index so that descriptors can
/// declare dependencies by type (via `ServiceDescriptor.dependencies`).
/// Staging two services of the same type would make that lookup
/// ambiguous, so it is rejected at stage time.
class DuplicateServiceType extends ServiceError {
  /// Builds the error identifying the colliding [type], the name it was
  /// first staged as ([existingName]), and the name the caller just
  /// tried to stage it under again ([attemptedName]).
  DuplicateServiceType({
    required Type type,
    required String existingName,
    required String attemptedName,
  }) : super(
         'Service type "$type" is already staged as "$existingName"; '
         'cannot stage it again as "$attemptedName"',
       );
}

/// Thrown when a service is requested by a name that has never been staged.
///
/// Fires from `getServiceSync`, `getServiceAsync`, `register`,
/// `getAsync`, `getSync`, and from `_nameForType` when a declared
/// dependency type has no matching staged descriptor.
class ServiceNotRegistered extends ServiceError {
  /// Builds the error tagging the missing [name]. Note: when the source
  /// is a type-to-name resolution failure, the registry passes a
  /// `type:<TypeName>` string as [name] to aid diagnosis.
  ServiceNotRegistered(String name) : super('"$name" is not registered');
}

/// Thrown when a requested name exists but doesn't resolve to a known entry.
///
/// Distinct from [ServiceNotRegistered]: that one means the name was
/// never staged at all; this one means the registry has an entry it
/// can't interpret (e.g. a storage mismatch between `_registrations`
/// and `_typeToName`). Should be unreachable in practice; retained as
/// a diagnostic for corrupted registry state.
class UnknownServiceEntry extends ServiceError {
  /// Builds the error tagging the opaque [name] whose entry couldn't
  /// be interpreted.
  UnknownServiceEntry(String name) : super('Unknown service entry "$name"');
}

/// Thrown when a registration is retrieved with the wrong generic type.
///
/// Example: `registrationFor<FooService>('bar')` when `'bar'` was
/// staged as `ServiceDescriptor<BarService>`. Most commonly caught in
/// tests that mis-type their `registrationFor` calls; production code
/// rarely hits this because services are retrieved by their contract
/// interface.
class ServiceTypeMismatch extends ServiceError {
  /// Builds the error identifying the service [name] and the
  /// expected-vs-actual types.
  ServiceTypeMismatch(
    String name, {
    required Type expected,
    required Type actual,
  }) : super(
         'Type mismatch on "$name": expected "$expected", actual "$actual"',
       );
}

/// Thrown when a service is requested but its registration isn't in a
/// ready state (i.e. status is still `staged`, `starting`, etc.).
///
/// Fires from `getServiceSync` on both the [ServiceLocator] adapters
/// and on `ServiceLocatorRegistry.getSync` — any code path that
/// requires an immediately-available instance. Callers needing to wait
/// for readiness should use the async variant instead.
class ServiceNotReady extends ServiceError {
  /// Builds the error tagging the service [name] and the [status] that
  /// the registration was in when the sync access was attempted.
  ServiceNotReady(String name, {required String status})
    : super('"$name" is not ready (status: $status)');
}

/// Thrown when a service's resolve exceeds its configured timeout.
///
/// [notReadyYet] and [waitedBy] carry diagnostic detail when the
/// underlying locator can provide it (e.g. the GetIt adapter surfaces
/// `WaitingTimeOutException`'s `notReadyYet` and `areWaitedBy` maps
/// here). Both default to empty collections so the fields are always
/// safe to read.
class ServiceItemTimeout extends ServiceError {
  /// Builds the error with the offending [name] and [timeout] duration.
  /// Optional [notReadyYet] / [waitedBy] carry diagnostic payload when
  /// available; both default to empty and are formatted into the
  /// message only when populated.
  ServiceItemTimeout(
    String name,
    Duration timeout, {
    this.notReadyYet = const <String>[],
    this.waitedBy = const <String, List<String>>{},
  }) : super(_buildMessage(name, timeout, notReadyYet, waitedBy));

  /// Types or named instances that had not reached ready state when the
  /// timeout fired.
  final List<String> notReadyYet;

  /// Reverse-dependency map: for each still-not-ready entry, the callees
  /// that were waiting on it. Empty when the underlying locator doesn't
  /// expose that information.
  final Map<String, List<String>> waitedBy;

  /// Composes the timeout message. Emits the bare `Timeout on service
  /// "$name" after <ms>ms` header when no diagnostic data is available,
  /// and appends `; not ready: ...` and/or `; waited by: ...` segments
  /// when the corresponding collections are populated.
  static String _buildMessage(
    String name,
    Duration timeout,
    List<String> notReadyYet,
    Map<String, List<String>> waitedBy,
  ) {
    final base = 'Timeout on service "$name" after ${timeout.inMilliseconds}ms';
    if (notReadyYet.isEmpty && waitedBy.isEmpty) return base;
    final buffer = StringBuffer(base);
    if (notReadyYet.isNotEmpty) {
      buffer.write('; not ready: ${notReadyYet.join(", ")}');
    }
    if (waitedBy.isNotEmpty) {
      buffer.write('; waited by: $waitedBy');
    }
    return buffer.toString();
  }
}

/// Thrown when staging/registering a descriptor fails for a reason
/// other than duplicate or blank name.
///
/// General-purpose wrapper for registry-level failures that don't fit
/// one of the more specific sibling errors. Carries a [cause] so the
/// originating exception type is not lost.
class ServiceRegistrationError extends ServiceError {
  /// Builds the error tagging the service [name] and wrapping [cause]
  /// (via `toString`) into the message for diagnosis.
  ServiceRegistrationError(String name, {required Object cause})
    : super('"$name" registration error: $cause');
}

/// Thrown when a service's builder throws during startup.
///
/// The canonical wrapper for any builder-failure propagation: the
/// registry constructs one at `markFailed` time and caches it so every
/// observer of the failure (the original thrower, concurrent awaiters,
/// later `getAsync`/`getSync`/`register` queries) receives the same
/// exception object.
///
/// [toString] follows the Throwable-style "Caused by" convention so
/// nested failures (e.g. a dependency's startup failure wrapped by its
/// dependent's) render as a readable cause chain rather than a
/// flattened single line.
class ServiceStartupFailed extends ServiceError {
  /// Builds the error for [serviceName] with the originating [cause]
  /// and the [causeStackTrace] captured at the point the builder
  /// failed. The message is the bare `"<name>" failed to start`; the
  /// cause is rendered by [toString] on a separate `Caused by:` line.
  ServiceStartupFailed(
    this.serviceName, {
    required this.cause,
    required this.causeStackTrace,
  }) : super('"$serviceName" failed to start');

  /// The name of the service whose builder failed. Preserved as a
  /// first-class field so log sinks can index by service without
  /// parsing the message string.
  final String serviceName;

  /// The originating exception. Preserved by reference so callers can
  /// downcast to a known cause type (database error, network error,
  /// etc.) and react accordingly.
  final Object cause;

  /// Stack trace captured at the point of the original throw, passed
  /// through unchanged so crash reporters see the real failure site
  /// rather than the registry's wrapping site.
  final StackTrace causeStackTrace;

  /// Renders a Throwable-style cause chain:
  ///
  /// ```
  /// ServiceStartupFailed: "foo" failed to start
  /// Caused by: <cause's own toString()>
  /// <causeStackTrace>
  /// ```
  ///
  /// When [cause] is itself a [ServiceStartupFailed], its `toString()`
  /// already includes its own `Caused by` line and stack trace, so
  /// this layout produces a natural cause chain for nested failures —
  /// each level's stack trace accumulates innermost-first, matching
  /// Java's Throwable convention.
  ///
  /// Uses [runtimeType] rather than a literal class name so a future
  /// subclass renders with its own name without overriding this
  /// method.
  @override
  String toString() {
    return '$runtimeType: $message\n'
        'Caused by: $cause\n'
        '$causeStackTrace';
  }
}

/// Thrown when an illegal status transition is attempted on a
/// registration.
///
/// Example: transitioning from `ready` back to `waiting`, or from
/// `failed` to `ready` without passing through a reset. Raised by
/// `ServiceRegistration`'s state-machine guards — currently not
/// emitted, but defined for future enforcement of transition
/// invariants.
class InvalidStatusTransition extends ServiceError {
  /// Builds the error tagging the service [name] and the attempted
  /// [from] → [to] transition.
  InvalidStatusTransition(
    String name, {
    required String from,
    required String to,
  }) : super('"$name" cannot transition from "$from" to "$to"');
}

/// Thrown when a registration is found in a status value that the locator
/// doesn't know how to handle (i.e. enum value added but switch not
/// updated).
///
/// Acts as a compile-time safety net: when `LocatorStatus` grows a new
/// variant and a switch somewhere is missed, this error makes the gap
/// visible at runtime with a diagnostic message rather than falling
/// through silently.
class UnknownServiceStatus extends ServiceError {
  /// Builds the error tagging the service [name] and the unhandled
  /// [status] value.
  UnknownServiceStatus(String name, {required String status})
    : super('"$name" is in unhandled status: "$status"');
}

/// Thrown when resolving a service's dependency graph encounters a cycle.
///
/// The registry runs a stage-time DFS check at the entry of every
/// `register` call via `_checkForCycles`; a cycle (e.g. A → B → A)
/// would otherwise cause the involved registrations to indefinitely
/// await each other's `pendingStart`. Detected before any registration
/// work begins so participants stay at `staged` and can be retried
/// after the configuration is fixed.
///
/// [chain] is the ordered list of service names forming the cycle,
/// with the repeated name appended at the end to make the loop visually
/// explicit: `['a', 'b', 'a']` reads as "a depends on b which depends
/// on a".
class CircularDependency extends ServiceError {
  /// Builds the error with the offending [chain], rendering it into
  /// the message as `a → b → a` for immediate human readability.
  CircularDependency(this.chain)
    : super('Circular dependency detected: ${chain.join(" → ")}');

  /// The walked path through the dependency graph that closed the
  /// cycle. First and last elements are the same name (the repeated
  /// node); intermediate elements are the transit stops. Note: when
  /// the cycle is reached via transitive deps (e.g. A → B → C → B),
  /// this is the full walk path, not the minimal cycle — so A appears
  /// in the chain even though the cycle proper is B ↔ C.
  final List<String> chain;
}

/// Thrown when a descriptor's `serviceType` is not a usable concrete
/// type.
///
/// The registry's `Type → name` index requires a distinct concrete
/// subtype of the marker interface for each service so that
/// `ServiceDescriptor.dependencies` can identify dependencies
/// unambiguously by type. A descriptor whose generic parameter resolves
/// to the marker interface itself (e.g. `class Foo extends
/// SyncServiceDescriptor<ServiceClass>`) cannot be expressed as a
/// dependency target and is rejected at stage time.
class InvalidServiceType extends ServiceError {
  /// Builds the error tagging the service [name] with a message that
  /// explains the requirement (concrete subtype of `ServiceClass`, not
  /// `ServiceClass` itself).
  InvalidServiceType(String name)
    : super(
        '"$name" has an invalid service type: the descriptor\'s type '
        'parameter must be a concrete subtype of ServiceClass, not '
        'ServiceClass itself',
      );
}
