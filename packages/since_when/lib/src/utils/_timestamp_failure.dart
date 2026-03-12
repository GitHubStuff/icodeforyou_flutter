// lib/src/utils/_timestamp_failure.dart

part of '_timestamp_generator.dart';

/// Failure sealed class for [TimestampGenerator] operations.
sealed class TimestampFailure {
  const TimestampFailure();
}

/// Unique timestamp could not be generated after [_maxRetries] attempts.
final class TimestampCollisionExhausted extends TimestampFailure {
  const TimestampCollisionExhausted();

  @override
  String toString() =>
      'TimestampCollisionExhausted: '
      'failed to generate unique timestamp after $_maxRetries retries.';
}
