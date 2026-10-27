// packages/platform_tools/lib/src/unsuppored_platform_exception.dart
import 'package:flutter/foundation.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;

/// Thrown when an operation is requested for a [TargetPlatform] that this
/// package does not support.
///
/// Carries the offending [platform] so callers can branch on it, log it, or
/// surface it to the user without parsing a message string.
// TODO(steven): Create test
@immutable
class UnsupportedPlatformException implements Exception {
  /// Creates an [UnsupportedPlatformException] for [platform].
  const UnsupportedPlatformException(this.platform);

  /// The platform that was requested but is not supported.
  final OSPlatform platform;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnsupportedPlatformException && other.platform == platform;

  @override
  int get hashCode => platform.hashCode;

  @override
  String toString() =>
      'UnsupportedPlatformException: ${platform.name} is not supported';
}
