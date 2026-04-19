// ignore_for_file: public_member_api_docs

class BlankServiceName extends StateError {
  BlankServiceName() : super('An empty string is not a valid Service Name');
}

class DuplicateServiceEntry extends StateError {
  DuplicateServiceEntry(String name) : super('"$name" is already registered ');
}

class InvalidLocatorState extends StateError {
  InvalidLocatorState(String state, {required String onServiceLocator})
    : super('Invalid request "$state" on service "$onServiceLocator"');
}

class ServiceItemTimeout extends StateError {
  ServiceItemTimeout(String name, Duration timeout)
    : super('Time out on Service "$name" after ${timeout.inMilliseconds}ms');
}

class ServiceNotReady extends StateError {
  ServiceNotReady(String name) : super('"$name" is not ready');
}

class ServiceNotRegistered extends StateError {
  ServiceNotRegistered(String name) : super('"$name" is not registered');
}

class ServiceRegistrationError extends StateError {
  ServiceRegistrationError(String name, {required Object cause})
    : super('"$name" registeration error "$cause"');
}

class StartServiceError extends StateError {
  StartServiceError(String name, {required String reason})
    : super('"$name" failed to start: $reason');
}

class UnknownServiceEntry extends StateError {
  UnknownServiceEntry(String name) : super('Unknown Service Entry "$name"');
}

class UnknownStateError extends StateError {
  UnknownStateError(String name, {required String state})
    : super('"$name" in state: $state');
}
