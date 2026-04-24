// packages/services_locator/lib/src/service_locator_registry/service_locator_registry.dart
//
// Registry of staged [ServiceDescriptor]s keyed by name, orchestrating
// their registration with an underlying [ServiceLocator]. Enforces
// dependency order, single-start semantics, and terminal-failure
// propagation.
//
// Design principles applied:
// - SRP: register(), getAsync(), and getSync() each delegate state-
//   specific handling to small, focused helpers.
// - OCP: [ServiceDescriptor]'s sealed hierarchy drives behavior; the
//   registry does not switch on descriptor type.
// - DIP: depends on the [ServiceLocator] abstraction, not any concrete
//   implementation.
// - Tell, Don't Ask: registration state transitions and terminal-error
//   construction live on [ServiceRegistration], not here.
//
// ignore_for_file: public_member_api_docs

import 'dart:async' show Completer;

import 'package:services_locator/src/errors.dart'
    show
        BlankServiceName,
        DuplicateServiceEntry,
        ServiceNotReady,
        ServiceNotRegistered,
        ServiceStartupFailed,
        ServiceTypeMismatch;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, ServiceDescriptor;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ServiceLocator;
import 'package:services_locator/src/service_locator_registry/service_registration.dart'
    show ServiceRegistration;

class ServiceLocatorRegistry {
  ServiceLocatorRegistry({required ServiceLocator locator})
    : _locator = locator;

  final ServiceLocator _locator;
  final Map<String, ServiceRegistration<ServiceClass>> _registrations = {};
  final Map<Type, String> _typeToName = {};

  // ───────────────────────────────────────────────────────────────────
  // Staging
  // ───────────────────────────────────────────────────────────────────

  void stage<SRV extends ServiceClass>(ServiceDescriptor<SRV> descriptor) {
    final name = descriptor.name;
    if (name.trim().isEmpty) throw BlankServiceName();
    if (_registrations.containsKey(name)) throw DuplicateServiceEntry(name);

    _registrations[name] = ServiceRegistration<SRV>(descriptor);
    _typeToName[SRV] = name;
  }

  ServiceRegistration<SRV> registrationFor<SRV extends ServiceClass>(
    String name,
  ) {
    final registration = _registrations[name];
    if (registration == null) throw ServiceNotRegistered(name);
    if (registration is! ServiceRegistration<SRV>) {
      throw ServiceTypeMismatch(
        name,
        expected: SRV,
        actual: registration.runtimeType,
      );
    }
    return registration;
  }

  // ───────────────────────────────────────────────────────────────────
  // Registration orchestration
  // ───────────────────────────────────────────────────────────────────

  /// Registers a staged service (and its dependencies) with the locator.
  ///
  /// For sync services: builds and registers the instance immediately,
  /// transitioning to [LocatorStatus.ready].
  ///
  /// For lazy-async services: registers the builder with the locator.
  /// Status stays at [LocatorStatus.starting] until the first `get()`
  /// call triggers construction.
  ///
  /// Idempotent for ready / starting registrations. Terminally failed
  /// registrations rethrow their original error on every subsequent call.
  Future<void> register(String name) async {
    final registration = _lookupOrThrow(name);

    if (await _handleNonStagedState(registration)) return;

    await _registerStaged(registration);
  }

  /// Handles registrations that are not in the `staged` state.
  ///
  /// Returns `true` if the registration was already handled (ready, or
  /// in-flight via another caller) and no further work is needed. Throws
  /// [ServiceStartupFailed] if the registration has terminally failed.
  /// Returns `false` only when the registration is `staged` and requires
  /// the caller to perform the actual registration.
  Future<bool> _handleNonStagedState(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    switch (registration.status) {
      case LocatorStatus.ready:
        return true;
      case LocatorStatus.starting:
        await registration.pendingStart;
        return true;
      case LocatorStatus.failed:
        throw registration.asStartupFailed();
      case LocatorStatus.staged:
        return false;
    }
  }

  /// Performs the actual registration for a staged service, with proper
  /// lifecycle signaling via a [Completer] so concurrent callers can
  /// await completion through [ServiceRegistration.pendingStart].
  Future<void> _registerStaged(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    final completer = Completer<void>();
    // The completer's future is stored on the registration for concurrent
    // awaiters; in the common single-caller case nobody awaits it, so
    // explicitly silence its error channel to prevent the Dart runtime
    // from reporting an unhandled async error on completer.completeError.
    completer.future.ignore();
    registration.markStarting(completer.future);

    try {
      await _performRegister(registration);
      completer.complete();
    } catch (error) {
      completer.completeError(error);
      rethrow;
    }
  }

