// packages/biometric_gate_service_local/lib/src/biometric_gate_service_local.dart
// ignore: lines_longer_than_80_chars
// ignore_for_file: document_ignores, noop_primitive_operations, avoid_catches_without_on_clauses

import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';

/// Maps a thrown object to a [BiometricFailure].
///
/// Exposed as a typedef so tests can inject a fake mapping and verify the
/// wiring without depending on platform-specific error codes. Production
/// code uses [defaultBiometricErrorMapper].
typedef BiometricErrorMapper = BiometricFailure Function(Object error);

/// Default mapping of thrown objects to [BiometricFailure].
///
/// Recognises the [LocalAuthException] codes surfaced by `local_auth` 3.x
/// and falls back to [BiometricUnknownFailure] for anything else, including
/// codes added in future versions of the underlying plugin.
BiometricFailure defaultBiometricErrorMapper(Object error) {
  if (error is LocalAuthException) {
    final code = error.code;
    if (code == LocalAuthExceptionCode.noBiometricHardware) {
      return const BiometricUnavailable();
    }
    if (code == LocalAuthExceptionCode.noBiometricsEnrolled) {
      return const BiometricNotEnrolled();
    }
    if (code == LocalAuthExceptionCode.temporaryLockout) {
      return BiometricLockedOut(cause: error);
    }
    if (code == LocalAuthExceptionCode.biometricLockout) {
      return BiometricPermanentlyLockedOut(cause: error);
    }
    return BiometricUnknownFailure(
      message: '[${code.name}] ${error.toString()}',
      cause: error,
    );
  }
  return BiometricUnknownFailure(message: error.toString(), cause: error);
}

/// Storage key under which the opt-in flag is persisted.
@visibleForTesting
const kBiometricEnabledKey = '__biometric_gate_enabled__';

/// Local implementation of [BiometricGateService].
///
/// Combines the platform's biometric prompt (via `local_auth`) with the
/// platform's secure key/value store (via `flutter_secure_storage`) to
/// provide a backend-agnostic biometric-gated store.
///
/// All thrown objects are caught and converted to [BiometricFailure] via
/// the injected [BiometricErrorMapper]; no exceptions escape the public
/// surface.
final class BiometricGateServiceLocal implements BiometricGateService {
  /// Creates a local biometric gate.
  ///
  /// [localAuth] and [secureStorage] default to fresh instances; tests
  /// inject mocks.
  ///
  /// [errorMapper] converts thrown objects to [BiometricFailure]; override
  /// in tests to verify error-path behavior.
  ///
  /// [iosOptions] / [androidOptions] are passed to every secure-storage
  /// call. Override to enable additional access controls (e.g. biometric
  /// access control on the iOS Keychain item directly).
  BiometricGateServiceLocal({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
    BiometricErrorMapper? errorMapper,
    IOSOptions? iosOptions,
    AndroidOptions? androidOptions,
  }) : _auth = localAuth ?? LocalAuthentication(),
       _storage = secureStorage ?? const FlutterSecureStorage(),
       _mapError = errorMapper ?? defaultBiometricErrorMapper,
       _iosOptions = iosOptions ?? IOSOptions.defaultOptions,
       _androidOptions = androidOptions ?? AndroidOptions.defaultOptions;

  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;
  final BiometricErrorMapper _mapError;
  final IOSOptions _iosOptions;
  final AndroidOptions _androidOptions;

  @override
  Future<BiometricCapability> capability() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return BiometricCapability.none;

      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return BiometricCapability.none;

      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) return BiometricCapability.notEnrolled;

      if (available.contains(BiometricType.face)) {
        return BiometricCapability.face;
      }
      if (available.contains(BiometricType.fingerprint)) {
        return BiometricCapability.fingerprint;
      }
      if (available.contains(BiometricType.iris)) {
        return BiometricCapability.iris;
      }
      // strong / weak on Android map to generic.
      return BiometricCapability.generic;
    } catch (_) {
      return BiometricCapability.none;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      final raw = await _storage.read(
        key: kBiometricEnabledKey,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return raw == 'true';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<BiometricFailure, Unit>> enable() async {
    try {
      await _storage.write(
        key: kBiometricEnabledKey,
        value: 'true',
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return right(unit);
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<BiometricFailure, Unit>> disable() async {
    try {
      await _storage.deleteAll(
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return right(unit);
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<BiometricFailure, Unit>> verify({
    required String reason,
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!ok) return left(const BiometricCancelled());
      return right(unit);
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<BiometricFailure, Unit>> store({
    required String key,
    required String value,
  }) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return right(unit);
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<BiometricFailure, String>> retrieve({
    required String key,
    required String reason,
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (!ok) return left(const BiometricCancelled());

      final value = await _storage.read(
        key: key,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      if (value == null) {
        return left(
          BiometricStorageFailure(message: 'No value stored under "$key".'),
        );
      }
      return right(value);
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<BiometricFailure, Unit>> clear({
    required String key,
  }) async {
    try {
      await _storage.delete(
        key: key,
        iOptions: _iosOptions,
        aOptions: _androidOptions,
      );
      return right(unit);
    } catch (e) {
      return left(_mapError(e));
    }
  }
}
