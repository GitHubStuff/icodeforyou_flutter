// programs/creature_comforts/lib/src/auth/failures/auth_failure.dart
import 'package:meta/meta.dart';

/// Failures returned from [AuthService] operations.
///
/// Returned as the `Left` side of an `Either<AuthFailure, T>` so callers
/// handle every case explicitly via exhaustive `switch`.
///
/// Each subclass maps to a recovery action the UI knows how to take:
/// [AuthInvalidCredentials] → "wrong password" inline message,
/// [AuthUserNotFound] → suggest sign-up or check spelling,
/// [AuthNetworkFailure] → "no connection" banner,
/// [AuthTooManyAttempts] → "try again later" with cooldown,
/// [AuthBackendFailure] → generic catch-all surfaced verbatim.
@immutable
sealed class AuthFailure {
  const AuthFailure({required this.message, this.cause});

  /// Human-readable description of the failure.
  final String message;

  /// Optional underlying error (e.g. a `FirebaseAuthException`).
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// Email or password is incorrect.
///
/// The backend should not distinguish "wrong email" from "wrong password" in
/// its error mapping — surfacing only the combined case avoids enumeration
/// attacks. Use [AuthUserNotFound] only when the *backend* explicitly returns
/// a "no such user" response that's already public information.
final class AuthInvalidCredentials extends AuthFailure {
  const AuthInvalidCredentials()
      : super(message: 'Email or password is incorrect.');
}

/// No account exists for the supplied email.
final class AuthUserNotFound extends AuthFailure {
  const AuthUserNotFound()
      : super(message: 'No account found for that email.');
}

/// The user account exists but has been disabled by an administrator.
final class AuthUserDisabled extends AuthFailure {
  const AuthUserDisabled() : super(message: 'This account is disabled.');
}

/// The supplied email is not a valid email address.
final class AuthInvalidEmail extends AuthFailure {
  const AuthInvalidEmail() : super(message: 'That email address is invalid.');
}

/// The user's network is offline or the backend is unreachable.
final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure({super.cause})
      : super(message: 'Network error. Check your connection.');
}

/// The backend has temporarily blocked sign-in attempts due to rate limiting.
final class AuthTooManyAttempts extends AuthFailure {
  const AuthTooManyAttempts({super.cause})
      : super(message: 'Too many attempts. Try again later.');
}

/// No user is currently signed in. Returned by operations that require an
/// authenticated session (e.g. `signOut` when already signed out).
final class AuthNotSignedIn extends AuthFailure {
  const AuthNotSignedIn() : super(message: 'No user is signed in.');
}

/// Catch-all for any backend error not covered by the specific cases above.
final class AuthBackendFailure extends AuthFailure {
  const AuthBackendFailure({required super.message, super.cause});
}
