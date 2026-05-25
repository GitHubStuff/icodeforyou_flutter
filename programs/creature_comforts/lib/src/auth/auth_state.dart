// programs/creature_comforts/lib/src/auth/auth_state.dart
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:creature_comforts/src/auth/failures/auth_failure.dart';
import 'package:meta/meta.dart';

/// State machine for [AuthCubit].
///
/// The auth gate in `app.dart` routes screens based on the current state:
///
///  - [AuthInitializing] — splash; cubit is reading `currentUser` and the
///    biometric preference to decide which terminal state to land in.
///  - [Unauthenticated] — login screen; no session, no stored credentials.
///    Optionally carries a [failure] when the previous sign-in attempt
///    surfaced one.
///  - [BiometricLocked] — unlock screen; a Firebase session exists and the
///    user previously opted into biometric. The unlock screen shows
///    "tap to sign in as <user>" and runs the biometric prompt on tap.
///  - [Authenticated] — the rail; user is fully signed in and unlocked.
///
/// Sealed so the auth gate's `switch` is exhaustive at compile time. Adding
/// a new state forces every consumer to handle it.
@immutable
sealed class AuthState {
  const AuthState();
}

/// Cubit is resolving the initial auth state.
///
/// Lasts only as long as `bootstrap()` takes to read `currentUser`
/// synchronously and `BiometricGateService.isEnabled()` asynchronously —
/// typically a single event loop turn.
final class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// No session exists. The login screen is shown.
///
/// [failure] is non-null when this state was reached via a failed sign-in
/// attempt — the login screen renders the message inline. After the user
/// dismisses or retries, [failure] is cleared.
final class Unauthenticated extends AuthState {
  const Unauthenticated({this.failure});

  /// Failure from the most recent sign-in attempt, if any.
  final AuthFailure? failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unauthenticated && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Unauthenticated(failure: $failure)';
}

/// A session exists but is gated behind biometric authentication.
///
/// Carries the [user] so the unlock screen can show "tap to sign in as
/// <email>" without re-fetching, and so a successful unlock can transition
/// to [Authenticated] with the same user attached.
final class BiometricLocked extends AuthState {
  const BiometricLocked({required this.user});

  final AuthUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiometricLocked && other.user == user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'BiometricLocked(user: $user)';
}

/// User is fully signed in and unlocked. The rail is shown.
final class Authenticated extends AuthState {
  const Authenticated({required this.user});

  final AuthUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authenticated && other.user == user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'Authenticated(user: $user)';
}
