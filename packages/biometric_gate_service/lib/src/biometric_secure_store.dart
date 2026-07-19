// packages/biometric_gate_service/lib/src/biometric_secure_store.dart
import 'package:biometric_gate_service/src/failures/biometric_failure.dart';
import 'package:fpdart/fpdart.dart';

/// A secure key/value store whose reads are gated by biometric
/// authentication.
///
/// Values are opaque strings; this role does not interpret their contents,
/// which keeps it reusable across auth backends and non-auth use cases
/// (API keys, wallet seeds, and so on).
abstract interface class BiometricSecureStore {
  /// Stores [value] under [key].
  ///
  /// The guarantee is that a later [retrieve] of [key] succeeds only after a
  /// successful biometric authentication. How a backend binds the value to
  /// that authentication is an implementation concern, not part of this
  /// contract.
  ///
  /// Returns [BiometricStorageFailure] if the underlying store rejects the
  /// write.
  Future<Either<BiometricFailure, Unit>> store({
    required String key,
    required String value,
  });

  /// Retrieves the value stored under [key], gated by a biometric prompt.
  ///
  /// [reason] is shown to the user in the prompt. Returns the same prompt
  /// failures as a `verify` call (cancelled, locked out, unavailable, not
  /// enrolled, unknown), and additionally [BiometricStorageFailure] when the
  /// prompt succeeds but no value is stored under [key].
  Future<Either<BiometricFailure, String>> retrieve({
    required String key,
    required String reason,
  });

  /// Deletes the value stored under [key].
  ///
  /// Does not run the biometric prompt. Idempotent: deleting an absent key
  /// is a no-op success.
  Future<Either<BiometricFailure, Unit>> clear({required String key});
}
