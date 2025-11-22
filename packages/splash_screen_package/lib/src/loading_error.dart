// loading_error.dart

import 'package:equatable/equatable.dart';

/// Represents an error that occurred during app initialization or loading.
class LoadingError extends Equatable {
  /// A human-readable error message describing what went wrong.
  final String errorMessage;

  /// Optional additional details about the error for debugging or display purposes.
  final Map<String, dynamic>? errorDetails;

  const LoadingError(this.errorMessage, [this.errorDetails]);

  @override
  List<Object?> get props => [errorMessage, errorDetails];

  @override
  String toString() =>
      'LoadingError(errorMessage: $errorMessage, errorDetails: $errorDetails)';
}
