// packages/sincewhen_screens/test/src/cubit/cubit_test.dart

import 'dart:async';

import 'package:ext_datetime/ext_datetime.dart' show ExtDateTime;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show
        SinceWhenMiniAction,
        SinceWhenMiniCubit,
        SinceWhenMiniLoading,
        SinceWhenMiniReady;

class _TestBlocObserver extends BlocObserver {
  BlocBase<dynamic>? lastCreatedBloc;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    lastCreatedBloc = bloc;
  }
}

/// A test cubit that forces the state into [SinceWhenMiniLoading]
/// to verify branch coverage for loading guards.
class _LoadingSinceWhenMiniCubit extends SinceWhenMiniCubit {
  _LoadingSinceWhenMiniCubit()
    : super(
        item: const SinceWhenItem(
          id: 1,
          createdTimestamp: 1000,
          reviewedTimestamp: 2000,
          editedTimestamp: 3000,
          sequenceNumber: 0,
          content: 'test',
        ),
      ) {
    emit(const SinceWhenMiniLoading());
  }
}

void main() {
  group('SinceWhenMiniCubit', () {
    late DateTime fixedNow;
    late _TestBlocObserver observer;

    setUp(() {
      ExtDateTime.reset();
      fixedNow = DateTime.utc(2026, 1, 1, 12, 0, 0);
      observer = _TestBlocObserver();
      Bloc.observer = observer;
    });

    SinceWhenItem createTestItem({
      int id = 1,
      int created = 1000,
      int reviewed = 2000,
      int edited = 3000,
      int sequenceNumber = 0,
      String content = 'initial content',
      int? parentTimestamp,
      int? eventTimestamp = 4000,
      String? metaData = 'initial meta',
      String? tldr = 'initial tldr',
    }) {
      return SinceWhenItem(
        id: id,
        createdTimestamp: created,
        reviewedTimestamp: reviewed,
        editedTimestamp: edited,
        sequenceNumber: sequenceNumber,
        content: content,
        parentTimestamp: parentTimestamp,
        eventTimestamp: eventTimestamp,
        metaData: metaData,
        tldr: tldr,
      );
    }

    group('create mode & loading state', () {
      test(
        'initializes with item == null and mints draft into SinceWhenMiniReady',
        () async {
          final cubit = SinceWhenMiniCubit(
            item: null,
            now: () => fixedNow,
          );

          // _mintCreateDraft runs synchronously inside constructor
          expect(cubit.state, isA<SinceWhenMiniReady>());
          final ready = cubit.state as SinceWhenMiniReady;

          expect(ready.original, isNull);
          expect(ready.content, isEmpty);
          expect(ready.metaData, isEmpty);
          expect(ready.tldr, isEmpty);
          expect(ready.eventTimestamp, isNull);
          expect(
            ready.createdTimestamp,
            equals(fixedNow.microsecondsSinceEpoch),
          );
          expect(ready.reviewedTimestamp, equals(ready.createdTimestamp));
          expect(ready.editedTimestamp, equals(ready.createdTimestamp));

          await cubit.close();
        },
      );

      test('aborts _mintCreateDraft when cubit is closed before emit', () async {
        final cubit = SinceWhenMiniCubit(
          item: null,
          now: () {
            // Close the cubit captured by BlocObserver before _mintCreateDraft emits
            unawaited(observer.lastCreatedBloc?.close());
            return fixedNow;
          },
        );

        // State remains the initial SinceWhenMiniLoading and emit is aborted
        expect(cubit.state, isA<SinceWhenMiniLoading>());
        expect(cubit.isClosed, isTrue);

        await cubit.close();
      });

      test(
        'guards _mutate and complete() when state is SinceWhenMiniLoading',
        () async {
          final loadingCubit = _LoadingSinceWhenMiniCubit();

          expect(loadingCubit.state, isA<SinceWhenMiniLoading>());

          // Verify all _mutate methods ignore changes when not in SinceWhenMiniReady
          loadingCubit.contentChanged('ignored content');
          loadingCubit.metaDataChanged('ignored metadata');
          loadingCubit.tldrChanged('ignored tldr');
          loadingCubit.eventTimestampChanged(DateTime.utc(2026, 2, 1));
          loadingCubit.eventTimestampCleared();

          expect(loadingCubit.state, isA<SinceWhenMiniLoading>());

          // Verify complete() throws StateError when state is not SinceWhenMiniReady
          expect(
            loadingCubit.complete,
            throwsStateError,
          );

          await loadingCubit.close();
        },
      );
    });

    group('edit mode initialization', () {
      test(
        'starts synchronously in SinceWhenMiniReady with non-null values',
        () async {
          final item = createTestItem();
          final cubit = SinceWhenMiniCubit(
            item: item,
            now: () => fixedNow,
          );

          expect(cubit.state, isA<SinceWhenMiniReady>());
          final ready = cubit.state as SinceWhenMiniReady;

          expect(ready.original, item);
          expect(ready.createdTimestamp, item.createdTimestamp);
          expect(ready.reviewedTimestamp, item.reviewedTimestamp);
          expect(ready.editedTimestamp, item.editedTimestamp);
          expect(ready.content, item.content);
          expect(ready.metaData, item.metaData);
          expect(ready.tldr, item.tldr);
          expect(ready.eventTimestamp, item.eventTimestamp);

          await cubit.close();
        },
      );

      test(
        'falls back to empty strings when item metaData and tldr are null',
        () async {
          final item = createTestItem(
            metaData: null,
            tldr: null,
          );
          final cubit = SinceWhenMiniCubit(
            item: item,
            now: () => fixedNow,
          );

          final ready = cubit.state as SinceWhenMiniReady;
          expect(ready.metaData, '');
          expect(ready.tldr, '');

          await cubit.close();
        },
      );
    });

    group('mutations in ready state', () {
      test('updates content via contentChanged', () async {
        final cubit = SinceWhenMiniCubit(
          item: createTestItem(),
          now: () => fixedNow,
        );

        cubit.contentChanged('updated text');

        expect(
          (cubit.state as SinceWhenMiniReady).content,
          equals('updated text'),
        );
        await cubit.close();
      });

      test('updates metaData via metaDataChanged', () async {
        final cubit = SinceWhenMiniCubit(
          item: createTestItem(),
          now: () => fixedNow,
        );

        cubit.metaDataChanged('updated metadata');

        expect(
          (cubit.state as SinceWhenMiniReady).metaData,
          equals('updated metadata'),
        );
        await cubit.close();
      });

      test('updates tldr via tldrChanged', () async {
        final cubit = SinceWhenMiniCubit(
          item: createTestItem(),
          now: () => fixedNow,
        );

        cubit.tldrChanged('updated tldr');

        expect(
          (cubit.state as SinceWhenMiniReady).tldr,
          equals('updated tldr'),
        );
        await cubit.close();
      });

      test('updates eventTimestamp via eventTimestampChanged', () async {
        final cubit = SinceWhenMiniCubit(
          item: createTestItem(),
          now: () => fixedNow,
        );
        final date = DateTime.utc(2026, 6, 15, 10, 30);

        cubit.eventTimestampChanged(date);

        expect(
          (cubit.state as SinceWhenMiniReady).eventTimestamp,
          equals(date.microsecondsSinceEpoch),
        );
        await cubit.close();
      });

      test('clears eventTimestamp via eventTimestampCleared', () async {
        final cubit = SinceWhenMiniCubit(
          item: createTestItem(eventTimestamp: 99999),
          now: () => fixedNow,
        );

        cubit.eventTimestampCleared();

        expect(
          (cubit.state as SinceWhenMiniReady).eventTimestamp,
          isNull,
        );
        await cubit.close();
      });
    });

    group('complete()', () {
      test('returns item with pass-through stamps on submit action', () async {
        final cubit = SinceWhenMiniCubit(
          item: null,
          now: () => fixedNow,
        );

        final ready = cubit.state as SinceWhenMiniReady;
        expect(ready.primaryAction, SinceWhenMiniAction.submit);

        final result = await cubit.complete();

        expect(result.createdTimestamp, equals(ready.createdTimestamp));
        expect(result.reviewedTimestamp, equals(ready.reviewedTimestamp));
        expect(result.editedTimestamp, equals(ready.editedTimestamp));

        await cubit.close();
      });

      test(
        'returns item with newly minted reviewed and edited stamps on update action',
        () async {
          var clock = DateTime.utc(2026, 1, 1, 10, 0, 0);
          final item = createTestItem(
            content: 'old text',
            reviewed: 100,
            edited: 100,
          );

          final cubit = SinceWhenMiniCubit(
            item: item,
            now: () => clock,
          );

          cubit.contentChanged('brand new text');
          final ready = cubit.state as SinceWhenMiniReady;
          expect(ready.primaryAction, SinceWhenMiniAction.update);

          clock = DateTime.utc(2026, 1, 1, 12, 0, 0);
          final result = await cubit.complete();

          expect(result.createdTimestamp, equals(item.createdTimestamp));
          expect(result.content, equals('brand new text'));
          expect(result.reviewedTimestamp, equals(result.editedTimestamp));
          expect(result.reviewedTimestamp, isNot(equals(100)));

          await cubit.close();
        },
      );

      test(
        'returns item with freshly minted reviewed stamp only on reviewed action',
        () async {
          var clock = DateTime.utc(2026, 1, 1, 10, 0, 0);
          final item = createTestItem(
            reviewed: 500,
            edited: 500,
          );

          final cubit = SinceWhenMiniCubit(
            item: item,
            now: () => clock,
          );

          final ready = cubit.state as SinceWhenMiniReady;
          expect(ready.primaryAction, SinceWhenMiniAction.reviewed);

          clock = DateTime.utc(2026, 1, 1, 15, 0, 0);
          final result = await cubit.complete();

          expect(result.createdTimestamp, equals(item.createdTimestamp));
          expect(result.editedTimestamp, equals(item.editedTimestamp));
          expect(
            result.reviewedTimestamp,
            isNot(equals(item.reviewedTimestamp)),
          );

          await cubit.close();
        },
      );
    });
  });
}
