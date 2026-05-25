// programs/creature_comforts/lib/src/auth/auth_service.dart
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:creature_comforts/src/auth/failures/auth_failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:service_locator/service_locator.dart';

/// Backend-agnostic authentication contract.
///
/// Implemented by `AuthServiceFirebase` for the production app. Other
/// backends (Supabase, AWS Cognito, custom) would each provide their own
/// impl; consumers depend only on this interface.
///
/// All operations return `Either<AuthFailure, T>`; no exceptions escape.
/// Callers handle every failure case via exhaustive `switch` on the sealed
/// [AuthFailure] hierarchy.
///
/// Implements [ServiceClass] so this interface can be the type parameter
/// of a [ServiceDescriptor] and be registered with the
/// [ServiceLocatorRegistry].
abstract interface class AuthService implements ServiceClass {
  /// Currently signed-in user, or `null` if no session exists.
  ///
  /// Read synchronously from the backend's persisted session — useful at
  /// app launch to decide whether to skip the login screen. Returns
  /// `null` after `signOut()` and before the next successful `signIn(...)`.
  AuthUser? get currentUser;

  /// Stream of authentication state changes.
  ///
  /// Emits `null` when the user signs out (or session expires) and a
  /// non-null [AuthUser] when sign-in succeeds. Cubits subscribe to this
  /// to keep the auth state machine in sync with the backend without
  /// polling.
  ///
  /// The stream is multi-subscribable; the underlying SDK is responsible
  /// for replaying the current state to new listeners.
  Stream<AuthUser?> authStateChanges();

  /// Signs in with email and password.
  ///
  /// Returns:
  /// - [AuthInvalidCredentials] when email/password don't match.
  /// - [AuthUserNotFound] when the email isn't registered (only if the
  ///   backend explicitly distinguishes — most do not, to prevent user
  ///   enumeration; impls should prefer [AuthInvalidCredentials]).
  /// - [AuthUserDisabled] when the account exists but has been disabled.
  /// - [AuthInvalidEmail] when the email format is rejected up-front.
  /// - [AuthNetworkFailure] when the backend is unreachable.
  /// - [AuthTooManyAttempts] when the backend rate-limits the caller.
  /// - [AuthBackendFailure] for any other backend error.
  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  });

  /// Signs the current user out, ending the session.
  ///
  /// Returns [AuthNotSignedIn] if no user was signed in. Other failures
  /// are infrastructural (network, backend) and surface as the
  /// appropriate sealed case.
  ///
  /// On success, [currentUser] becomes `null` and [authStateChanges]
  /// emits `null`.
  Future<Either<AuthFailure, Unit>> signOut();

  /// Sends a password-reset link to [email].
  ///
  /// The backend dispatches an email with a reset link the user follows
  /// in their mail client. Subsequent sign-in attempts use the new
  /// password. The current session, if any, is unaffected.
  ///
  /// Returns:
  /// - [AuthUserNotFound] if no account exists for [email] (some backends
  ///   return success here to prevent enumeration; impls should follow
  ///   the backend's lead).
  /// - [AuthInvalidEmail] if the format is rejected.
  /// - [AuthNetworkFailure] / [AuthBackendFailure] for infrastructure errors.
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
  });
}
