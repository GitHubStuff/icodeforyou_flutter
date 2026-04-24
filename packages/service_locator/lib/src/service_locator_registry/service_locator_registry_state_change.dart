// packages/services_locator/lib/src/service_locator_registry/service_locator_registry_state_change.dart
//
// Locator-to-registry state-change dispatch. Split into a `part` file to
// keep the main registry body within the per-file line budget; kept
// `part of` rather than a standalone class because these helpers need
// library-private access to [ServiceRegistration.markReady] /
// [ServiceRegistration.markFailed] and do not form a cohesive unit on
// their own.

part of 'service_locator_registry.dart';

/// Mixin factored out of [ServiceLocatorRegistry] carrying the
/// locator-state-change callback dispatch. Grouped together because
/// [_onLocatorStateChange] is the only public entry point and the two
/// `_markXOrThrow` helpers are only called from it.
mixin _LocatorStateChangeHandling {
  /// Handles the lifecycle callback the locator invokes during
  /// descriptor registration. Translates the locator's status report
  /// into state transitions on [ServiceRegistration].
  ///
  /// The `starting` and `staged` arms are no-ops for different reasons
  /// (see inline comments); the `ready` and `failed` arms delegate to
  /// [_markReadyOrThrow] / [_markFailedOrThrow] which guard the
  /// payload-presence invariants.
  void _onLocatorStateChange(
    ServiceRegistration<ServiceClass> registration,
    LocatorStatus state, {
    ServiceClass? instance,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Dart 3 pattern-switch: cases do NOT fall through. Each arm runs
    // independently; the absence of `break` after `_markReadyOrThrow` /
    // `_markFailedOrThrow` is intentional, not a C-style omission bug.
    // The `break` in the `starting` and `staged` arms is only there
    // because those arms would otherwise be empty cases, which reads
    // worse than an explicit break.
    switch (state) {
      case LocatorStatus.starting:
        // The registry already transitioned the registration to `starting`
        // in [ServiceLocatorRegistry._registerStaged] (via
        // [ServiceRegistration.markStarting]) before
        // [ServiceDescriptor.registerWith] was invoked, so the locator's
        // `starting` signal is informational-only and carries no state
        // change. This arm exists for switch exhaustiveness.
        break;
      case LocatorStatus.ready:
        _markReadyOrThrow(registration, instance);
      case LocatorStatus.failed:
        _markFailedOrThrow(registration, error: error, stackTrace: stackTrace);
      case LocatorStatus.staged:
        // Locators do not drive services back to `staged`; this arm
        // exists for switch exhaustiveness and is intentionally a no-op.
        break;
    }
  }

  /// Transitions [registration] to `ready` with [instance], or throws
  /// [StateError] when the locator reports `ready` without providing an
  /// instance (a contract violation by the locator implementation).
  void _markReadyOrThrow(
    ServiceRegistration<ServiceClass> registration,
    ServiceClass? instance,
  ) {
    if (instance == null) {
      throw StateError(
        'Locator reported ready for "${registration.name}" '
        'without providing an instance',
      );
    }
    registration.markReady(instance);
  }

  /// Transitions [registration] to `failed` with [error], or throws
  /// [StateError] when the locator reports `failed` without providing
  /// an error (a contract violation). Falls back to [StackTrace.current]
  /// when [stackTrace] is null so `markFailed` is always called with a
  /// non-null trace.
  void _markFailedOrThrow(
    ServiceRegistration<ServiceClass> registration, {
    required Object? error,
    required StackTrace? stackTrace,
  }) {
    if (error == null) {
      throw StateError(
        'Locator reported failure for "${registration.name}" '
        'without providing an error',
      );
    }
    registration.markFailed(error, stackTrace ?? StackTrace.current);
  }
}
