// lib/src/_editor_cubit.dart
import 'package:edittext_popover/src/_editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State management for the editor overlay using flutter_bloc Cubit.
/// Tracks current text, line count, and character count.
/// Line counting rules: empty = 0, first char starts line 1, each \n adds a line.

class EditorScreenCubit extends Cubit<EditorState> {
  EditorScreenCubit({required String initialText})
    : super(EditorState.initial(initialText));

  void updateText(String text) {
    final lineCount = _calculateLineCount(text);
    final characterCount = text.length;

    emit(
      state.copyWith(
        text: text,
        lineCount: lineCount,
        characterCount: characterCount,
      ),
    );
  }

  int _calculateLineCount(String text) {
    if (text.isEmpty) {
      return 0;
    }

    final newlineCount = '\n'.allMatches(text).length;
    return 1 + newlineCount;
  }
}