  Future<void> _performRegister(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    try {
      await _registerDependencies(registration);
      registration.descriptor.registerWith(
        _locator,
        serviceState: (LocatorStatus state, {Object? instance}) =>
            _onLocatorStateChange(registration, state, instance: instance),
      );
    } catch (error, stackTrace) {
      registration.markFailed(error, stackTrace);
      throw ServiceStartupFailed(
        registration.name,
        cause: error,
        causeStackTrace: stackTrace,
      );
    }
  }

  Future<void> _registerDependencies(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    for (final depType in registration.descriptor.dependencies) {
      await register(_nameForType(depType));
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Locator state-change callback
  // ───────────────────────────────────────────────────────────────────

  void _onLocatorStateChange(
    ServiceRegistration<ServiceClass> registration,
    LocatorStatus state, {
    Object? instance,
  }) {
    switch (state) {
      case LocatorStatus.starting:
        registration.markStartingReported();
      case LocatorStatus.ready:
        _markReadyOrThrow(registration, instance);
      case LocatorStatus.failed:
        registration.markFailed(
          StateError('Locator reported failure for "${registration.name}"'),
          StackTrace.current,
        );
      case LocatorStatus.staged:
        // Locators do not drive services back to `staged`; this arm
        // exists for switch exhaustiveness and is intentionally a no-op.
        break;
    }
  }

  void _markReadyOrThrow(
    ServiceRegistration<ServiceClass> registration,
    Object? instance,
  ) {
    if (instance is! ServiceClass) {
      throw StateError(
        'Locator reported ready for "${registration.name}" '
        'without providing a ServiceClass instance (got: '
        '${instance?.runtimeType ?? 'null'})',
      );
    }
    registration.markReady(instance);
  }

  // ───────────────────────────────────────────────────────────────────
  // Retrieval
  // ───────────────────────────────────────────────────────────────────

  Future<SRV> getAsync<SRV extends ServiceClass>(String name) async {
    final registration = registrationFor<SRV>(name);

    switch (registration.status) {
      case LocatorStatus.ready:
        return _locator.getServiceSync<SRV>(name: name);

      case LocatorStatus.starting:
        return _resolveStartingAsync<SRV>(registration);

      case LocatorStatus.failed:
        throw registration.asStartupFailed();

      case LocatorStatus.staged:
        await register(name);
        return getAsync<SRV>(name);
    }
  }

  /// Awaits the registry-side [ServiceRegistration.pendingStart] (if any)
  /// and then asks the locator to materialize the instance. For lazy-async
  /// services, [ServiceLocator.getServiceAsync] triggers construction and
  /// waits for the builder to complete.
  Future<SRV> _resolveStartingAsync<SRV extends ServiceClass>(
    ServiceRegistration<SRV> registration,
  ) async {
    await registration.pendingStart;
    final instance = await _locator.getServiceAsync<SRV>(
      name: registration.name,
      timeout: registration.descriptor.timeout,
    );
    registration.markReady(instance);
    return instance;
  }

  SRV getSync<SRV extends ServiceClass>(String name) {
    final registration = registrationFor<SRV>(name);

    switch (registration.status) {
      case LocatorStatus.ready:
        return _locator.getServiceSync<SRV>(name: name);

      case LocatorStatus.staged:
      case LocatorStatus.starting:
        throw ServiceNotReady(name, status: registration.status.name);

      case LocatorStatus.failed:
        throw registration.asStartupFailed();
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Private helpers
  // ───────────────────────────────────────────────────────────────────

  ServiceRegistration<ServiceClass> _lookupOrThrow(String name) {
    final registration = _registrations[name];
    if (registration == null) throw ServiceNotRegistered(name);
    return registration;
  }

  String _nameForType(Type type) {
    final name = _typeToName[type];
    if (name == null) throw ServiceNotRegistered('type:$type');
    return name;
  }

  // ───────────────────────────────────────────────────────────────────
  // Debugging
  // ───────────────────────────────────────────────────────────────────

  @override
  String toString() {
    if (_registrations.isEmpty) return 'ServiceLocatorRegistry: <empty>';
    final entries = _registrations.entries
        .map((e) => '  ${e.key} → ${e.value}')
        .join('\n');
    return 'ServiceLocatorRegistry (${_registrations.length} entries):'
        '\n$entries';
  }
}
