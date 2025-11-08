import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user_entity.dart';

/// Authentication states for BLoC pattern
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {}

/// State when authentication is in progress
class AuthLoading extends AuthState {}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {}

/// State when authentication fails
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
