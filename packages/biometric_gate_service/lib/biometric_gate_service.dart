// packages/biometric_gate_service/lib/biometric_gate_service.dart
// ignore_for_file: comment_references

/// Backend-agnostic biometric-gated secure storage interface.
///
/// Exposes the [BiometricGateService] interface, the [BiometricCapability]
/// enum reporting available hardware, and the sealed [BiometricFailure]
/// hierarchy.
///
/// Programs depend on the interface; an implementation (e.g. the local
/// `local_auth` + `flutter_secure_storage` impl) is registered with the
/// services broker at app startup.
library;

export 'src/biometric_capability.dart';
export 'src/biometric_gate_service.dart';
export 'src/failures/biometric_failure.dart';
