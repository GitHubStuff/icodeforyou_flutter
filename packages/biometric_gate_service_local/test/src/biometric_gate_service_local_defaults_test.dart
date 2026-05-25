// packages/biometric_gate_service_local/test/src/biometric_gate_service_local_defaults_test.dart

import 'package:biometric_gate_service_local/biometric_gate_service_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiometricGateServiceLocal defaults', () {
    test(
      'constructs with no arguments, exercising every default fallback',
      () {
        // Hits the `?? LocalAuthentication()`, `?? const FlutterSecureStorage()`,
        // `?? defaultBiometricErrorMapper`, `?? IOSOptions.defaultOptions`, and
        // `?? AndroidOptions.defaultOptions` branches in the constructor.
        final service = BiometricGateServiceLocal();

        expect(service, isA<BiometricGateServiceLocal>());
      },
    );
  });
}
