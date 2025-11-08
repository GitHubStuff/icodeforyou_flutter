import 'package:equatable/equatable.dart';

/// Authentication events for BLoC pattern
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in with email and password
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign out
class SignOutRequested extends AuthEvent {}

/// Event to check current authentication status
class CheckAuthRequested extends AuthEvent {}
