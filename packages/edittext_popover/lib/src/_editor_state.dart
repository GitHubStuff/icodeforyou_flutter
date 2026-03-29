// edittext_popover/lib/src/_editor_state.dart
// ignore_for_file: lines_longer_than_80_chars
import 'package:edittext_popover/src/_editor_cubit.dart' show EditorScreenCubit;
import 'package:flutter/foundation.dart';

/// Immutable state for [EditorScreenCubit].
@immutable
final class EditorState {
  /// Creates an [EditorState] with the given [text], [lineCount],
  /// and [characterCount].
  const EditorState({
    required this.text,
    required this.lineCount,
    required this.characterCount,
  });

  /// Creates the initial [EditorState] derived from [initialText].
  factory EditorState.initial(String initialText) {
    return EditorState(
      text: initialText,
      lineCount: _calculateLineCount(initialText),
      characterCount: initialText.length,
    );
  }

  /// The current editor text.
  final String text;

  /// The number of lines in [text].
  final int lineCount;

  /// The number of characters in [text].
  final int characterCount;

  /// Returns a copy of this state with the given fields replaced.
  EditorState copyWith({
    String? text,
    int? lineCount,
    int? characterCount,
  }) {
    return EditorState(
      text: text ?? this.text,
      lineCount: lineCount ?? this.lineCount,
      characterCount: characterCount ?? this.characterCount,
    );
  }

  /// Calculates line count from [text].
  ///
  /// An empty string yields 0. Otherwise the count is 1 plus the
  /// number of newline characters present.
  static int _calculateLineCount(String text) {
    if (text.isEmpty) return 0;
    return 1 + '\n'.allMatches(text).length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorState &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          lineCount == other.lineCount &&
          characterCount == other.characterCount;

  @override
  int get hashCode => Object.hash(text, lineCount, characterCount);

  @override
  String toString() =>
      'EditorState(text: $text, lineCount: $lineCount, characterCount: $characterCount)';
}
