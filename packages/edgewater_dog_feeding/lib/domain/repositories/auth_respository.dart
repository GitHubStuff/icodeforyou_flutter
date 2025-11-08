import '../entities/user_entity.dart';

/// Abstract authentication repository
/// Following Interface Segregation Principle - focused interface
/// Designed to work with flutter_bloc/cubit
abstract class AuthRepository {
  /// Signs in a user with email and password
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user
  Future<void> signOut();

  /// Gets the current signed-in user
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes for BLoC
  Stream<UserEntity?> get authStateChanges;
}
