// packages/biometric_gate_service_local/lib/biometric_gate_service_local.dart
// ignore_for_file: comment_references

/// Local implementation of [BiometricGateService] using `local_auth` and
/// `flutter_secure_storage`.
///
/// Exposes [BiometricGateServiceLocal], the default platform-error mapper
/// [defaultBiometricErrorMapper], and the [BiometricErrorMapper] typedef
/// for tests that wish to inject a custom mapping.
///
/// Re-exports the interface package so consumers can depend on this single
/// barrel and pick up the abstract types and sealed failures alongside the
/// implementation.
library;

export 'package:biometric_gate_service/biometric_gate_service.dart';

export 'src/biometric_gate_service_local.dart';
