// since_when_widgets/lib/src/tag_glossary_read/tag_glossary_read_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart' show GlossaryReader;
import 'package:since_when_widgets/src/tag_glossary_read/tag_glossary_read_state.dart';

/// Drives the read-tags flow.
///
/// Calls [GlossaryReader.fetchAllTagDefinitions] on [load] and emits
/// [TagGlossaryReadLoaded] / [TagGlossaryReadEmpty] / [TagGlossaryReadError]
/// accordingly.
///
/// Depends on [GlossaryReader] (not the concrete database) so the cubit
/// can be unit-tested against a fake without touching SQLite.
class TagGlossaryReadCubit extends Cubit<TagGlossaryReadState> {
  /// Creates the cubit. Call [load] to populate.
  TagGlossaryReadCubit(this._reader) : super(const TagGlossaryReadLoading());

  final GlossaryReader _reader;

  /// Fetches the glossary and emits the matching state.
  ///
  /// Re-emits [TagGlossaryReadLoading] before the fetch so consumers can
  /// drive a refresh without manual state shuffling.
  Future<void> load() async {
    emit(const TagGlossaryReadLoading());
    final result = await _reader.fetchAllTagDefinitions();
    result.match(
      (failure) => emit(TagGlossaryReadError(failure)),
      (records) => emit(
        records.isEmpty
            ? const TagGlossaryReadEmpty()
            : TagGlossaryReadLoaded(records),
      ),
    );
  }
}
