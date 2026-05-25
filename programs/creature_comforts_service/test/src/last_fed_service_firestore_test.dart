// packages/creature_comforts_service/test/src/last_fed_service_firestore_test.dart
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../lib/creature_comforts_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

const _docPath = 'shared/last_fed';
const _field = 'occurred_at';

FirebaseException _firebaseEx({
  String code = 'unavailable',
  String? message = 'transient',
}) =>
    FirebaseException(plugin: 'cloud_firestore', code: code, message: message);

// ============================================================================
// Mocks for the throwing-firestore scenarios.
//
// cloud_firestore 6.x marks Query / CollectionReference / DocumentReference as
// sealed, so we cannot `implements` them with a hand-rolled Fake.
// mocktail's Mock base sidesteps the analyzer restriction.
// ============================================================================

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {
}

class _FakeGetOptions extends Fake implements GetOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(SetOptions(merge: true));
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(_FakeGetOptions());
    registerFallbackValue(ListenSource.defaultSource);
  });

  group('defaultErrorMapper', () {
    test('maps FirebaseException to LastFedRemoteFailure with [code] prefix',
        () {
      final ex = _firebaseEx(code: 'permission-denied', message: 'nope');

      final result = defaultErrorMapper(ex);

      expect(result, isA<LastFedRemoteFailure>());
      expect(result.message, '[permission-denied] nope');
      expect(result.cause, same(ex));
    });

    test('uses default message when FirebaseException.message is null', () {
      final ex = _firebaseEx(code: 'unknown', message: null);

      final result = defaultErrorMapper(ex);

      expect(result.message, '[unknown] Firestore error');
    });

    test('maps any other Object to LastFedRemoteFailure with stringified cause',
        () {
      final ex = StateError('boom');

      final result = defaultErrorMapper(ex);

      expect(result, isA<LastFedRemoteFailure>());
      expect(result.message, ex.toString());
      expect(result.cause, same(ex));
    });
  });

  group('LastFedServiceFirestore', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth signedIn;
    late MockFirebaseAuth signedOut;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      signedIn = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-1', email: 'a@b.com'),
      );
      signedOut = MockFirebaseAuth();
    });

    LastFedServiceFirestore buildService({
      FirebaseFirestore? store,
      MockFirebaseAuth? auth,
      DateTime Function()? now,
      LastFedErrorMapper? errorMapper,
    }) {
      return LastFedServiceFirestore(
        firestore: store ?? firestore,
        auth: auth ?? signedIn,
        now: now,
        errorMapper: errorMapper,
      );
    }

    Future<void> seed(int ms) =>
        firestore.doc(_docPath).set(<String, Object?>{_field: ms});

    /// Returns a stream that emits [error] *after* a listener attaches.
    ///
    /// Using `Stream.error()` or `Future.error().asStream()` races against
    /// listener attachment — the error can fire before `.map().handleError()`
    /// is wired up, leaving the listener with nothing. A controller with
    /// `onListen` defers the error until the subscription is established.
    Stream<DocumentSnapshot<Map<String, dynamic>>> _errorStream(Object error) {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>();
      controller.onListen = () {
        controller.addError(error);
      };
      return controller.stream;
    }

    /// Builds a fully-stubbed mock firestore whose `shared/last_fed`
    /// document throws [error] on `get`, `set`, and `snapshots`.
    _MockFirestore buildThrowingFirestore(Object error) {
      final mockStore = _MockFirestore();
      final mockColl = _MockCollection();
      final mockDoc = _MockDoc();

      when(() => mockStore.collection(any())).thenReturn(mockColl);
      when(() => mockColl.doc(any())).thenReturn(mockDoc);
      when(() => mockDoc.path).thenReturn(_docPath);

      when(() => mockDoc.get(any())).thenThrow(error);
      when(() => mockDoc.get()).thenThrow(error);

      when(() => mockDoc.set(any(), any())).thenThrow(error);

      when(
        () => mockDoc.snapshots(
          includeMetadataChanges: any(named: 'includeMetadataChanges'),
          source: any(named: 'source'),
        ),
      ).thenAnswer((_) => _errorStream(error));
      when(() => mockDoc.snapshots()).thenAnswer((_) => _errorStream(error));

      return mockStore;
    }

    group('debugDocumentPath', () {
      test('points at shared/last_fed', () {
        expect(buildService().debugDocumentPath, _docPath);
      });
    });

    group('read', () {
      test('returns the stored timestamp as UTC DateTime', () async {
        const ms = 1735689600000;
        await seed(ms);

        final result = await buildService().read();

        expect(result.isRight(), isTrue);
        result.match(
          (_) => fail('expected Right'),
          (dt) {
            expect(dt.isUtc, isTrue);
            expect(dt.millisecondsSinceEpoch, ms);
          },
        );
      });

      test('returns LastFedUnauthenticated when no user is signed in',
          () async {
        await seed(0);

        final result = await buildService(auth: signedOut).read();

        expect(
          result,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedUnauthenticated>(),
          ),
        );
      });

      test('returns LastFedDocumentMissing when document does not exist',
          () async {
        final result = await buildService().read();

        expect(
          result,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedDocumentMissing>(),
          ),
        );
      });

      test('returns LastFedDocumentMissing when occurred_at field is absent',
          () async {
        await firestore
            .doc(_docPath)
            .set(<String, Object?>{'something_else': 1});

        final result = await buildService().read();

        expect(
          result,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedDocumentMissing>(),
          ),
        );
      });

      test('returns LastFedDecodeFailure when occurred_at is not an int',
          () async {
        await firestore
            .doc(_docPath)
            .set(<String, Object?>{_field: 'not-an-int'});

        final result = await buildService().read();

        expect(
          result,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedDecodeFailure>(),
          ),
        );
      });

      test('routes thrown errors through the injected mapper', () async {
        final throwing = buildThrowingFirestore(_firebaseEx());
        const sentinel = LastFedDecodeFailure(message: 'sentinel');

        final result = await buildService(
          store: throwing,
          errorMapper: (_) => sentinel,
        ).read();

        expect(
          result,
          isA<Left<LastFedFailure, DateTime>>()
              .having((l) => l.value, 'value', same(sentinel)),
        );
      });
    });

    group('update', () {
      test('writes the supplied timestamp as ms-since-epoch UTC', () async {
        final when = DateTime.utc(2025, 6, 15, 12, 30);

        final result = await buildService().update(occurredAt: when);

        expect(result.isRight(), isTrue);
        final snap = await firestore.doc(_docPath).get();
        expect(snap.data()?[_field], when.millisecondsSinceEpoch);
      });

      test('uses the injected now() when no timestamp is supplied', () async {
        final fixed = DateTime.utc(2030);

        final result = await buildService(now: () => fixed).update();

        expect(result.isRight(), isTrue);
        final snap = await firestore.doc(_docPath).get();
        expect(snap.data()?[_field], fixed.millisecondsSinceEpoch);
      });

      test('converts non-UTC timestamps to UTC before storing', () async {
        final local = DateTime(2025, 6, 15, 12, 30);

        final result = await buildService().update(occurredAt: local);

        expect(result.isRight(), isTrue);
        final snap = await firestore.doc(_docPath).get();
        expect(snap.data()?[_field], local.toUtc().millisecondsSinceEpoch);
      });

      test('merges into existing document without clobbering siblings',
          () async {
        await firestore.doc(_docPath).set(<String, Object?>{
          'sibling': 'preserved',
          _field: 0,
        });

        await buildService().update(occurredAt: DateTime.utc(2025));

        final snap = await firestore.doc(_docPath).get();
        expect(snap.data()?['sibling'], 'preserved');
        expect(
          snap.data()?[_field],
          DateTime.utc(2025).millisecondsSinceEpoch,
        );
      });

      test('returns LastFedUnauthenticated when no user is signed in',
          () async {
        final result = await buildService(auth: signedOut).update(
          occurredAt: DateTime.utc(2025),
        );

        expect(
          result,
          isA<Left<LastFedFailure, Unit>>().having(
            (l) => l.value,
            'value',
            isA<LastFedUnauthenticated>(),
          ),
        );

        final snap = await firestore.doc(_docPath).get();
        expect(snap.exists, isFalse);
      });

      test('routes thrown errors through the injected mapper', () async {
        final throwing = buildThrowingFirestore(_firebaseEx());
        const sentinel = LastFedDecodeFailure(message: 'sentinel-update');

        final result = await buildService(
          store: throwing,
          errorMapper: (_) => sentinel,
        ).update(occurredAt: DateTime.utc(2025));

        expect(
          result,
          isA<Left<LastFedFailure, Unit>>()
              .having((l) => l.value, 'value', same(sentinel)),
        );
      });
    });

    group('watch', () {
      test('emits Right(DateTime) for the seeded value, then for each update',
          () async {
        const initialMs = 1000;
        const updatedMs = 2000;
        await seed(initialMs);

        final service = buildService();
        final emitted = <Either<LastFedFailure, DateTime>>[];
        final sub = service.watch().listen(emitted.add);

        await pumpEventQueue();
        await firestore.doc(_docPath).set(<String, Object?>{_field: updatedMs});
        await pumpEventQueue();
        await sub.cancel();

        expect(emitted.length, greaterThanOrEqualTo(2));
        expect(
          emitted.first
              .getOrElse((_) => DateTime.fromMillisecondsSinceEpoch(0))
              .millisecondsSinceEpoch,
          initialMs,
        );
        expect(
          emitted.last
              .getOrElse((_) => DateTime.fromMillisecondsSinceEpoch(0))
              .millisecondsSinceEpoch,
          updatedMs,
        );
      });

      test('emits Left(LastFedDocumentMissing) when no document exists',
          () async {
        final service = buildService();
        final emitted = <Either<LastFedFailure, DateTime>>[];
        final sub = service.watch().listen(emitted.add);

        await pumpEventQueue();
        await sub.cancel();

        expect(emitted, isNotEmpty);
        expect(
          emitted.first,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedDocumentMissing>(),
          ),
        );
      });

      test('emits Left(LastFedDecodeFailure) when the field has the wrong type',
          () async {
        await firestore
            .doc(_docPath)
            .set(<String, Object?>{_field: 'wrong-type'});

        final service = buildService();
        final emitted = <Either<LastFedFailure, DateTime>>[];
        final sub = service.watch().listen(emitted.add);

        await pumpEventQueue();
        await sub.cancel();

        expect(
          emitted.first,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedDecodeFailure>(),
          ),
        );
      });

      test('emits a single Left(LastFedUnauthenticated) when not signed in',
          () async {
        final service = buildService(auth: signedOut);

        final emitted = <Either<LastFedFailure, DateTime>>[];
        final sub = service.watch().listen(emitted.add);

        await pumpEventQueue();
        await sub.cancel();

        expect(emitted.length, 1);
        expect(
          emitted.single,
          isA<Left<LastFedFailure, DateTime>>().having(
            (l) => l.value,
            'value',
            isA<LastFedUnauthenticated>(),
          ),
        );
      });

      test('routes stream errors through the injected mapper', () async {
        final throwing = buildThrowingFirestore(_firebaseEx());
        const sentinel = LastFedDecodeFailure(message: 'sentinel-stream');

        final service = buildService(
          store: throwing,
          errorMapper: (_) => sentinel,
        );

        final emitted = <Either<LastFedFailure, DateTime>>[];
        final sub = service.watch().listen(emitted.add);

        await pumpEventQueue();
        await sub.cancel();

        expect(emitted, isNotEmpty);
        expect(
          emitted.first,
          isA<Left<LastFedFailure, DateTime>>()
              .having((l) => l.value, 'value', same(sentinel)),
        );
      });
    });
  });
}
