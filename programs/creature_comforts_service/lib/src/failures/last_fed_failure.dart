// packages/creature_comforts_service/lib/src/failures/last_fed_failure.dart
import 'package:meta/meta.dart';

/// Failures returned from [LastFedService] operations.
///
/// Returned as the `Left` side of an `Either<LastFedFailure, T>` so callers
/// handle every case explicitly via exhaustive `switch`.
@immutable
sealed class LastFedFailure {
  const LastFedFailure({required this.message, this.cause});

  /// Human-readable description of the failure.
  final String message;

  /// Optional underlying error (e.g. a `FirebaseException`).
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// The caller is not authenticated.
///
/// Firestore security rules require `request.auth != null`; this is returned
/// before any network call when no user is signed in.
final class LastFedUnauthenticated extends LastFedFailure {
  const LastFedUnauthenticated()
      : super(message: 'No authenticated user.');
}

/// The remote document is missing or has no `occurred_at` field.
///
/// The seed document is created during backend setup; this failure indicates
/// the document was deleted or the schema drifted.
final class LastFedDocumentMissing extends LastFedFailure {
  const LastFedDocumentMissing()
      : super(message: 'shared/last_fed document not found.');
}

/// A Firestore call failed (network, permission, deadline, etc.).
final class LastFedRemoteFailure extends LastFedFailure {
  const LastFedRemoteFailure({
    required super.message,
    required Object super.cause,
  });
}

/// The stored `occurred_at` value is not a valid millisecond epoch integer.
final class LastFedDecodeFailure extends LastFedFailure {
  const LastFedDecodeFailure({required super.message, super.cause});
}
