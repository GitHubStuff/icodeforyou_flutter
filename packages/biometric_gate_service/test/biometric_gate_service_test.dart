// packages/biometric_gate_service/test/biometric_gate_service_test.dart
//
// Sanity test for the public barrel: every exported symbol must be reachable
// from a single `package:biometric_gate_service/biometric_gate_service.dart`
// import. If a future change accidentally drops an export from the barrel,
// this test fails to compile and CI catches the regression before it ships.

import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('public barrel', () {
    test('exports BiometricCapability', () {
      const value = BiometricCapability.face;
      expect(value, isA<BiometricCapability>());
    });

    test('exports BiometricGateService interface', () {
      // Cannot instantiate; type reference alone proves it is exported.
      expect(BiometricGateService, isNotNull);
    });

    test('exports every BiometricFailure subclass', () {
      final failures = <BiometricFailure>[
        const BiometricUnavailable(),
        const BiometricNotEnrolled(),
        const BiometricCancelled(),
        const BiometricLockedOut(),
        const BiometricPermanentlyLockedOut(),
        const BiometricStorageFailure(message: 'x'),
        const BiometricUnknownFailure(message: 'y'),
      ];

      for (final f in failures) {
        expect(f, isA<BiometricFailure>());
      }
    });
  });
}
