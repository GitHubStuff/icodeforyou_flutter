// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the set of currently-selected chip ids in an [IceChipsTray].
///
/// Holds a `Set<int>` keyed on [IceChipData.id]. Pure UI state — no
/// knowledge of where the chip data comes from, no persistence, no
/// awareness of which chips currently exist.
///
/// Callers register one [IceChipsTrayCubit] per tray via `BlocProvider`
/// at the appropriate scope (typically per-screen). Multiple trays in
/// the same screen each get their own Cubit instance.
class IceChipsTrayCubit extends Cubit<Set<int>> {
  IceChipsTrayCubit([super.initial = const {}]);

  /// Toggle membership of [id] in the selection.
  ///
  /// Removes [id] if currently selected, adds it otherwise.
  void toggle(int id) {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    emit(next);
  }

  /// Replace the current selection with [ids].
  void selectAll(Iterable<int> ids) => emit(ids.toSet());

  /// Empty the selection — every chip becomes unselected.
  void clear() => emit(const {});

  /// `true` if [id] is currently selected.
  bool isSelected(int id) => state.contains(id);

  /// Number of currently-selected ids.
  int get count => state.length;
}
