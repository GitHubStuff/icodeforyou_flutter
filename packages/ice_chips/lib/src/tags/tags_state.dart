// packages/ice_chips/lib/src/tags/tags_state.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:equatable/equatable.dart' show Equatable;
import 'package:ice_chips/src/glossary_types_todo.dart'
    show RecordTagDefinition, SinceWhenFailure;

/// Sealed state hierarchy for [TagsCubit].
///
/// Four states cover the full lifecycle of loading and holding a list
/// of tag definitions from the `since_when_tag_glossary` table.
sealed class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => const [];
}

/// Pre-load state. The Cubit has been constructed but [TagsCubit.load]
/// has not yet been called.
class TagsInitial extends TagsState {
  const TagsInitial();
}

/// A load operation is in flight.
class TagsLoading extends TagsState {
  const TagsLoading();
}

/// Tags have been loaded successfully and are available for rendering.
class TagsLoaded extends TagsState {
  const TagsLoaded(this.tags);

  final List<RecordTagDefinition> tags;

  @override
  List<Object?> get props => [tags];
}

/// A read or write operation against the database failed. Carries the
/// typed [SinceWhenFailure] for callers to pattern-match on.
class TagsError extends TagsState {
  const TagsError(this.failure);

  final SinceWhenFailure failure;

  @override
  List<Object?> get props => [failure];
}
