// packages/services_locator/lib/src/service_locator_registry/service_registration.dart
//
// Tracks the lifecycle state of a single staged service within the
// [ServiceLocatorRegistry]. Transitions are one-way through the state
// machine: staged → starting → (ready | failed).
//
// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/errors.dart' show ServiceStartupFailed;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
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

  /// Canonical [ServiceStartupFailed] wrapper for this registration's
  /// failure, constructed once inside [markFailed] at the moment of
  /// failure and returned by every subsequent call to [asStartupFailed].
  ///
  /// Having a single cached instance gives all callers that observe the
  /// failure — the original thrower, any concurrent `_awaitNonStaged`
  /// awaiter, and every later `getAsync`/`getSync`/`register` query —
  /// the same exception object. This preserves object identity across
  /// queries (useful for tests that compare by reference, caching
  /// frameworks, and anyone inspecting `e.cause` at the outer wrapper
  /// level) and avoids redundant construction of semantically-identical
  /// exceptions.
  ServiceStartupFailed? _startupFailed;

  String get name => descriptor.name;

  Future<void>? _pendingStart;

  /// Future that resolves when the registry's handoff of this service
  /// to the underlying [ServiceLocator] completes.
  ///
  /// Important semantics: for **sync** services the handoff drives the
  /// registration all the way to [LocatorStatus.ready] before resolving
  /// this future. For **lazy-async** services the handoff is just the
  /// builder-registration step — the future resolves successfully as
  /// soon as the locator has accepted the builder, even though the
  /// builder itself has not yet run and could later fail when it does.
  ///
  /// Concurrent callers who await this future must therefore re-check
  /// [status] after the await to detect a terminal failure that
  /// materialized after the handoff.
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

  void markReady(SRV instance) {
    _instance = instance;
    _status = LocatorStatus.ready;
    _error = null;
    _stackTrace = null;
    _startupFailed = null;
  }

  void markFailed(Object error, StackTrace stackTrace) {
    _error = error;
    _stackTrace = stackTrace;
    _status = LocatorStatus.failed;
    _startupFailed = ServiceStartupFailed(
      name,
      cause: error,
      causeStackTrace: stackTrace,
    );
  }

  /// Returns this registration's canonical [ServiceStartupFailed] wrapper.
  ///
  /// The wrapper is constructed once inside [markFailed] at the moment of
  /// failure, then cached on the registration. Every call to this method
  /// returns the same object — so callers observing the failure via
  /// different paths (the original thrower, concurrent `register` awaiters,
  /// later `getAsync`/`getSync` queries) see identical exception identity.
  ///
  /// Throws [StateError] if called when [isFailed] is `false`. The check
  /// runs unconditionally — debug and release — so the `!` on
  /// [_startupFailed] cannot be reached in an inconsistent state. An
  /// `assert`-only guard would strip in release and fall through to a
  /// confusing `Null check operator used on a null value` `TypeError`
  /// instead of a diagnostic message.
  ServiceStartupFailed asStartupFailed() {
    if (!isFailed) {
      throw StateError(
        'asStartupFailed called on "$name" with status ${_status.name}; '
        'only valid when status is "${LocatorStatus.failed.name}".',
      );
    }
    return _startupFailed!;
  }

  @override
  String toString() {
    final buffer = StringBuffer('${descriptor.name} [${_status.name}]');
    if (_instance != null) buffer.write(' ✓');
    if (_error != null) buffer.write(' ✗ $_error');
    return buffer.toString();
  }
}
