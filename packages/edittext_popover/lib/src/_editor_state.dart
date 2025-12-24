// lib/src/_editor_state.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';

/// Immutable state class for EditorScreenCubit.
/// Holds current text, line count, and character count.
/// Provides factory constructor for initial state and copyWith for updates.

@immutable
final class EditorState {
  const EditorState({
    required this.text,
    required this.lineCount,
    required this.characterCount,
  });

  factory EditorState.initial(String initialText) {
    return EditorState(
      text: initialText,
      lineCount: _calculateLineCount(initialText),
      characterCount: initialText.length,
    );
  }

  final String text;
  final int lineCount;
  final int characterCount;

  EditorState copyWith({String? text, int? lineCount, int? characterCount}) {
    return EditorState(
      text: text ?? this.text,
      lineCount: lineCount ?? this.lineCount,
      characterCount: characterCount ?? this.characterCount,
    );
  }

  /// Calculates line count based on rules:
  /// - First line needs at least 1 character to count
  /// - Each \n adds a line
  static int _calculateLineCount(String text) {
    if (text.isEmpty) {
      return 0;
    }

    final newlineCount = '\n'.allMatches(text).length;
    return 1 + newlineCount;
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
