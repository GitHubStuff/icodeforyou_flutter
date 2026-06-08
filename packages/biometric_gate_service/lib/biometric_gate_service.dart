// packages/biometric_gate_service/lib/biometric_gate_service.dart
// ignore_for_file: comment_references

/// Backend-agnostic biometric-gated secure storage contract.
///
/// Exposes the composable role interfaces [BiometricAuthenticator] and
/// [BiometricSecureStore], the [BiometricGateService] that unites them with
/// the opt-in lifecycle, the [BiometricCapability] enum reporting available
/// hardware, and the sealed [BiometricFailure] hierarchy.
///
/// Programs depend on these contracts; an implementation (for example, a
/// `local_auth` + `flutter_secure_storage` backend) is registered with the
/// services broker at app startup.
library;

export 'src/biometric_authenticator.dart';
export 'src/biometric_capability.dart';
export 'src/biometric_gate_service.dart';
export 'src/biometric_secure_store.dart';
export 'src/failures/biometric_failure.dart';
