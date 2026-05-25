// edittext_popover/lib/src/editor_cubit.dart
import 'package:edittext_popover/src/session/editor_state.dart'
    show EditorState;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages editor overlay state via a [Cubit].
///
/// Tracks current text, line count, and character count.
/// Line counting rules: empty → 0, first character → line 1,
/// each `\n` adds one additional line.
class EditorScreenCubit extends Cubit<EditorState> {
  /// Creates an [EditorScreenCubit] seeded with [initialText].
  EditorScreenCubit({required String initialText})
    : super(EditorState.initial(initialText));

  /// Updates state with [text] and recalculates line and character counts.
  void updateText(String text) {
    emit(
      state.copyWith(
        text: text,
        lineCount: _calculateLineCount(text),
        characterCount: text.length,
      ),
    );
  }

  /// Returns the number of lines in [text].
  ///
  /// Empty string returns 0; otherwise 1 plus the number of `\n` characters.
  int _calculateLineCount(String text) {
    if (text.isEmpty) return 0;
    return 1 + '\n'.allMatches(text).length;
  }
}
