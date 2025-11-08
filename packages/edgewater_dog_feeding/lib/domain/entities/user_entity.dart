// user_entity.dart

/// Represents a user in the domain layer
/// Following Single Responsibility Principle - only holds user data
class UserEntity {
  final String uid;
  final String email;
  final String displayName;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode;
}
