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
class ServiceItemTimeout extends ServiceError {
  ServiceItemTimeout(String name, Duration timeout)
    : super('Timeout on service "$name" after ${timeout.inMilliseconds}ms');
}

/// Thrown when staging/registering a descriptor fails for a reason other
/// than duplicate or blank name.
class ServiceRegistrationError extends ServiceError {
  ServiceRegistrationError(String name, {required Object cause})
    : super('"$name" registration error: $cause');
}

/// Thrown when a service's builder throws during startup.
class ServiceStartupFailed extends ServiceError {
  ServiceStartupFailed(
    this.serviceName, {
    required this.cause,
    required this.causeStackTrace,
  }) : super('"$serviceName" failed to start: $cause');

  final String serviceName;
  final Object cause;
  final StackTrace causeStackTrace;

  @override
  String toString() =>
      'ServiceStartupFailed: $message\nCaused by:\n$causeStackTrace';
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
