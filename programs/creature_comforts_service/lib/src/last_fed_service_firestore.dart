// packages/creature_comforts_service/lib/src/last_fed_service_firestore.dart
// ignore_for_file: document_ignores, always_use_package_imports

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

import 'failures/last_fed_failure.dart';
import 'last_fed_service.dart';

/// Maps any thrown object into a [LastFedFailure].
///
/// Exposed as a typedef so tests can inject a fake Firestore that throws,
/// and verify the resulting failure mapping without needing the Firebase
/// emulator. Production code uses [defaultErrorMapper].
typedef LastFedErrorMapper = LastFedFailure Function(Object error);

/// Default mapping: [FirebaseException] -> [LastFedRemoteFailure] with code,
/// any other [Object] -> [LastFedRemoteFailure] with stringified cause.
LastFedFailure defaultErrorMapper(Object error) {
  if (error is FirebaseException) {
    return LastFedRemoteFailure(
      message: '[${error.code}] ${error.message ?? 'Firestore error'}',
      cause: error,
    );
  }
  return LastFedRemoteFailure(message: error.toString(), cause: error);
}

/// Firestore-backed implementation of [LastFedService].
///
/// Reads and writes the single document at `shared/last_fed`, where the
/// `occurred_at` field stores milliseconds since epoch (UTC) as an integer.
///
/// All thrown objects are caught and converted to [LastFedFailure] via the
/// injected [LastFedErrorMapper]; no exceptions escape the public surface.
final class LastFedServiceFirestore implements LastFedService {
  /// Creates a Firestore-backed [LastFedService].
  ///
  /// [firestore] and [auth] default to the global singletons; tests inject
  /// `FakeFirebaseFirestore` and `MockFirebaseAuth` instances.
  ///
  /// [now] is the time source used by [update] when no timestamp is supplied;
  /// override in tests for deterministic writes.
  ///
  /// [errorMapper] converts any thrown object into a [LastFedFailure];
  /// override in tests to verify error-path behavior.
  LastFedServiceFirestore({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DateTime Function()? now,
    LastFedErrorMapper? errorMapper,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _now = now ?? _defaultNow,
        _mapError = errorMapper ?? defaultErrorMapper;

  static const String _collection = 'shared';
  static const String _docId = 'last_fed';
  static const String _field = 'occurred_at';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DateTime Function() _now;
  final LastFedErrorMapper _mapError;

  static DateTime _defaultNow() => DateTime.now().toUtc();

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(_collection).doc(_docId);

  @override
  Future<Either<LastFedFailure, DateTime>> read() async {
    final authFailure = _requireAuth();
    if (authFailure != null) return left(authFailure);

    try {
      final snap = await _doc.get();
      return _decode(snap);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Stream<Either<LastFedFailure, DateTime>> watch() {
    final authFailure = _requireAuth();
    if (authFailure != null) {
      return Stream<Either<LastFedFailure, DateTime>>.value(left(authFailure));
    }

    // `Stream.handleError` returns void from its callback — it cannot transform
    // an error into a data event. To surface stream errors as `Left` values
    // for the listener, use `StreamTransformer.fromHandlers` and push the
    // mapped failure into the sink.
    final transformer = StreamTransformer<
        Either<LastFedFailure, DateTime>,
        Either<LastFedFailure, DateTime>>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        sink.add(left(_mapError(error)));
      },
    );

    return _doc.snapshots().map(_decode).transform(transformer);
  }

  @override
  Future<Either<LastFedFailure, Unit>> update({DateTime? occurredAt}) async {
    final authFailure = _requireAuth();
    if (authFailure != null) return left(authFailure);

    final ms = (occurredAt ?? _now()).toUtc().millisecondsSinceEpoch;

    try {
      await _doc.set(<String, Object?>{_field: ms}, SetOptions(merge: true));
      return right(unit);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      return left(_mapError(e));
    }
  }

  LastFedFailure? _requireAuth() =>
      _auth.currentUser == null ? const LastFedUnauthenticated() : null;

  Either<LastFedFailure, DateTime> _decode(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    if (!snap.exists) return left(const LastFedDocumentMissing());

    final data = snap.data();
    if (data == null || !data.containsKey(_field)) {
      return left(const LastFedDocumentMissing());
    }

    final raw = data[_field];
    if (raw is! int) {
      return left(
        LastFedDecodeFailure(
          message:
              'Field "$_field" must be int, got ${raw.runtimeType}: $raw',
        ),
      );
    }

    return right(DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true));
  }

  /// Exposed for tests verifying the document path; not part of the public
  /// API consumed by programs.
  @visibleForTesting
  String get debugDocumentPath => _doc.path;
}
