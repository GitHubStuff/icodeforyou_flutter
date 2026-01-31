// lib/src/error.dart
part of '../theme_package.dart';

/// Error types that can occur during theme operations.
sealed class ThemeError {
  const ThemeError();

  /// Hive database failed to initialize.
  const factory ThemeError.initializationFailed(String message) =
      _InitializationFailed;

  /// Failed to persist theme mode to Hive.
  const factory ThemeError.persistenceFailed(String message) =
      _PersistenceFailed;
}

final class _InitializationFailed extends ThemeError {
  const _InitializationFailed(this.message);

  final String message;

  @override
  String toString() => 'ThemeError.initializationFailed: $message';
}

final class _PersistenceFailed extends ThemeError {
  const _PersistenceFailed(this.message);

  final String message;

  @override
  String toString() => 'ThemeError.persistenceFailed: $message';
}
