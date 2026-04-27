// ignore_for_file: public_member_api_docs

/// Base class for all service-locator-related errors.
///
/// Extends [StateError] because every failure mode here represents the
/// service registry being in an unexpected state relative to the caller's
/// request.
sealed class ServiceError extends StateError {
  ServiceError(super.message);
}

/// Thrown when a service name is blank or whitespace-only.
class BlankServiceName extends ServiceError {
  BlankServiceName() : super('An empty string is not a valid service name');
}

/// Thrown when attempting to register a service whose name is already taken.
class DuplicateServiceEntry extends ServiceError {
  DuplicateServiceEntry(String name) : super('"$name" is already registered');
}

class BadServiceClass extends StateError {
  BadServiceClass(String name)
    : super(
        'Generic type must be a concrete subtype of ServiceClass. '
        'Received: ServiceClass (too generic) for "$name".',
      );
}

/// Thrown when attempting to stage a second descriptor for the same service
/// type.
///
/// The registry maintains a `Type → name` index so that descriptors can
/// declare dependencies by type (via `ServiceDescriptor.dependencies`).
/// Staging two services of the same type would make that lookup ambiguous,
/// so it is rejected at stage time.
class DuplicateServiceType extends ServiceError {
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
class ServiceNotRegistered extends ServiceError {
  ServiceNotRegistered(String name) : super('"$name" is not registered');
}

/// Thrown when a requested name exists but doesn't resolve to a known entry.
///
/// Distinct from [ServiceNotRegistered]: that one means the name was never
/// staged at all; this one means the registry has an entry it can't interpret.
class UnknownServiceEntry extends ServiceError {
  UnknownServiceEntry(String name) : super('Unknown service entry "$name"');
}

/// Thrown when a registration is retrieved with the wrong generic type.
///
/// Example: `registrationFor<FooService>('bar')` when `'bar'` was staged
/// as `ServiceDescriptor<BarService>`.
class ServiceTypeMismatch extends ServiceError {
  ServiceTypeMismatch(
    String name, {
    required Type expected,
    required Type actual,
  }) : super(
         'Type mismatch on "$name": expected "$expected", actual "$actual"',
       );
}

/// Thrown when a service is requested but its registration isn't in a
/// ready state (i.e. status is still `waiting`, `starting`, etc.).
class ServiceNotReady extends ServiceError {
  ServiceNotReady(String name, {required String status})
    : super('"$name" is not ready (status: $status)');
}

/// Thrown when a service's resolve exceeds its configured timeout.
///
/// [notReadyYet] and [waitedBy] carry diagnostic detail when the underlying
/// locator can provide it (e.g. the GetIt adapter surfaces
/// `WaitingTimeOutException`'s `notReadyYet` and `areWaitedBy` maps here).
/// Both default to empty collections so the fields are always safe to read.
class ServiceItemTimeout extends ServiceError {
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

/// Thrown when staging/registering a descriptor fails for a reason other
/// than duplicate or blank name.
class ServiceRegistrationError extends ServiceError {
  ServiceRegistrationError(String name, {required Object cause})
    : super('"$name" registration error: $cause');
}

/// Thrown when a service's builder throws during startup.
///
/// The [cause] is the originating exception, and [causeStackTrace] is the
/// stack trace captured at the point where the builder failed. [toString]
/// follows the Throwable-style "Caused by" convention so nested failures
/// (e.g. a dependency's startup failure wrapped by its dependent's) render
/// as a readable cause chain rather than a flattened single line.
class ServiceStartupFailed extends ServiceError {
  ServiceStartupFailed(
    this.serviceName, {
    required this.cause,
    required this.causeStackTrace,
  }) : super('"$serviceName" failed to start');

  final String serviceName;
  final Object cause;
  final StackTrace causeStackTrace;

  @override
  String toString() {
    // Format:
    //   ServiceStartupFailed: "foo" failed to start
    //   Caused by: <cause's own toString()>
    //   <causeStackTrace>
    //
    // When [cause] is itself a [ServiceStartupFailed], its toString()
    // already includes its own "Caused by" line and stack trace, so this
    // layout produces a natural cause chain for nested failures — each
    // level's stack trace accumulates innermost-first, matching Java's
    // Throwable convention.
    //
    // Uses [runtimeType] rather than a literal class name so a future
    // subclass renders with its own name without overriding this method.
    return '$runtimeType: $message\n'
        'Caused by: $cause\n'
        '$causeStackTrace';
  }
}

/// Thrown when an illegal status transition is attempted on a registration.
///
/// Example: transitioning from `ready` back to `waiting`, or from `failed`
/// to `ready` without passing through a reset.
class InvalidStatusTransition extends ServiceError {
  InvalidStatusTransition(
    String name, {
    required String from,
    required String to,
  }) : super('"$name" cannot transition from "$from" to "$to"');
}

/// Thrown when a registration is found in a status value that the locator
/// doesn't know how to handle (i.e. enum value added but switch not updated).
class UnknownServiceStatus extends ServiceError {
  UnknownServiceStatus(String name, {required String status})
    : super('"$name" is in unhandled status: "$status"');
}

/// Thrown when resolving a service's dependency graph encounters a cycle.
///
/// The registry walks `ServiceDescriptor.dependencies` recursively during
/// [ServiceLocatorRegistry.register]; a cycle (e.g. A → B → A) would cause
/// the two registrations to indefinitely await each other's `pendingStart`.
/// Detected and rejected at registration time rather than at stage time —
/// stage order is independent, and a cycle only matters when edges are
/// actually traversed.
///
/// [chain] is the ordered list of service names forming the cycle, with the
/// repeated name appended at the end to make the loop visually explicit:
/// `['a', 'b', 'a']` reads as "a depends on b which depends on a".
class CircularDependency extends ServiceError {
  CircularDependency(this.chain)
    : super('Circular dependency detected: ${chain.join(" → ")}');

  final List<String> chain;
}

/// Thrown when a descriptor's `serviceType` is not a usable concrete type.
///
/// The registry's `Type → name` index requires a distinct concrete subtype
/// of the marker interface for each service so that
/// `ServiceDescriptor.dependencies` can identify dependencies unambiguously
/// by type. A descriptor whose generic parameter resolves to the marker
/// interface itself (e.g. `class Foo extends SyncServiceDescriptor<ServiceClass>`)
/// cannot be expressed as a dependency target and is rejected at stage time.
class InvalidServiceType extends ServiceError {
  InvalidServiceType(String name)
    : super(
        '"$name" has an invalid service type: the descriptor\'s type '
        'parameter must be a concrete subtype of ServiceClass, not '
        'ServiceClass itself',
      );
}
