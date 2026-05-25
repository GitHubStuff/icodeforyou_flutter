// packages/services_locator/lib/src/service_locator_registry/service_locator_registry.dart
//
// Registry of staged [ServiceDescriptor]s keyed by name, orchestrating
// their registration with an underlying [ServiceLocator]. Enforces
// dependency order, single-start semantics, and terminal-failure
// propagation. Write-side ([ServiceRegistrar]) and read-side
// ([ServiceResolver]) interfaces live in
// `service_locator_registry_interfaces.dart`; the locator-state-change
// dispatch (`_LocatorStateChangeHandling` mixin) lives in the part file
// `service_locator_registry_state_change.dart`.

// ignore_for_file: avoid_types_on_closure_parameters

import 'dart:async' show Completer;

import 'package:extensions/extensions.dart' show IterableExt;
import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:service_locator/src/errors.dart'
    show
        BlankServiceName,
        CircularDependency,
        DuplicateServiceEntry,
        DuplicateServiceType,
        InvalidServiceType,
        ServiceNotReady,
        ServiceNotRegistered,
        ServiceStartupFailed,
        ServiceTypeMismatch;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceDescriptor;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ServiceLocator;
import 'package:service_locator/src/service_registry/service_registration.dart'
    show ServiceRegistration;
import 'package:service_locator/src/service_registry/service_registry_interfaces.dart'
    show ServiceRegistryInterface, ServiceResolver;

part 'service_registry_state_change.dart';

// ───────────────────────────────────────────────────────────────────
// Concrete implementation
// ───────────────────────────────────────────────────────────────────

