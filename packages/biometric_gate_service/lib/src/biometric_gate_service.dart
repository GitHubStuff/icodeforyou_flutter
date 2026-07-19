// packages/biometric_gate_service/lib/src/biometric_gate_service.dart
import 'package:biometric_gate_service/src/biometric_authenticator.dart';
import 'package:biometric_gate_service/src/biometric_secure_store.dart';
import 'package:biometric_gate_service/src/failures/biometric_failure.dart';
import 'package:fpdart/fpdart.dart';

/// Biometric capability, prompt, and gated secure store behind one handle.
///
/// Composes [BiometricAuthenticator] (user presence) and
/// [BiometricSecureStore] (gated values), and adds the opt-in lifecycle
/// ([enable] / [disable] / [isEnabled]) that records whether the user wants
/// biometric protection at all.
///
/// The interface is intentionally backend-agnostic: it knows nothing about
/// emails, passwords, tokens, or any other domain concept. Callers decide
/// what to store and under what keys, which keeps the gate reusable across
/// auth backends and non-auth use cases.
///
/// Every operation returns `Either<BiometricFailure, T>`; no exceptions
/// escape an implementation. Callers handle each case via an exhaustive
/// `switch` on the sealed [BiometricFailure] hierarchy.
///
/// Registering this service with a dependency-injection mechanism is a
/// composition-root concern and is deliberately not expressed here. An
/// implementation (or a thin handle around one) carries whatever locator
/// marker the app's broker requires.
abstract interface class BiometricGateService
    implements BiometricAuthenticator, BiometricSecureStore {
  /// Whether the user has opted into biometric protection.
  ///
  /// Independent of [capability]: a user may have enabled the gate on a
  /// device that has since lost its enrolled biometric, so this can return
  /// `true` even when no biometric is currently enrolled. Callers should
  /// reconcile the two.
  Future<bool> isEnabled();

  /// Records the user's opt-in and performs whatever setup the backend needs
  /// to be ready for [verify] and [retrieve].
  ///
  /// Idempotent: enabling an already-enabled gate is a no-op success.
  Future<Either<BiometricFailure, Unit>> enable();

  /// Records the user's opt-out and, as a deliberate side effect, **purges
  /// every value stored behind the gate**.
  ///
  /// This is destructive: opting out removes the protected data, not merely
  /// the opt-in flag. Callers that need to keep the data must read it out
  /// before calling [disable].
  ///
  /// Idempotent: disabling an already-disabled gate is a no-op success.
  Future<Either<BiometricFailure, Unit>> disable();
}
