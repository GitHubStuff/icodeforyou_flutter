// since_when_widgets/lib/src/tag_glossary_read/tag_glossary_read_state.dart

import 'package:equatable/equatable.dart';
import 'package:ice_chips/ice_chips.dart'
    show RecordTagDefinition, SinceWhenFailure;

/// State for the read-tags flow.
///
/// Sealed so the UI exhaustively handles every case. `Loaded` and
/// `Empty` are split so the rendering widget never has to inspect the
/// list to decide which view to show — the state itself is the answer.
sealed class TagGlossaryReadState extends Equatable {
  /// Const base constructor for sealed subclasses.
  const TagGlossaryReadState();

  @override
  List<Object?> get props => const [];
}

/// Initial fetch in flight.
final class TagGlossaryReadLoading extends TagGlossaryReadState {
  /// Creates the loading sentinel.
  const TagGlossaryReadLoading();
}

/// Fetch succeeded; glossary contains at least one tag.
final class TagGlossaryReadLoaded extends TagGlossaryReadState {
  /// Creates a loaded snapshot with the [records] returned by the reader.
  const TagGlossaryReadLoaded(this.records);

  /// Tag definitions in the order returned by the reader.
  final List<RecordTagDefinition> records;

  @override
  List<Object?> get props => [records];
}

/// Fetch succeeded; glossary is empty.
final class TagGlossaryReadEmpty extends TagGlossaryReadState {
  /// Creates the empty-glossary sentinel.
  const TagGlossaryReadEmpty();
}

/// Fetch failed; carries the typed failure for pattern-matching.
final class TagGlossaryReadError extends TagGlossaryReadState {
  /// Creates an error snapshot wrapping the typed [failure].
  const TagGlossaryReadError(this.failure);

  /// The typed failure returned by the underlying reader.
  final SinceWhenFailure failure;

  @override
  List<Object?> get props => [failure];
}
