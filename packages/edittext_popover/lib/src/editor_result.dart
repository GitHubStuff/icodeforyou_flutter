// lib/src/editor_result.dart
import 'package:flutter/foundation.dart';

/// Sealed class representing the result of an editor session.
///
/// Use pattern matching to handle the result:
/// ```dart
/// final result = await showEditor(context: context);
/// switch (result) {
///   case EditorCompleted(:final text):
///     // User saved
///   case EditorDismissed(:final text):
///     // User cancelled
/// }
/// ```
@immutable
sealed class EditorResult {
  const EditorResult({required this.text});

  /// The text content at the time of closing.
  final String text;
}

/// User completed editing by tapping Save.
@immutable
final class EditorCompleted extends EditorResult {
  const EditorCompleted({required super.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorCompleted &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'EditorCompleted(text: $text)';
}

/// User dismissed editing by tapping Cancel.
@immutable
final class EditorDismissed extends EditorResult {
  const EditorDismissed({required super.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorDismissed &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'EditorDismissed(text: $text)';
}
