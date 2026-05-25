// since_when_widgets/lib/src/tag_glossary_edit/tag_glossary_edit_cubit.dart

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        RecordTagDefinition,
        SinceWhenFailure;
import 'package:random_color_generator/random_color_generator.dart';
import 'package:since_when_widgets/src/tag_glossary_edit/tag_glossary_edit_state.dart';

/// Drives the edit-tag flow for Create, Update, and Delete.
///
/// Construction is mode-driven via the named constructors:
/// - [TagGlossaryEditCubit.create] — opens the editor blank. Save inserts.
///   Delete is a no-op (Create has nothing to remove).
/// - [TagGlossaryEditCubit.update] — opens the editor pre-populated with
///   an existing record. The record's color is excluded from the reroll
///   set MINUS its own value, so the user can keep their current color
///   across rerolls. Save updates. Delete removes the record.
///
/// Depends on the narrow [GlossaryRepository] (Create) and
/// [GlossaryReader] / [GlossaryWriter] / [GlossaryDeleter] (Update support)
/// so the cubit can be unit-tested against fakes without touching SQLite.
///
/// The Ready/Error states preserve the typed name and rolled color so
/// failures never lose user input. Tag names are upper-cased on entry,
/// in display, and on save.
class TagGlossaryEditCubit extends Cubit<TagGlossaryEditState> {
  /// Create-mode constructor.
  TagGlossaryEditCubit.create({
    required GlossaryRepository repository,
    required GlossaryReader reader,
  }) : this._(
         repository: repository,
         reader: reader,
         writer: null,
         deleter: null,
         mode: const TagGlossaryEditCreate(),
       );

  /// Update-mode constructor — Save updates, Delete deletes.
  TagGlossaryEditCubit.update({
    required GlossaryReader reader,
    required GlossaryWriter writer,
    required GlossaryDeleter deleter,
    required RecordTagDefinition existing,
  }) : this._(
         repository: null,
         reader: reader,
         writer: writer,
         deleter: deleter,
         mode: TagGlossaryEditUpdate(existing),
       );

  TagGlossaryEditCubit._({
    required GlossaryRepository? repository,
    required GlossaryReader reader,
    required GlossaryWriter? writer,
    required GlossaryDeleter? deleter,
    required this.mode,
  }) : _repository = repository,
       _reader = reader,
       _writer = writer,
       _deleter = deleter,
       super(const TagGlossaryEditLoading());

  static const int _maxRollAttempts = 20;

  /// Which flow this cubit is running.
  final TagGlossaryEditMode mode;

  final GlossaryRepository? _repository;
  final GlossaryReader _reader;
  final GlossaryWriter? _writer;
  final GlossaryDeleter? _deleter;

  /// Loads the glossary's color set and emits the initial Ready state.
  ///
  /// Create mode: name is empty and the rolled color is excluded against
  /// every glossary color. Update mode: name and color are pre-populated
  /// from the existing record, and the existing record's color is removed
  /// from the exclusion set (so consecutive rerolls don't lock the user
  /// out of the color they may want to keep).
  Future<void> init() async {
    emit(const TagGlossaryEditLoading());
    final fetchResult = await _reader.fetchAllTagDefinitions();
    fetchResult.match(
      (failure) => emit(_errorWithFreshDraft(failure)),
      _emitReady,
    );
  }

  /// Updates the name in the current Ready or Error state.
  ///
  /// The incoming [value] is uppercased before being stored.
  ///
  /// No-op in any non-editing state.
  void nameChanged(String value) {
    final upper = value.toUpperCase();
    final current = state;
    if (current is TagGlossaryEditReady) {
      if (current.name == upper) return;
      emit(current.copyWith(name: upper));
      return;
    }
    if (current is TagGlossaryEditError) {
      if (current.name == upper) return;
      emit(
        TagGlossaryEditReady(
          name: upper,
          color: current.color,
          excludedColors: current.excludedColors,
        ),
      );
    }
  }

  /// Rolls a new random color, excluding the editor's current exclusion
  /// set and the currently displayed color.
  ///
  /// No-op in any non-editing state.
  void rerollColor() {
    final current = state;
    if (current is TagGlossaryEditReady) {
      final next = _rollExcluding({
        ...current.excludedColors,
        current.color.toARGB32(),
      });
      emit(current.copyWith(color: next));
      return;
    }
    if (current is TagGlossaryEditError) {
      final next = _rollExcluding({
        ...current.excludedColors,
        current.color.toARGB32(),
      });
      emit(
        TagGlossaryEditReady(
          name: current.name,
          color: next,
          excludedColors: current.excludedColors,
        ),
      );
    }
  }

