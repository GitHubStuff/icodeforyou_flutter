// since_when_widgets/lib/src/tag_glossary_edit/tag_glossary_edit_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:ice_chips/ice_chips.dart'
    show RecordTagDefinition, SinceWhenFailure;

/// Distinguishes the flows the editor handles.
///
/// The cubit branches on this in `init` (initial name + exclusion set),
/// `save` (insert vs update), and `delete` (Update only — no-op in Create).
/// The widget branches on it for affordances that differ between flows
/// (Delete button visibility, button labels, etc.).
sealed class TagGlossaryEditMode extends Equatable {
  /// Const base constructor for sealed subclasses.
  const TagGlossaryEditMode();

  @override
  List<Object?> get props => const [];
}

/// Editor opens blank to create a new tag.
final class TagGlossaryEditCreate extends TagGlossaryEditMode {
  /// Creates the Create-mode marker.
  const TagGlossaryEditCreate();
}

/// Editor opens pre-populated with [existing] to update or delete it.
final class TagGlossaryEditUpdate extends TagGlossaryEditMode {
  /// Creates the Update-mode marker carrying the record being edited.
  const TagGlossaryEditUpdate(this.existing);

  /// The record currently being edited.
  final RecordTagDefinition existing;

  @override
  List<Object?> get props => [existing];
}

/// State for the edit-tag flow.
///
/// Sealed so the UI exhaustively handles every case. The editing-bearing
/// states ([TagGlossaryEditReady], [TagGlossaryEditSaving],
/// [TagGlossaryEditDeleting], [TagGlossaryEditError]) preserve the typed
/// name and rolled color so the user never loses work across transitions.
sealed class TagGlossaryEditState extends Equatable {
  /// Const base constructor for sealed subclasses.
  const TagGlossaryEditState();

  @override
  List<Object?> get props => const [];
}

/// Initial state while the cubit loads the glossary's color set.
final class TagGlossaryEditLoading extends TagGlossaryEditState {
  /// Creates the loading sentinel.
  const TagGlossaryEditLoading();
}

/// Editor is interactive. The user can type, reroll, save, or delete.
final class TagGlossaryEditReady extends TagGlossaryEditState {
  /// Creates a ready snapshot of the editor.
  const TagGlossaryEditReady({
    required this.name,
    required this.color,
    required this.excludedColors,
  });

  /// Current text in the name field. Always upper-cased.
  final String name;

  /// Current rolled color, guaranteed not to be in [excludedColors].
  final Color color;

  /// Colors already taken by existing glossary entries other than the
  /// one being edited.
  final Set<int> excludedColors;

  /// True when [name] is non-empty and has no leading/trailing whitespace.
  ///
  /// Color uniqueness is enforced upstream by the reroll mechanism, so
  /// it is not part of [canSave].
  bool get canSave => name.isNotEmpty && name.trim() == name;

  /// Returns a copy with any provided fields replaced.
  TagGlossaryEditReady copyWith({
    String? name,
    Color? color,
    Set<int>? excludedColors,
  }) => TagGlossaryEditReady(
    name: name ?? this.name,
    color: color ?? this.color,
    excludedColors: excludedColors ?? this.excludedColors,
  );

  @override
  List<Object?> get props => [name, color, excludedColors];
}

/// Save in flight. The UI disables inputs while in this state.
final class TagGlossaryEditSaving extends TagGlossaryEditState {
  /// Creates a saving snapshot preserving the user's input.
  const TagGlossaryEditSaving({required this.name, required this.color});

  /// The name being persisted.
  final String name;

  /// The color being persisted.
  final Color color;

  @override
  List<Object?> get props => [name, color];
}

/// Terminal save success. Carries the persisted record.
final class TagGlossaryEditSaved extends TagGlossaryEditState {
  /// Creates the success terminal carrying the persisted [record].
  const TagGlossaryEditSaved(this.record);

  /// The record as it now exists in the glossary.
  final RecordTagDefinition record;

  @override
  List<Object?> get props => [record];
}

/// Delete in flight. The UI disables inputs while in this state.
final class TagGlossaryEditDeleting extends TagGlossaryEditState {
  /// Creates a deleting snapshot preserving the user's input.
  const TagGlossaryEditDeleting({required this.name, required this.color});

  /// The name displayed at the moment delete was requested.
  final String name;

  /// The color displayed at the moment delete was requested.
  final Color color;

  @override
  List<Object?> get props => [name, color];
}

/// Terminal delete success. Carries the record that was just deleted so
/// the host can show a confirmation, undo affordance, or refresh.
final class TagGlossaryEditDeleted extends TagGlossaryEditState {
  /// Creates the delete-success terminal carrying the [record] that was
  /// removed from the glossary.
  const TagGlossaryEditDeleted(this.record);

  /// The record as it existed immediately before deletion.
  final RecordTagDefinition record;

  @override
  List<Object?> get props => [record];
}

/// Save or delete failed. Preserves the user's input so they can retry
/// without retyping.
final class TagGlossaryEditError extends TagGlossaryEditState {
  /// Creates an error snapshot.
  const TagGlossaryEditError({
    required this.failure,
    required this.name,
    required this.color,
    required this.excludedColors,
  });

  /// The typed failure returned by the underlying interface.
  final SinceWhenFailure failure;

  /// The name that was being saved/deleted when the failure occurred.
  final String name;

  /// The color that was being saved/deleted when the failure occurred.
  final Color color;

  /// The exclusion set in effect at failure time.
  final Set<int> excludedColors;

  @override
  List<Object?> get props => [failure, name, color, excludedColors];
}
