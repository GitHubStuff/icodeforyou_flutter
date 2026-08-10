// packages/ice_chips/test/src/tags/tags_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either, Unit, unit;
import 'package:ice_chips/src/glossary_types_todo.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        RecordTagDefinition,
        SinceWhenFailure;
import 'package:ice_chips/src/tags/tags_cubit.dart' show TagsCubit;
import 'package:ice_chips/src/tags/tags_state.dart'
    show TagsError, TagsInitial, TagsLoaded, TagsLoading;
import 'package:since_when_framework/database.dart' show DatabaseOpenFailure;

/// Reader returning a canned result.
final class _FakeReader implements GlossaryReader {
  /// Creates a reader that resolves to [result].
  _FakeReader(this.result);

  /// Canned result returned by [fetchAllTagDefinitions].
  final Either<SinceWhenFailure, List<RecordTagDefinition>> result;

  @override
  Future<Either<SinceWhenFailure, List<RecordTagDefinition>>>
  fetchAllTagDefinitions() async => result;
}

/// Repository returning a canned insert result and recording its input.
final class _FakeRepository implements GlossaryRepository {
  /// Creates a repository that resolves to [result].
  _FakeRepository(this.result);

  /// Canned result returned by [insertTagDefinition].
  final Either<SinceWhenFailure, RecordTagDefinition> result;

  /// Last `tagName` received, for interaction assertions.
  String? lastTagName;

  /// Last `color` received, for interaction assertions.
  int? lastColor;

  @override
  Future<Either<SinceWhenFailure, RecordTagDefinition>> insertTagDefinition({
    required String tagName,
    required int color,
  }) async {
    lastTagName = tagName;
    lastColor = color;
    return result;
  }
}

/// Writer returning a canned update result and recording its input.
final class _FakeWriter implements GlossaryWriter {
  /// Creates a writer that resolves to [result].
  _FakeWriter(this.result);

  /// Canned result returned by [updateTagDefinition].
  final Either<SinceWhenFailure, Unit> result;

  /// Last record received, for interaction assertions.
  RecordTagDefinition? lastRecord;

  @override
  Future<Either<SinceWhenFailure, Unit>> updateTagDefinition(
    RecordTagDefinition record,
  ) async {
    lastRecord = record;
    return result;
  }
}

/// Deleter returning a canned delete result and recording its input.
final class _FakeDeleter implements GlossaryDeleter {
  /// Creates a deleter that resolves to [result].
  _FakeDeleter(this.result);

  /// Canned result returned by [deleteTagDefinition].
  final Either<SinceWhenFailure, Unit> result;

  /// Last id received, for interaction assertions.
  int? lastId;

  @override
  Future<Either<SinceWhenFailure, Unit>> deleteTagDefinition(int id) async {
    lastId = id;
    return result;
  }
}

/// Persisted tag used across the success-path tests.
const _kTag = RecordTagDefinition(
  id: 1,
  createdTimeStamp: 1000,
  tagName: 'ALPHA',
  color: 0xFF112233,
);

void main() {
  const failure = SinceWhenFailure(DatabaseOpenFailure('boom'));

  group('TagsCubit', () {
    test('starts in TagsInitial', () {
      final cubit = TagsCubit(reader: _FakeReader(Either.right(const [])));
      addTearDown(cubit.close);
      expect(cubit.state, const TagsInitial());
    });

    group('load', () {
      test('emits Loading then Loaded on success', () async {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [_kTag])),
        );
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(const [
            TagsLoading(),
            TagsLoaded([_kTag]),
          ]),
        );

        await cubit.load();
        await expectation;
      });

      test('emits Loading then Error on failure', () async {
        final cubit = TagsCubit(reader: _FakeReader(Either.left(failure)));
        addTearDown(cubit.close);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder(const [
            TagsLoading(),
            TagsError(failure),
          ]),
        );

        await cubit.load();
        await expectation;
      });
    });

    group('add', () {
      test('inserts then reloads on success', () async {
        final repository = _FakeRepository(Either.right(_kTag));
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [_kTag])),
          repository: repository,
        );
        addTearDown(cubit.close);

        await cubit.add(tagName: 'ALPHA', color: 0xFF112233);

        expect(repository.lastTagName, 'ALPHA');
        expect(repository.lastColor, 0xFF112233);
        expect(cubit.state, const TagsLoaded([_kTag]));
      });

      test('emits TagsError on insert failure without reloading', () async {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [_kTag])),
          repository: _FakeRepository(Either.left(failure)),
        );
        addTearDown(cubit.close);

        await cubit.add(tagName: 'ALPHA', color: 0xFF112233);

        expect(cubit.state, const TagsError(failure));
      });

      test('throws StateError on a read-only cubit', () {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [])),
        );
        addTearDown(cubit.close);

        expect(
          () => cubit.add(tagName: 'ALPHA', color: 0),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('add'),
            ),
          ),
        );
      });
    });

    group('update', () {
      test('writes then reloads on success', () async {
        final writer = _FakeWriter(Either.right(unit));
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [_kTag])),
          writer: writer,
        );
        addTearDown(cubit.close);

        await cubit.update(_kTag);

        expect(writer.lastRecord, _kTag);
        expect(cubit.state, const TagsLoaded([_kTag]));
      });

      test('emits TagsError on update failure', () async {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [_kTag])),
          writer: _FakeWriter(Either.left(failure)),
        );
        addTearDown(cubit.close);

        await cubit.update(_kTag);

        expect(cubit.state, const TagsError(failure));
      });

      test('throws StateError on a read-only cubit', () {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [])),
        );
        addTearDown(cubit.close);

        expect(
          () => cubit.update(_kTag),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('update'),
            ),
          ),
        );
      });
    });

    group('remove', () {
      test('deletes then reloads on success', () async {
        final deleter = _FakeDeleter(Either.right(unit));
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [])),
          deleter: deleter,
        );
        addTearDown(cubit.close);

        await cubit.remove(1);

        expect(deleter.lastId, 1);
        expect(cubit.state, const TagsLoaded([]));
      });

      test('emits TagsError on delete failure', () async {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [])),
          deleter: _FakeDeleter(Either.left(failure)),
        );
        addTearDown(cubit.close);

        await cubit.remove(1);

        expect(cubit.state, const TagsError(failure));
      });

      test('throws StateError on a read-only cubit', () {
        final cubit = TagsCubit(
          reader: _FakeReader(Either.right(const [])),
        );
        addTearDown(cubit.close);

        expect(
          () => cubit.remove(1),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('remove'),
            ),
          ),
        );
      });
    });
  });
}
