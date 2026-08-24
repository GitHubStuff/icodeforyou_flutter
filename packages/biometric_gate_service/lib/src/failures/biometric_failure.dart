// packages/biometric_gate_service/lib/src/failures/biometric_failure.dart

import 'package:meta/meta.dart';

/// The base class for all failures returned by `BiometricGateService`
/// operations.
///
/// This is a sealed class. When returned as the `Left` side of an
/// `Either<BiometricFailure, T>`, callers should handle every possible
/// failure explicitly via an exhaustive `switch` statement.
@immutable
sealed class BiometricFailure {
  /// Creates a [BiometricFailure] with a human-readable [message] and an
  /// optional underlying [cause].
  const BiometricFailure({required this.message, this.cause});

  /// A human-readable description of the failure.
  ///
  /// This message is generally intended for debugging or logging. UI elements
  /// should typically map the specific subclass to a localized user-facing
  /// message.
  final String message;

  /// The optional underlying error that triggered this failure.
  ///
  /// This is often a `PlatformException` or similar low-level error from
  /// the underlying biometric or storage plugins.
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// Indicates that the device has no biometric hardware, or the OS does not
/// support it.
///
/// This is returned by capability checks and any operation that requires the
/// prompt when the platform cannot execute one.
final class BiometricUnavailable extends BiometricFailure {
  /// Creates a [BiometricUnavailable] failure.
  const BiometricUnavailable()
    : super(message: 'Biometric authentication is not available.');
}

/// Indicates that biometric hardware exists but the user has not enrolled any
/// biometric.
///
/// Distinct from [BiometricUnavailable]: the device can run the prompt, but
/// there is nothing to match against. The user must enroll a face or
/// fingerprint in system settings before biometric flows can be used.
final class BiometricNotEnrolled extends BiometricFailure {
  /// Creates a [BiometricNotEnrolled] failure.
  const BiometricNotEnrolled()
    : super(message: 'No biometric is enrolled on this device.');
}

/// Indicates that the user dismissed the biometric prompt before completing
/// it.
///
/// This is typically not an error in the strict sense. Callers should usually
/// fall back to a password, PIN, or other authentication method when
/// receiving this.
final class BiometricCancelled extends BiometricFailure {
  /// Creates a [BiometricCancelled] failure.
  const BiometricCancelled()
    : super(message: 'The user cancelled the biometric prompt.');
}

/// Indicates that biometric matching failed too many times.
///
/// The OS has temporarily disabled biometric authentication and requires a
/// device passcode or PIN to unlock the device before biometrics can be used
/// again.
final class BiometricLockedOut extends BiometricFailure {
  /// Creates a [BiometricLockedOut] failure with an optional [cause].
  const BiometricLockedOut({super.cause})
    : super(
        message:
            'Biometric authentication is locked out. '
            'Use the device passcode to unlock.',
      );
}

/// Indicates that the biometric prompt was permanently disabled.
///
/// Some platforms surface this as distinct from [BiometricLockedOut]. A
/// permanent lock requires the user to remove and re-add their biometric
/// credentials in the OS system settings.
final class BiometricPermanentlyLockedOut extends BiometricFailure {
  /// Creates a [BiometricPermanentlyLockedOut] failure with an optional
  /// [cause].
  const BiometricPermanentlyLockedOut({super.cause})
    : super(
        message:
            'Biometric authentication is permanently disabled. '
            'Re-enroll a biometric in system settings.',
      );
}

/// Indicates that a read or write to the secure store failed.
///
/// Distinct from biometric prompt failures: the prompt itself may have
/// succeeded (or not been required), but the underlying secure storage layer
/// rejected the operation (e.g., due to key invalidation).
final class BiometricStorageFailure extends BiometricFailure {
  /// Creates a [BiometricStorageFailure] with a [message] and an optional
  /// [cause].
  const BiometricStorageFailure({required super.message, super.cause});
}

/// A catch-all for any other platform error not covered by the specific
/// subclasses.
///
/// New platforms or future versions of the underlying APIs may surface error
/// codes that do not map to any of the dedicated subclasses. This failure
/// carries the original [cause] for diagnosis and logging.
final class BiometricUnknownFailure extends BiometricFailure {
  /// Creates a [BiometricUnknownFailure] with a [message] and an optional
  /// [cause].
  const BiometricUnknownFailure({required super.message, super.cause});
}
