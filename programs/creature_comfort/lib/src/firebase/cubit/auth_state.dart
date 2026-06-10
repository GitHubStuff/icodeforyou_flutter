// programs/creature_comfort/lib/src/firebase/cubit/auth_state.dart
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before the first [authStateChanges] event has been observed.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A register / login / sign-out call is in flight.
final class AuthInProgress extends AuthState {
  const AuthInProgress();
}

/// No user is currently signed in.
final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// A user is signed in.
final class AuthSignedIn extends AuthState {
  const AuthSignedIn({
    required this.uid,
    required this.email,
  });

  final String uid;
  final String? email;

  @override
  List<Object?> get props => [uid, email];
}

/// The last auth operation failed.
final class AuthFailure extends AuthState {
  const AuthFailure({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}
