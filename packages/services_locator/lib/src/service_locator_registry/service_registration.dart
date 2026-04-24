// packages/services_locator/lib/src/service_locator_registry/service_registration.dart
//
// Tracks the lifecycle state of a single staged service within the
// [ServiceLocatorRegistry]. Transitions are one-way through the state
// machine: staged → starting → (ready | failed).
//
// ignore_for_file: public_member_api_docs

import 'package:services_locator/src/errors.dart' show ServiceStartupFailed;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, ServiceDescriptor;

class ServiceRegistration<SRV extends ServiceClass> {
  ServiceRegistration(this.descriptor);

  final ServiceDescriptor<SRV> descriptor;

  LocatorStatus _status = LocatorStatus.staged;
  LocatorStatus get status => _status;

  SRV? _instance;
  SRV? get instance => _instance;

  Object? _error;
  Object? get error => _error;

  StackTrace? _stackTrace;
  StackTrace? get stackTrace => _stackTrace;

  String get name => descriptor.name;

  Future<void>? _pendingStart;
  Future<void>? get pendingStart => _pendingStart;

  bool get isReady => _status == LocatorStatus.ready;
  bool get isStarting => _status == LocatorStatus.starting;
  bool get isFailed => _status == LocatorStatus.failed;
  bool get isStaged => _status == LocatorStatus.staged;

  /// Called by the registry when it begins registering this service.
  /// The [pending] future lets concurrent callers await completion.
  void markStarting(Future<void> pending) {
    _status = LocatorStatus.starting;
    _pendingStart = pending;
  }

  /// Called when the locator reports that it has started work, independent
  /// of the registry's pending future. Does not set [pendingStart] because
  /// no registry-side orchestration is waiting.
  void markStartingReported() {
    _status = LocatorStatus.starting;
  }

  void markReady(SRV instance) {
    _instance = instance;
    _status = LocatorStatus.ready;
    _error = null;
    _stackTrace = null;
  }

  void markFailed(Object error, StackTrace stackTrace) {
    _error = error;
    _stackTrace = stackTrace;
    _status = LocatorStatus.failed;
  }

  /// Builds a [ServiceStartupFailed] exception from this registration's
  /// recorded error state. Must only be called when [isFailed] is `true` —
  /// enforced by assertion in debug builds.
  ///
  /// Centralizing this construction removes the need for callers to reach
  /// into nullable [error] and [stackTrace] fields with `!` operators.
  ServiceStartupFailed asStartupFailed() {
    assert(
      isFailed,
      'asStartupFailed called on "$name" with status $_status; '
      'only valid when status is failed.',
    );
    return ServiceStartupFailed(
      name,
      cause: _error!,
      causeStackTrace: _stackTrace!,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('${descriptor.name} [${_status.name}]');
    if (_instance != null) buffer.write(' ✓');
    if (_error != null) buffer.write(' ✗ $_error');
    return buffer.toString();
  }
}
