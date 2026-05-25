// programs/creature_comforts/lib/src/auth/auth_service_firebase.dart
import 'package:creature_comforts/src/auth/auth_service.dart';
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:creature_comforts/src/auth/failures/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

/// Maps a thrown object to an [AuthFailure].
///
/// Exposed as a typedef so tests can inject a fake mapping and verify the
/// wiring without depending on platform-specific error codes. Production
/// code uses [defaultAuthErrorMapper].
typedef AuthErrorMapper = AuthFailure Function(Object error);

/// Default mapping of thrown objects to [AuthFailure].
///
/// Recognises the [fb.FirebaseAuthException] codes documented for Firebase
/// Auth 6.x and falls back to [AuthBackendFailure] for anything else.
///
/// Firebase Auth deliberately does not distinguish "wrong password" from
/// "no such email" — both surface as `invalid-credential` to prevent user
/// enumeration. Impls should not try to reverse that.
AuthFailure defaultAuthErrorMapper(Object error) {
  if (error is fb.FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-mismatch' =>
        const AuthInvalidCredentials(),
      'user-not-found' => const AuthUserNotFound(),
      'user-disabled' => const AuthUserDisabled(),
      'invalid-email' => const AuthInvalidEmail(),
      'network-request-failed' => AuthNetworkFailure(cause: error),
      'too-many-requests' => AuthTooManyAttempts(cause: error),
      _ => AuthBackendFailure(
          message: '[${error.code}] ${error.message ?? 'Auth error'}',
          cause: error,
        ),
    };
  }
  return AuthBackendFailure(message: error.toString(), cause: error);
}

/// Firebase-backed implementation of [AuthService].
///
/// Wraps `package:firebase_auth`, mapping its `User` and `FirebaseAuthException`
/// types into the program's backend-agnostic [AuthUser] and [AuthFailure]
/// shapes.
///
/// All thrown objects are caught and converted to [AuthFailure] via the
/// injected [AuthErrorMapper]; no exceptions escape the public surface.
final class AuthServiceFirebase implements AuthService {
  /// Creates a Firebase-backed [AuthService].
  ///
  /// [firebaseAuth] defaults to `FirebaseAuth.instance`; tests inject a
  /// mock. [errorMapper] converts thrown objects to [AuthFailure];
  /// override in tests to verify error-path wiring.
  AuthServiceFirebase({
    fb.FirebaseAuth? firebaseAuth,
    AuthErrorMapper? errorMapper,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _mapError = errorMapper ?? defaultAuthErrorMapper;

  final fb.FirebaseAuth _auth;
  final AuthErrorMapper _mapError;

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return left(
          const AuthBackendFailure(
            message: 'Sign-in succeeded but no user was returned.',
          ),
        );
      }
      return right(_toAuthUser(user)!);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    if (_auth.currentUser == null) {
      return left(const AuthNotSignedIn());
    }
    try {
      await _auth.signOut();
      return right(unit);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return right(unit);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      return left(_mapError(e));
    }
  }

  /// Translates a Firebase `User` into an [AuthUser]. Returns `null` for
  /// `null` input, so [authStateChanges] and [currentUser] can use the
  /// same mapper.
  AuthUser? _toAuthUser(fb.User? user) {
    if (user == null) return null;
    final email = user.email;
    if (email == null) {
      // Email/password auth always sets `email`; this path is unreachable
      // in practice but guards against future provider additions (anonymous,
      // phone, federated) returning null-email users.
      return AuthUser(id: user.uid, email: '', displayName: user.displayName);
    }
    return AuthUser(id: user.uid, email: email, displayName: user.displayName);
  }

  /// Exposed for tests that need to inspect which Firebase instance the
  /// impl is bound to without exposing the field.
  @visibleForTesting
  fb.FirebaseAuth get debugFirebaseAuth => _auth;
}
