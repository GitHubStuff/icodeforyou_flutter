// ignore_for_file: public_member_api_docs

part of 'since_when_database.dart';

/// Failure sealed class for [SinceWhenDatabase] lifecycle operations.
sealed class SinceWhenFailure {
  const SinceWhenFailure();
}

/// Database name is empty or whitespace.
final class SinceWhenInvalidName extends SinceWhenFailure {
  const SinceWhenInvalidName();

  @override
  String toString() => 'SinceWhenInvalidName: name cannot be empty.';
}

/// Database file already exists (raised under [DatabaseAccess.create]).
final class SinceWhenAlreadyExists extends SinceWhenFailure {
  const SinceWhenAlreadyExists();

  @override
  String toString() => 'SinceWhenAlreadyExists: database file already exists.';
}

/// Database file does not exist (raised under [DatabaseAccess.open]).
final class SinceWhenNotFound extends SinceWhenFailure {
  const SinceWhenNotFound();

  @override
  String toString() => 'SinceWhenNotFound: database file does not exist.';
}

/// An unexpected error occurred while opening the database.
final class SinceWhenOpenFailure extends SinceWhenFailure {
  const SinceWhenOpenFailure(this.cause);

  final Exception cause;

  @override
  String toString() => 'SinceWhenOpenFailure: $cause';
}
