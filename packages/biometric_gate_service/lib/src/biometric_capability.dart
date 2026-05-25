// packages/biometric_gate_service/lib/src/biometric_capability.dart

/// What kind of biometric authentication the device offers, if any.
///
/// Returned by `BiometricGateService.capability()` so the UI can show an
/// appropriate label and icon ("Use Face ID" vs "Use Touch ID" vs a generic
/// "Use biometric") without depending on `local_auth` or any other platform
/// SDK.
///
/// Values are ordered by specificity: prefer the most specific value when
/// the platform reports multiple. On Android the platform may abstract the
/// hardware type for security-classification reasons, in which case
/// [generic] is returned even when fingerprint or face hardware is present.
enum BiometricCapability {
  /// No biometric hardware, or hardware is present but unsupported by the
  /// current OS version.
  none,

  /// Hardware exists, but the user has not enrolled any biometric.
  ///
  /// The prompt cannot run until the user enrolls a face, fingerprint, or
  /// other biometric in system settings.
  notEnrolled,

  /// Face-based biometric (Face ID on iOS, face unlock on Android).
  face,

  /// Fingerprint-based biometric (Touch ID on iOS, fingerprint sensor on
  /// Android).
  fingerprint,

  /// Iris-based biometric. Rare; some Samsung devices.
  iris,

  /// Hardware is available and a biometric is enrolled, but the platform did
  /// not report the specific type. Common on Android, where the framework
  /// may surface only the security class (strong/weak) rather than the
  /// modality. Show a generic "Use biometric" label.
  generic,
}