  /// Persists the current draft.
  ///
  /// Branches on [mode]: Create calls [GlossaryRepository.insertTagDefinition];
  /// Update calls [GlossaryWriter.updateTagDefinition] preserving the
  /// existing record's `id` and `createdTimeStamp`. On success, emits
  /// [TagGlossaryEditSaved]. On failure, emits [TagGlossaryEditError]
  /// with the user's input preserved.
  Future<void> save() async {
    final current = state;
    if (current is! TagGlossaryEditReady) return;
    if (!current.canSave) return;

    emit(TagGlossaryEditSaving(name: current.name, color: current.color));

    switch (mode) {
      case TagGlossaryEditCreate():
        await _saveCreate(current);
      case TagGlossaryEditUpdate(:final existing):
        await _saveUpdate(current, existing);
    }
  }

  /// Deletes the existing record (Update mode only — no-op in Create).
  ///
  /// Emits [TagGlossaryEditDeleting] then [TagGlossaryEditDeleted] on
  /// success, or [TagGlossaryEditError] preserving the draft on failure.
  ///
  /// No-op when called outside [TagGlossaryEditReady] (e.g. while saving)
  /// to prevent racing terminal transitions.
  Future<void> delete() async {
    final m = mode;
    if (m is! TagGlossaryEditUpdate) return;
    final current = state;
    if (current is! TagGlossaryEditReady) return;

    final id = m.existing.id;
    if (id == null) return; // Defensive — Update records always carry an id.

    emit(TagGlossaryEditDeleting(name: current.name, color: current.color));

    final result = await _deleter!.deleteTagDefinition(id);
    result.match(
      (failure) => emit(_errorFromDraft(failure, current)),
      (_) => emit(TagGlossaryEditDeleted(m.existing)),
    );
  }

  Future<void> _saveCreate(TagGlossaryEditReady draft) async {
    final result = await _repository!.insertTagDefinition(
      tagName: draft.name,
      color: draft.color.toARGB32(),
    );
    result.match(
      (failure) => emit(_errorFromDraft(failure, draft)),
      (record) => emit(TagGlossaryEditSaved(record)),
    );
  }

  Future<void> _saveUpdate(
    TagGlossaryEditReady draft,
    RecordTagDefinition existing,
  ) async {
    final updated = existing.copyWith(
      tagName: draft.name,
      color: draft.color.toARGB32(),
    );
    final result = await _writer!.updateTagDefinition(updated);
    result.match(
      (failure) => emit(_errorFromDraft(failure, draft)),
      (_) => emit(TagGlossaryEditSaved(updated)),
    );
  }

  /// Emits the appropriate Ready state for the configured mode given a
  /// successfully-fetched glossary list.
  void _emitReady(List<RecordTagDefinition> records) {
    switch (mode) {
      case TagGlossaryEditCreate():
        final excluded = {for (final r in records) r.color};
        emit(
          TagGlossaryEditReady(
            name: '',
            color: _rollExcluding(excluded),
            excludedColors: excluded,
          ),
        );
      case TagGlossaryEditUpdate(:final existing):
        final excluded = {
          for (final r in records)
            if (r.id != existing.id) r.color,
        };
        emit(
          TagGlossaryEditReady(
            name: existing.tagName,
            color: Color(existing.color),
            excludedColors: excluded,
          ),
        );
    }
  }

  /// Builds an Error state for an init-time failure, with a placeholder
  /// draft pre-populated from the mode (existing record for Update,
  /// blank for Create).
  TagGlossaryEditError _errorWithFreshDraft(SinceWhenFailure failure) {
    return switch (mode) {
      TagGlossaryEditCreate() => TagGlossaryEditError(
        failure: failure,
        name: '',
        color: RandomColorGenerator.generate(),
        excludedColors: const {},
      ),
      TagGlossaryEditUpdate(:final existing) => TagGlossaryEditError(
        failure: failure,
        name: existing.tagName,
        color: Color(existing.color),
        excludedColors: const {},
      ),
    };
  }

  /// Builds an Error state preserving an in-progress Ready draft.
  TagGlossaryEditError _errorFromDraft(
    SinceWhenFailure failure,
    TagGlossaryEditReady draft,
  ) => TagGlossaryEditError(
    failure: failure,
    name: draft.name,
    color: draft.color,
    excludedColors: draft.excludedColors,
  );

  /// Generates a random color whose ARGB32 value is not in [excluded].
  Color _rollExcluding(Set<int> excluded) {
    var rolled = RandomColorGenerator.generate();
    for (var i = 0; i < _maxRollAttempts; i++) {
      if (!excluded.contains(rolled.toARGB32())) return rolled;
      rolled = RandomColorGenerator.generate();
    }
    return rolled;
  }
}
