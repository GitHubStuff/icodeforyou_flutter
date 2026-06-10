// programs/creature_comforts/lib/src/auth/auth_user.dart
import 'package:meta/meta.dart';

/// A backend-agnostic representation of a signed-in user.
///
/// Holds the minimum identity information any [AuthService] backend can
/// reliably provide:
///
/// - [id] — opaque, stable, unique. Treat as a primary key only; do not
///   parse, slice, or pattern-match. Firebase calls this `uid`, Supabase
///   calls this the auth user `id`, AWS Cognito calls this the `sub`
///   claim. All three are opaque strings to this program.
/// - [email] — the email the user signed in with.
/// - [displayName] — optional human-readable label. May be `null` when the
///   backend doesn't surface one (Firebase email/password sign-in does
///   not set a display name by default).
///
/// Deliberately excluded:
///
/// - Tokens, refresh tokens, session expiry — these are backend
///   implementation details handled inside [AuthService] impls. The UI
///   does not need them.
/// - Photo URL, phone number, custom claims — out of scope for v1; add
///   when a feature actually needs them.
@immutable
final class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  /// Opaque, stable identifier for this user.
  final String id;

  /// Email address used to sign in.
  final String email;

  /// Optional human-readable label. May be `null`.
  final String? displayName;

  /// The label to show in the UI: [displayName] if set, otherwise [email].
  String get label => displayName ?? email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          other.id == id &&
          other.email == email &&
          other.displayName == displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, displayName: $displayName)';
}
