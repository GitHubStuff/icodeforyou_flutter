// packages/custom_errors/lib/src/not_initialized_error.dart

/// Error thrown when an uninitialized state or variable is accessed.
///
/// Indicates that an operation requires a non-null or configured value
/// before it can safely proceed.
class NotInitializedError extends Error {
  /// Creates a [NotInitializedError] with the specified [message].
  ///
  /// The [message] typically identifies the variable, property, or
  /// component that was accessed prior to initialization.
  NotInitializedError(this.message);

  /// A description or name of the uninitialized entity.
  final String message;

  @override
  String toString() =>
      'NotInitializedError: $message must be initialized '
      'before use.';
}
