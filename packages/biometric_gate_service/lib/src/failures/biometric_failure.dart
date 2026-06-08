// packages/biometric_gate_service/lib/src/failures/biometric_failure.dart
// ignore_for_file: no_runtimetype_tostring, public_member_api_docs, comment_references

import 'package:meta/meta.dart';

/// Failures returned from [BiometricGateService] operations.
///
/// Returned as the `Left` side of an `Either<BiometricFailure, T>` so callers
/// handle every case explicitly via exhaustive `switch`.
@immutable
sealed class BiometricFailure {
  const BiometricFailure({required this.message, this.cause});

  /// Human-readable description of the failure.
  final String message;

  /// Optional underlying error (e.g. a `PlatformException`).
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// The device has no biometric hardware, or the OS does not support it.
///
/// Returned by capability checks and any operation that requires the prompt
/// when the platform cannot run one.
final class BiometricUnavailable extends BiometricFailure {
  const BiometricUnavailable()
    : super(message: 'Biometric authentication is not available.');
}

/// Biometric hardware exists but the user has not enrolled any biometric.
///
/// Distinct from [BiometricUnavailable]: the device can run the prompt, but
/// there is nothing to match against. The user must enroll in system
/// settings before biometric flows can be used.
final class BiometricNotEnrolled extends BiometricFailure {
  const BiometricNotEnrolled()
    : super(message: 'No biometric is enrolled on this device.');
}

/// The user dismissed the biometric prompt before completing it.
///
/// Not an error in the strict sense — callers typically fall back to a
/// password or other authentication method when they receive this.
final class BiometricCancelled extends BiometricFailure {
  const BiometricCancelled()
    : super(message: 'The user cancelled the biometric prompt.');
}

/// Biometric matching failed too many times; the OS has temporarily disabled
/// biometric authentication and requires a device passcode to unlock.
final class BiometricLockedOut extends BiometricFailure {
  const BiometricLockedOut({super.cause})
    : super(
        message:
            'Biometric authentication is locked out. '
            'Use the device passcode to unlock.',
      );
}

/// The biometric prompt was permanently disabled until the user re-enrolls.
///
/// Some platforms surface this distinct from [BiometricLockedOut]: a
/// permanent lock requires the user to remove and re-add their biometric
/// in system settings.
final class BiometricPermanentlyLockedOut extends BiometricFailure {
  const BiometricPermanentlyLockedOut({super.cause})
    : super(
        message:
            'Biometric authentication is permanently disabled. '
            'Re-enroll a biometric in system settings.',
      );
}

/// A read or write to the secure store failed.
///
/// Distinct from biometric prompt failures: the prompt may have succeeded
/// (or not been required), but the underlying secure storage layer rejected
/// the operation.
final class BiometricStorageFailure extends BiometricFailure {
  const BiometricStorageFailure({required super.message, super.cause});
}

/// Catch-all for any other platform error not covered by the specific cases
/// above.
///
/// New platforms or future versions of the underlying APIs may surface error
/// codes that do not map to any of the dedicated subclasses; this carries
/// the original cause for diagnosis.
final class BiometricUnknownFailure extends BiometricFailure {
  const BiometricUnknownFailure({required super.message, super.cause});
}