/// Concrete registry implementing both [ServiceRegistryInterface] and
/// [ServiceResolver].
///
/// Composition-root code constructs one with a backend [ServiceLocator]
/// (usually `GetItServiceLocator`) and hands narrower views — a
/// [ServiceRegistryInterface] for bootstrap code, a [ServiceResolver] for
/// widgets — to downstream consumers.
///
/// Owns two indices: a `Name → Registration` map (`_registrations`)
/// carrying runtime state per service, and a `Type → Name` map
/// (`_typeToName`) that lets dependency declarations reference siblings
/// by type. Both are populated by [stage] and consulted by [register]
/// / [getAsync] / [getSync].
class ServiceLocatorRegistry
    with _LocatorStateChangeHandling
    implements ServiceRegistryInterface, ServiceResolver {
  /// Creates a registry backed by [locator]. Pass `GetItServiceLocator()`
  /// for production wiring, `MockServiceLocator()` in tests. The locator
  /// is not touched until [register] transitions a staged descriptor.
  ServiceLocatorRegistry({required ServiceLocator locator})
    : _locator = locator;

  final ServiceLocator _locator;
  final Map<String, ServiceRegistration<ServiceClass>> _registrations = {};
  final Map<Type, String> _typeToName = {};

  // ───────────────────────────────────────────────────────────────────
  // Staging
  // ───────────────────────────────────────────────────────────────────

  @override
  void stage<SRV extends ServiceClass>(ServiceDescriptor<SRV> descriptor) {
    final name = descriptor.name;
    if (name.trim().isEmpty) throw BlankServiceName();
    if (_registrations.containsKey(name)) throw DuplicateServiceEntry(name);

    // Read the service type from the descriptor itself rather than the
    // call-site generic [SRV]. When this method is invoked through a
    // widened reference (e.g. iterating a `List<ServiceDescriptor>`),
    // [SRV] erases to [ServiceClass] and every descriptor would collide
    // under the same map key. [ServiceDescriptor.serviceType] captures
    // the type at the concrete subclass level, which survives erasure.
    final type = descriptor.serviceType;

    // A descriptor whose type parameter is [ServiceClass] itself (rather
    // than a concrete subtype) cannot participate in the `Type → name`
    // index meaningfully: every service subclasses [ServiceClass], so
    // using it as a key would either collide with subsequent descriptors
    // or mask genuine subtype descriptors behind a too-general mapping.
    // Reject at stage time where the programmer error is immediate.
    if (type == ServiceClass) throw InvalidServiceType(name);

    final existingName = _typeToName[type];
    if (existingName != null) {
      throw DuplicateServiceType(
        type: type,
        existingName: existingName,
        attemptedName: name,
      );
    }

    _registrations[name] = descriptor.toRegistration();
    _typeToName[type] = name;
  }

  @override
  bool isStaged(String name) => _registrations.containsKey(name);

  /// Returns the concrete [ServiceRegistration] for [name], narrowed to
  /// [SRV].
  ///
  /// Exposed on the concrete class (not on [ServiceRegistryInterface] or
  /// [ServiceResolver]) because it's primarily used by tests and
  /// diagnostics — production code resolves instances through
  /// [getAsync] / [getSync], not registrations. Throws
  /// [ServiceNotRegistered] if [name] is unknown and
  /// [ServiceTypeMismatch] if the staged descriptor's generic type
  /// doesn't match [SRV].
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
  /// transitioning to [LocatorStatus.ready]. For lazy-async services:
  /// registers the builder with the locator; status stays at
  /// [LocatorStatus.starting] until the first `get()` call triggers
  /// construction.
  ///
  /// Idempotent for ready / starting registrations. Terminally failed
  /// registrations rethrow their original error on every subsequent
  /// call.
  ///
  /// Throws [CircularDependency] if the dependency graph contains a
  /// cycle reachable from the staged set. The check runs once per
  /// public `register` call against the current snapshot of staged
  /// descriptors, before any registration work begins.
  ///
  /// Concurrent callers racing on the same [name] are serialized by an
  /// atomic synchronous claim: the first caller transitions the
  /// registration from `staged` to `starting` in the same microtask;
  /// subsequent callers find the registration non-staged and route
  /// through [_awaitNonStaged].
  ///
  /// Method is `async` so synchronous throws from [_lookupOrThrow] and
  /// [_checkForCycles] surface through the returned `Future` rather
  /// than at the call site. Callers see a uniform contract: all errors
  /// — synchronous or otherwise — arrive via the Future.
  @override
  Future<void> register(String name) async {
    // Fail fast on unknown names before the cycle check: callers get a
    // clean [ServiceNotRegistered] regardless of graph health, and the
    // check itself doesn't have to walk from a phantom root.
    _lookupOrThrow(name);

    // Validate the dependency graph. Cycles are a structural property
    // of the staged descriptors — runtime status and caller identity
    // don't factor in — so detection is decoupled from the async walk.
    _checkForCycles();

    // Graph is known-acyclic from here on. Delegate to the internal
    // worker, which skips further cycle detection during recursion.
    return _register(name);
  }

  /// Internal registration worker. Precondition: the dependency graph
  /// rooted at [name] has already been validated as acyclic by the
  /// public [register] entry point, so no cycle detection is needed
  /// here or in [_registerDependencies]'s recursion.
  Future<void> _register(String name) async {
    final registration = _lookupOrThrow(name);

    // Non-staged registrations route to [_awaitNonStaged].
    if (!registration.isStaged) {
      return _awaitNonStaged(registration);
    }

    // Synchronous claim: the status check and [markStarting] inside
    // [_registerStaged] run in the same microtask with no intervening
    // await, so a concurrent caller cannot slip in between them.
    await _registerStaged(registration);
  }

  /// Runs a pre-registration graph check over every currently-staged
  /// descriptor. Uses the generic `checkForCycles` DFS helper from the
  /// `extensions` package and adapts its diagnostic `StateError` to
  /// [CircularDependency] so callers see a typed failure.
  ///
  /// Checks the full graph rather than only the subgraph reachable from
  /// a specific root: an unrelated cycle elsewhere in the staged set is
  /// still a configuration bug and is better surfaced at the first
  /// `register` call than left to lurk until someone happens to walk
  /// through it.
  ///
  /// Two failure modes from the helper get different treatment:
  /// cycles become [CircularDependency] with the chain parsed from the
  /// helper's message; unknown dependencies (thrown by [_nameForType]
  /// from inside `dependenciesOf`) pass through as
  /// [ServiceNotRegistered] unchanged. The message-shape dependency on
  /// the helper is a deliberate trade-off — widening the helper's
  /// error surface with a locator-specific typed exception would
  /// couple a shared utility to this package.
  void _checkForCycles() {
    try {
      _registrations.values.checkForCycles(
        idOf: (registration) => registration.name,
        dependenciesOf: (registration) =>
            registration.descriptor.dependencies.map(_nameForType),
      );
      //
      // ignore: avoid_catching_errors
    } on ServiceNotRegistered {
      // Pass through unchanged — [_nameForType] produced this from inside
      // `dependenciesOf` for an undeclared dep type.
      rethrow;
      //
      // ignore: avoid_catching_errors
    } on StateError catch (error) {
      const prefix = 'Circular dependency detected: ';
      if (!error.message.startsWith(prefix)) rethrow;
      final chain = error.message
          .substring(prefix.length)
          .split(' -> ')
          .map((s) => s.trim())
          .toList();
      throw CircularDependency(chain);
    }
  }

  /// Awaits settlement of a registration that is already past the
  /// [LocatorStatus.staged] state: ready, in-flight via another caller,
  /// or terminally failed.
  ///
  /// Split from [register] so the in-flight path is free of async gaps
  /// — see [register]'s own docs for why that matters.
  ///
  /// For the `starting` branch the status is re-examined after the
  /// `pendingStart` await. [ServiceRegistration.pendingStart] resolves
  /// when the locator handoff finishes, which for lazy-async descriptors
  /// happens before the builder has actually run. By the time control
  /// returns here the builder may have fired and failed — and without
  /// the post-await re-check, concurrent callers of `register()` would
  /// silently return while the original caller's path would see a
  /// thrown `ServiceStartupFailed`. Re-checking keeps the two paths'
  /// observable outcomes aligned.
  Future<void> _awaitNonStaged(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    switch (registration.status) {
      case LocatorStatus.ready:
        return;
      case LocatorStatus.starting:
        await registration.pendingStart;
        switch (registration.status) {
          case LocatorStatus.ready:
            return;
          case LocatorStatus.failed:
            throw registration.asStartupFailed();
          case LocatorStatus.starting:
            // pendingStart resolved but status unchanged: legitimate for
            // lazy-async services whose handoff completed without firing
            // the builder. Registration is live; return.
            return;
          // coverage:ignore-start
          case LocatorStatus.staged:
            // Unreachable: cycle detection at [register]'s entry point
            // prevents any rollback-to-staged transition. Retained for
            // Dart 3 pattern-switch exhaustiveness; excluded from coverage
            // because no code path produces a staged → starting → staged
            // transition post-refactor.
            throw StateError(
              'Registration "${registration.name}" reverted to staged '
              'while awaited — no code path produces this transition.',
            );
          // coverage:ignore-end
        }
      case LocatorStatus.failed:
        throw registration.asStartupFailed();
      // coverage:ignore-start
      case LocatorStatus.staged:
        // Unreachable: [register] only delegates here when status is
        // non-staged. Retained for Dart 3 pattern-switch exhaustiveness;
        // excluded from coverage because the sole caller guards against
        // entering this method with a staged registration.
        throw StateError(
          '_awaitNonStaged called on registration "${registration.name}"',
        );
      // coverage:ignore-end
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

  /// Runs dependency resolution, then hands the descriptor to the
  /// locator with a lifecycle callback wired through
  /// [_onLocatorStateChange]. Any throw from dep resolution or the
  /// locator handoff is caught, marked on the registration via
  /// [ServiceRegistration.markFailed], and rethrown as the canonical
  /// [ServiceStartupFailed] wrapper so every observer sees the same
  /// exception object.
  Future<void> _performRegister(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    try {
      await _registerDependencies(registration);
      await registration.descriptor.registerWith(
        _locator,
        // Types on the closure parameters improve clarity at a call site
        // where four optional named parameters make positional lambdas
        // harder to read.
        serviceState:
            (
              LocatorStatus state, {
              ServiceClass? instance,
              Object? error,
              StackTrace? stackTrace,
            }) => _onLocatorStateChange(
              registration,
              state,
              instance: instance,
              error: error,
              stackTrace: stackTrace,
            ),
      );
    // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      registration.markFailed(error, stackTrace);
      // Throw the canonical wrapper stored by [markFailed]. This way the
      // original thrower here, concurrent `_awaitNonStaged` awaiters, and
      // every later `getAsync`/`getSync`/`register` query that goes
      // through [registration.asStartupFailed] all receive the same
      // exception object — not semantically-identical duplicates.
      throw registration.asStartupFailed();
    }
  }

  /// Walks [registration]'s declared dependency types, resolving each
  /// to its registered name via [_nameForType] and recursively
  /// [_register]-ing it. Runs serially — a dep's registration must be
  /// in flight (or settled) before the next dep is examined.
  Future<void> _registerDependencies(
    ServiceRegistration<ServiceClass> registration,
  ) async {
    for (final depType in registration.descriptor.dependencies) {
      await _register(_nameForType(depType));
    }
  }

  // ───────────────────────────────────────────────────────────────────
  // Locator state-change callback
  // ───────────────────────────────────────────────────────────────────
  //
  // [_onLocatorStateChange] and its `_markXOrThrow` helpers live in the
  // `service_locator_registry_state_change.dart` part file.

  // ───────────────────────────────────────────────────────────────────
  // Retrieval
  // ───────────────────────────────────────────────────────────────────

  @override
  Future<SRV> getAsync<SRV extends ServiceClass>(String name) async {
    ServiceClass.checkGeneric<SRV>(name);

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
  ///
  /// The registration is transitioned to [LocatorStatus.ready] by the
  /// locator's own `ReportServiceState` callback (wired through
  /// [_onLocatorStateChange]); this method does not mark-ready a second
  /// time to avoid duplicate state transitions.
  ///
  /// Re-checks for terminal failure after the `pendingStart` await. A
  /// lazy-async builder that failed between handoff and this call would
  /// otherwise let `_locator.getServiceAsync` re-surface the underlying
  /// builder error instead of the registry's canonical
  /// [ServiceStartupFailed]. The window is narrow but deterministic
  /// under the right microtask ordering — see the registry test
  /// `concurrent register observes failure flipped between handoff
  /// and resume` for the exact scenario.
  Future<SRV> _resolveStartingAsync<SRV extends ServiceClass>(
    ServiceRegistration<SRV> registration,
  ) async {
    await registration.pendingStart;
    if (registration.isFailed) throw registration.asStartupFailed();
    return _locator.getServiceAsync<SRV>(
      name: registration.name,
      timeout: registration.descriptor.timeout,
    );
  }

  @override
  SRV getSync<SRV extends ServiceClass>(String name) {
    ServiceClass.checkGeneric<SRV>(name);
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

  /// Looks up a registration by name, throwing [ServiceNotRegistered]
  /// when missing. Preferred over raw map access so every unknown-name
  /// path surfaces the same typed error.
  ServiceRegistration<ServiceClass> _lookupOrThrow(String name) {
    final registration = _registrations[name];
    if (registration == null) throw ServiceNotRegistered(name);
    return registration;
  }

  /// Resolves a dependency type to the registered name via the
  /// `Type → Name` index populated at stage time. Throws
  /// [ServiceNotRegistered] (tagged `type:<TypeName>` for diagnosis) if
  /// the type has no staged descriptor.
  String _nameForType(Type type) {
    final name = _typeToName[type];
    if (name == null) throw ServiceNotRegistered('type:$type');
    return name;
  }

  // ───────────────────────────────────────────────────────────────────
  // Debugging
  // ───────────────────────────────────────────────────────────────────

  /// Debug representation listing every registration and its current
  /// status. Intended for log output and inspector panels, not for
  /// parsing.
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
