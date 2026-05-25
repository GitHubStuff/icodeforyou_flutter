// packages/services_locator/lib/src/locator_status.dart
//
// The four lifecycle states a `ServiceRegistration` can occupy. Drives
// exhaustive switches throughout the registry and locator adapters —
// any new variant added here must be handled everywhere.

// ignore_for_file: comment_references

/// Lifecycle state of a single [ServiceRegistration] within the
/// [ServiceLocatorRegistry].
///
/// Transitions flow forward only: `staged → starting → (ready | failed)`.
/// `starting` is the single in-flight state; `ready` and `failed` are
/// terminal. A failed registration stays failed — there is no recovery
/// path that crosses back through `staged` without an explicit reset.
///
/// The registry and both [ServiceLocator] implementations switch
/// exhaustively on this enum; adding a new variant will surface as a
/// compile-time error on every pattern-switch that needs updating.
enum LocatorStatus {
  /// The registration's builder threw during startup. Terminal state.
  ///
  /// Inspect `ServiceRegistration.error` for the originating exception
  /// and `.stackTrace` for the capture site. Every subsequent `register`
  /// / `getAsync` / `getSync` call on a failed registration rethrows
  /// the same canonical `ServiceStartupFailed` wrapper (cached on the
  /// registration at the moment of failure), so repeat observers all
  /// see identical exception identity.
  failed,

  /// The registration is fully materialized and available for
  /// retrieval. Terminal state.
  ///
  /// For sync services this is reached synchronously inside
  /// `SyncServiceDescriptor.registerWith`. For lazy-async services it
  /// is reached when the builder resolves on first access — which may
  /// be well after the registration's `pendingStart` future completed.
  ready,

  /// The descriptor is in the registry's indices but no registration
  /// work has started. Initial state of every staged registration and
  /// the only non-terminal entry point; all transitions begin from
  /// here.
  ///
  /// Stage-time graph validation (cycle detection, unknown-dependency
  /// detection) runs at `register` entry before any staged registration
  /// transitions out of this state, so participants in a bad graph
  /// stay at `staged` and can be retried after the configuration is
  /// fixed.
  staged,

  /// The registry is actively registering this service and its
  /// dependencies. Non-terminal; resolves to `ready` or `failed` when
  /// the descriptor's handoff completes (sync) or the builder resolves
  /// (lazy-async).
  ///
  /// One subtlety: for lazy-async services, `ServiceRegistration.
  /// pendingStart` resolves as soon as the locator handoff finishes —
  /// BEFORE the builder runs. A registration can sit at `starting`
  /// indefinitely while waiting for first access to trigger the
  /// builder; concurrent awaiters must re-check status after
  /// `pendingStart` completes to detect terminal transitions that
  /// happened after the handoff.
  starting,
}
