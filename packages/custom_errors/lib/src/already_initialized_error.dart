// packages/custom_errors/lib/src/already_initialized_error.dart

/// Error thrown when an attempt to initialize something already initialized.
///
/// Indicates that an operation requires a non-null or configured value
/// before it can safely proceed.
class AlreadyInitializedError extends Error {
  /// Creates a [AlreadyInitializedError] with the specified [message].
  ///
  /// The [message] typically identifies the variable, property, or
  /// component that was already initialized.
  AlreadyInitializedError(this.message);

  /// A description or name of the initialized entity.
  final String message;

  @override
  String toString() =>
      'AlreadyInitializedError: $message has been initialized already';
}
