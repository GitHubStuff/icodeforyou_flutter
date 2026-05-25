// packages/creature_comforts_service/lib/src/last_fed_service.dart
import 'failures/last_fed_failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:service_locator/service_locator.dart';

/// Read and update the single shared "last fed" timestamp.
///
/// The backend stores one document at `shared/last_fed` with an integer
/// field `occurred_at` (milliseconds since epoch, UTC).
///
/// All operations return `Either<LastFedFailure, T>`; no exceptions escape
/// the implementation. Callers handle every failure case via exhaustive
/// `switch` on the sealed [LastFedFailure] hierarchy.
abstract interface class LastFedService implements ServiceClass {
  /// Reads the current timestamp once.
  ///
  /// Returns [LastFedUnauthenticated] if no user is signed in,
  /// [LastFedDocumentMissing] if the backend document is absent,
  /// [LastFedDecodeFailure] if `occurred_at` is not an integer, or
  /// [LastFedRemoteFailure] for any underlying Firestore error.
  Future<Either<LastFedFailure, DateTime>> read();

  /// Watches the timestamp, emitting on every remote change.
  ///
  /// The stream yields a `Right(DateTime)` for each successful snapshot and a
  /// `Left(LastFedFailure)` for any failure observed mid-stream. The stream
  /// stays open across failures so transient errors don't terminate the
  /// listener; cancel the subscription to stop watching.
  Stream<Either<LastFedFailure, DateTime>> watch();

  /// Writes [occurredAt] to the backend, replacing the previous value.
  ///
  /// Defaults to `DateTime.now().toUtc()` when omitted. Stored as
  /// milliseconds since epoch (UTC). Returns `Right(unit)` on success.
  Future<Either<LastFedFailure, Unit>> update({DateTime? occurredAt});
}
