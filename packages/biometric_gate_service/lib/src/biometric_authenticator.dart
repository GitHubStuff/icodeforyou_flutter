// packages/biometric_gate_service/lib/src/biometric_authenticator.dart
import 'package:biometric_gate_service/src/biometric_capability.dart';
import 'package:biometric_gate_service/src/failures/biometric_failure.dart';
import 'package:fpdart/fpdart.dart';

/// Reports biometric availability and runs the biometric prompt.
///
/// This role covers user presence only — it neither reads nor writes any
/// stored value. Use it to gate access to the app itself (for example, to
/// unlock a previously authenticated session at launch) and to decide
/// whether to offer biometric features in the UI.
abstract interface class BiometricAuthenticator {
  /// Reports what biometric modality is available on this device.
  ///
  /// Cheap and non-prompting; safe to call on every launch. Use the result
  /// to decide whether to offer biometric features and to pick an
  /// appropriate label ("Use Face ID" vs "Use Touch ID" vs "Use biometric").
  Future<BiometricCapability> capability();

  /// Runs the biometric prompt and returns success or a typed failure.
  ///
  /// [reason] is shown to the user in the prompt; keep it short and
  /// action-oriented, as some platforms truncate long text.
  ///
  /// Returns [BiometricCancelled] if the user dismisses the prompt,
  /// [BiometricLockedOut] or [BiometricPermanentlyLockedOut] if the platform
  /// has disabled biometric authentication, [BiometricUnavailable] or
  /// [BiometricNotEnrolled] if the device cannot run the prompt, and
  /// [BiometricUnknownFailure] for any other error.
  Future<Either<BiometricFailure, Unit>> verify({required String reason});
}
