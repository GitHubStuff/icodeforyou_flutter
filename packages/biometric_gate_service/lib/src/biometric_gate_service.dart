// packages/biometric_gate_service/lib/src/biometric_gate_service.dart
import 'package:biometric_gate_service/src/biometric_capability.dart';
import 'package:biometric_gate_service/src/failures/biometric_failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:service_locator/service_locator.dart';

/// Biometric-gated capability and secure key/value store.
///
/// Provides three intertwined capabilities behind a single interface:
///
/// 1. A **biometric prompt** that proves the user is present, backed by the
///    platform's local authentication (Face ID, Touch ID, Android
///    BiometricPrompt). Used directly by [verify] to gate access to the app
///    itself, and used implicitly by [retrieve] to gate access to a stored
///    value.
/// 2. A **secure store** for opaque string values, encrypted at rest by the
///    platform's secure storage (iOS Keychain, Android Keystore /
///    EncryptedSharedPreferences, etc.).
/// 3. An **opt-in flag** persisted via [enable] / [disable] / [isEnabled]
///    that records whether the user wants biometric to be used at all.
///
/// The interface is intentionally **backend-agnostic**: it knows nothing
/// about emails, passwords, refresh tokens, or any other domain concept.
/// Callers — typically auth flows and other services — decide what to
/// store and under what keys. This keeps the gate reusable across auth
/// backends (Firebase, Supabase, AWS Cognito, custom) and across non-auth
/// use cases (API keys, wallet seeds, etc.).
///
/// All operations return `Either<BiometricFailure, T>`; no exceptions
/// escape the implementation. Callers handle every failure case via
/// exhaustive `switch` on the sealed [BiometricFailure] hierarchy.
abstract interface class BiometricGateService implements ServiceClass {
  /// Reports what biometric modality is available on this device.
  ///
  /// Cheap, non-prompting, safe to call on every launch. Use the result to
  /// decide whether to offer biometric features in the UI and to pick an
  /// appropriate label ("Use Face ID" vs "Use Touch ID" vs "Use biometric").
  Future<BiometricCapability> capability();

  /// Whether the user has opted into biometric protection.
  ///
  /// Independent of [capability]: a user may have enabled the gate on a
  /// device that later lost its enrolled biometric, in which case this
  /// returns `true` while [capability] returns
  /// [BiometricCapability.notEnrolled]. Callers should reconcile both.
  Future<bool> isEnabled();

  /// Records the user's opt-in and performs any impl-specific setup the
  /// gate needs to be ready for [verify] / [retrieve].
  ///
  /// Implementations are responsible for whatever bookkeeping their
  /// platform requires — sentinel records, key generation, OS handshakes —
  /// so callers do not need to know how a particular backend works. After
  /// this returns `Right(unit)`, the gate is fully usable.
  ///
  /// Idempotent: calling on an already-enabled gate is a no-op success.
  Future<Either<BiometricFailure, Unit>> enable();

  /// Records the user's opt-out and clears any values stored behind the gate.
  ///
  /// Idempotent: calling on a disabled gate is a no-op success.
  Future<Either<BiometricFailure, Unit>> disable();

  /// Runs the biometric prompt and returns success or a typed failure
  /// without involving the secure store.
  ///
  /// Use this to gate access to the *app itself* — for example, to unlock
  /// a previously-authenticated session at app launch. For gating access
  /// to a specific stored value, use [retrieve] instead.
  ///
  /// [reason] is shown to the user in the prompt (e.g. "Unlock to sign in").
  /// Keep it short and action-oriented; some platforms truncate long text.
  ///
  /// Returns:
  /// - [BiometricCancelled] if the user dismisses the prompt.
  /// - [BiometricLockedOut] / [BiometricPermanentlyLockedOut] if the
  ///   platform has disabled biometric authentication.
  /// - [BiometricUnavailable] / [BiometricNotEnrolled] if the device cannot
  ///   run the prompt.
  /// - [BiometricUnknownFailure] for any other platform error.
  Future<Either<BiometricFailure, Unit>> verify({required String reason});

  /// Stores [value] under [key] behind the biometric gate.
  ///
  /// On platforms that support OS-level biometric access control (iOS
  /// Keychain `accessControl`, Android Keystore
  /// `setUserAuthenticationRequired`), the value is bound to a key that
  /// requires biometric authentication for retrieval. On platforms without
  /// that support, the value is stored in the platform's secure store and
  /// retrieval is gated by an explicit prompt.
  ///
  /// The [value] is opaque: the gate does not interpret its contents.
  ///
  /// Returns [BiometricStorageFailure] if the underlying secure store
  /// rejects the write.
  Future<Either<BiometricFailure, Unit>> store({
    required String key,
    required String value,
  });

  /// Retrieves the value stored under [key], running the biometric prompt.
  ///
  /// [reason] is shown to the user in the prompt. See [verify] for the
  /// list of failure cases — this method may additionally return
  /// [BiometricStorageFailure] when the prompt succeeds but the secure
  /// store rejects the read (e.g. key not found).
  Future<Either<BiometricFailure, String>> retrieve({
    required String key,
    required String reason,
  });

  /// Deletes the value stored under [key].
  ///
  /// Does not run the biometric prompt. Idempotent: deleting a non-existent
  /// key is a no-op success.
  Future<Either<BiometricFailure, Unit>> clear({required String key});
}
