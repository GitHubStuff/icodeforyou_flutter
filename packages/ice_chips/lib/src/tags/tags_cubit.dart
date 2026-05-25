// packages/ice_chips/lib/src/tags/tags_cubit.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/src/glossary_types_todo.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        RecordTagDefinition;
import 'package:ice_chips/src/tags/tags_state.dart'
    show TagsError, TagsInitial, TagsLoaded, TagsLoading, TagsState;

/// Wraps the glossary CRUD operations into observable Cubit state.
///
/// Holds the loaded list of [RecordTagDefinition]s as [TagsLoaded] state;
/// surfaces failures as [TagsError] with the typed `SinceWhenFailure`
/// preserved for pattern-matching.
///
/// Mutations ([add], [update], [remove]) reload the list on success and
/// emit [TagsError] on failure. The reload-after-mutate pattern keeps
/// the Cubit's view aligned with the database's truth without requiring
/// in-memory diff logic.
///
/// Depends on the four narrow role-segregated interfaces — [GlossaryReader],
/// [GlossaryRepository], [GlossaryWriter], [GlossaryDeleter] — rather than
/// a single god-object. Tests substitute fakes per role; consumers that
/// only need to read pass `null` for the write/delete interfaces (the
/// cubit raises on attempted use, see [add]/[update]/[remove]).
class TagsCubit extends Cubit<TagsState> {
  TagsCubit({
    required GlossaryReader reader,
    GlossaryRepository? repository,
    GlossaryWriter? writer,
    GlossaryDeleter? deleter,
  }) : _reader = reader,
       _repository = repository,
       _writer = writer,
       _deleter = deleter,
       super(const TagsInitial());

  final GlossaryReader _reader;
  final GlossaryRepository? _repository;
  final GlossaryWriter? _writer;
  final GlossaryDeleter? _deleter;

  /// Fetch the full list of tag definitions from the database.
  Future<void> load() async {
    emit(const TagsLoading());
    final result = await _reader.fetchAllTagDefinitions();
    result.match(
      (failure) => emit(TagsError(failure)),
      (tags) => emit(TagsLoaded(tags)),
    );
  }

  /// Insert a new tag definition with [tagName] and [color], then
  /// reload the list. Emits [TagsError] on insert failure.
  ///
  /// Requires a [GlossaryRepository] passed at construction; throws
  /// [StateError] if called on a read-only cubit.
  Future<void> add({required String tagName, required int color}) async {
    final repository = _requireRepository('add');
    final result = await repository.insertTagDefinition(
      tagName: tagName,
      color: color,
    );
    await result.match(
      (failure) async => emit(TagsError(failure)),
      (_) async => load(),
    );
  }

  /// Update an existing [tag], then reload the list. Emits [TagsError]
  /// on update failure.
  ///
  /// Requires a [GlossaryWriter] passed at construction; throws
  /// [StateError] if called on a read-only cubit.
  Future<void> update(RecordTagDefinition tag) async {
    final writer = _requireWriter('update');
    final result = await writer.updateTagDefinition(tag);
    await result.match(
      (failure) async => emit(TagsError(failure)),
      (_) async => load(),
    );
  }

  /// Delete the tag definition with the given [id], then reload the
  /// list. Emits [TagsError] on delete failure.
  ///
  /// Requires a [GlossaryDeleter] passed at construction; throws
  /// [StateError] if called on a read-only cubit.
  Future<void> remove(int id) async {
    final deleter = _requireDeleter('remove');
    final result = await deleter.deleteTagDefinition(id);
    await result.match(
      (failure) async => emit(TagsError(failure)),
      (_) async => load(),
    );
  }

  GlossaryRepository _requireRepository(String method) {
    final repository = _repository;
    if (repository == null) {
      throw StateError(
        'TagsCubit.$method called but no GlossaryRepository was supplied '
        'at construction. Pass a repository to enable insertions.',
      );
    }
    return repository;
  }

  GlossaryWriter _requireWriter(String method) {
    final writer = _writer;
    if (writer == null) {
      throw StateError(
        'TagsCubit.$method called but no GlossaryWriter was supplied at '
        'construction. Pass a writer to enable updates.',
      );
    }
    return writer;
  }

  GlossaryDeleter _requireDeleter(String method) {
    final deleter = _deleter;
    if (deleter == null) {
      throw StateError(
        'TagsCubit.$method called but no GlossaryDeleter was supplied at '
        'construction. Pass a deleter to enable removals.',
      );
    }
    return deleter;
  }
}
