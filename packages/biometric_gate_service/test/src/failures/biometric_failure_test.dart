// packages/biometric_gate_service/test/src/failures/biometric_failure_test.dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiometricFailure', () {
    group('BiometricUnavailable', () {
      const failure = BiometricUnavailable();

      test('carries the canonical message', () {
        expect(failure.message, 'Biometric authentication is not available.');
      });

      test('has no cause', () {
        expect(failure.cause, isNull);
      });

      test('toString includes runtimeType and message', () {
        expect(
          failure.toString(),
          'BiometricUnavailable(Biometric authentication is not available.)',
        );
      });
    });

    group('BiometricNotEnrolled', () {
      const failure = BiometricNotEnrolled();

      test('carries the canonical message', () {
        expect(failure.message, 'No biometric is enrolled on this device.');
      });

      test('has no cause', () {
        expect(failure.cause, isNull);
      });

      test('toString includes runtimeType and message', () {
        expect(
          failure.toString(),
          'BiometricNotEnrolled(No biometric is enrolled on this device.)',
        );
      });
    });

    group('BiometricCancelled', () {
      const failure = BiometricCancelled();

      test('carries the canonical message', () {
        expect(failure.message, 'The user cancelled the biometric prompt.');
      });

      test('has no cause', () {
        expect(failure.cause, isNull);
      });

      test('toString includes runtimeType and message', () {
        expect(
          failure.toString(),
          'BiometricCancelled(The user cancelled the biometric prompt.)',
        );
      });
    });

    group('BiometricLockedOut', () {
      test('defaults to no cause', () {
        const failure = BiometricLockedOut();
        expect(failure.cause, isNull);
        expect(
          failure.message,
          'Biometric authentication is locked out. '
          'Use the device passcode to unlock.',
        );
      });

      test('carries an optional cause', () {
        final cause = Exception('locked');
        final failure = BiometricLockedOut(cause: cause);
        expect(failure.cause, same(cause));
      });

      test('toString includes runtimeType and message', () {
        const failure = BiometricLockedOut();
        expect(
          failure.toString(),
          'BiometricLockedOut(Biometric authentication is locked out. '
          'Use the device passcode to unlock.)',
        );
      });
    });

    group('BiometricPermanentlyLockedOut', () {
      test('defaults to no cause', () {
        const failure = BiometricPermanentlyLockedOut();
        expect(failure.cause, isNull);
        expect(
          failure.message,
          'Biometric authentication is permanently disabled. '
          'Re-enroll a biometric in system settings.',
        );
      });

      test('carries an optional cause', () {
        final cause = Exception('permanent');
        final failure = BiometricPermanentlyLockedOut(cause: cause);
        expect(failure.cause, same(cause));
      });

      test('toString includes runtimeType and message', () {
        const failure = BiometricPermanentlyLockedOut();
        expect(
          failure.toString(),
          'BiometricPermanentlyLockedOut('
          'Biometric authentication is permanently disabled. '
          'Re-enroll a biometric in system settings.)',
        );
      });
    });

    group('BiometricStorageFailure', () {
      test('carries the provided message', () {
        const failure = BiometricStorageFailure(message: 'disk full');
        expect(failure.message, 'disk full');
        expect(failure.cause, isNull);
      });

      test('carries an optional cause', () {
        final cause = StateError('write failed');
        final failure = BiometricStorageFailure(
          message: 'write failed',
          cause: cause,
        );
        expect(failure.cause, same(cause));
      });

      test('toString includes runtimeType and message', () {
        const failure = BiometricStorageFailure(message: 'disk full');
        expect(failure.toString(), 'BiometricStorageFailure(disk full)');
      });
    });

    group('BiometricUnknownFailure', () {
      test('carries the provided message', () {
        const failure = BiometricUnknownFailure(message: 'unmapped code 42');
        expect(failure.message, 'unmapped code 42');
        expect(failure.cause, isNull);
      });

      test('carries an optional cause', () {
        final cause = Exception('boom');
        final failure = BiometricUnknownFailure(
          message: 'unmapped code 42',
          cause: cause,
        );
        expect(failure.cause, same(cause));
      });

      test('toString includes runtimeType and message', () {
        const failure = BiometricUnknownFailure(message: 'unmapped code 42');
        expect(
          failure.toString(),
          'BiometricUnknownFailure(unmapped code 42)',
        );
      });
    });
  });
}
