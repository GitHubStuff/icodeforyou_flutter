// packages/biometric_gate_service/test/src/biometric_capability_test.dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiometricCapability', () {
    test('declares the expected values in order', () {
      expect(BiometricCapability.values, <BiometricCapability>[
        BiometricCapability.none,
        BiometricCapability.notEnrolled,
        BiometricCapability.face,
        BiometricCapability.fingerprint,
        BiometricCapability.iris,
        BiometricCapability.generic,
      ]);
    });

    test('values are pairwise distinct', () {
      final set = BiometricCapability.values.toSet();
      expect(set.length, BiometricCapability.values.length);
    });

    test('exhaustive switch covers every value without a default', () {
      // If a new value is added without updating this switch, the analyzer
      // flags non-exhaustiveness and this test fails to compile. That's the
      // contract: the enum is the source of truth for call sites.
      String label(BiometricCapability c) => switch (c) {
            BiometricCapability.none => 'none',
            BiometricCapability.notEnrolled => 'not-enrolled',
            BiometricCapability.face => 'face',
            BiometricCapability.fingerprint => 'fingerprint',
            BiometricCapability.iris => 'iris',
            BiometricCapability.generic => 'generic',
          };

      expect(
        BiometricCapability.values.map(label).toList(),
        <String>['none', 'not-enrolled', 'face', 'fingerprint', 'iris',
            'generic'],
      );
    });
  });
}
