// firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_respository.dart';

/// Concrete implementation of AuthRepository using Firebase
/// Following Dependency Inversion - depends on abstraction
class FirebaseAuthService implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Converts Firebase User to UserEntity
  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;

    // Use displayName if set, otherwise extract from email
    final displayName =
        user.displayName ?? user.email?.split('@').first ?? 'Unknown User';

    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
    );
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if not set
      if (credential.user != null && credential.user!.displayName == null) {
        final nameFromEmail = email.split('@').first;
        await credential.user!.updateDisplayName(nameFromEmail);
        await credential.user!.reload();
        return _userFromFirebase(_firebaseAuth.currentUser);
      }

      return _userFromFirebase(credential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  /// Maps Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
