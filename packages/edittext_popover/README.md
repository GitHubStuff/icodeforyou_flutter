# edittext_popover

A cross-platform text editor overlay widget with line/character counting and automatic theme support.

## Features

- Full-screen popover on phones
- Positioned popup on tablets, Mac, and Web
- Real-time line and character counting
- Automatic dark/light theme support via `ColorScheme`
- Uses `\n` for newlines (database-friendly)
- Non-dismissible barrier (must use Save or Cancel)

## Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  edittext_popover:
    path: ../edittext_popover  # or your path
```

## Usage

### EditorTextField (convenience widget)
```dart
final controller = TextEditingController();

EditorTextField(
  controller: controller,
  decoration: const InputDecoration(
    labelText: 'Notes',
    border: OutlineInputBorder(),
  ),
  onResult: (result) {
    switch (result) {
      case EditorCompleted(:final text):
        print('Saved: $text');
      case EditorDismissed(:final text):
        print('Cancelled with: $text');
    }
  },
)
```

### showEditor (direct invocation)
```dart
final result = await showEditor(
  context: context,
  initialText: 'Hello\nWorld',
);

switch (result) {
  case EditorCompleted(:final text):
    // User tapped Save
  case EditorDismissed(:final text):
    // User tapped Cancel
}
```

## API Reference

### showEditor

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| context | `BuildContext` | required | Build context for navigation |
| initialText | `String` | `''` | Initial text content |
| textStyle | `TextStyle?` | SF 18pt | Text field style |
| barrierColor | `Color?` | black 40% | Overlay background |
| saveWidget | `Widget?` | `Text('SAVE')` | Save button content |
| cancelWidget | `Widget?` | `Text('CANCEL')` | Cancel button content |
| targetRect | `Rect?` | `null` | Position anchor for desktop/tablet |

### EditorTextField

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| controller | `TextEditingController` | required | Text controller |
| decoration | `InputDecoration?` | `null` | TextField decoration |
| style | `TextStyle?` | `null` | TextField style |
| editorTextStyle | `TextStyle?` | SF 18pt | Editor text style |
| editorBarrierColor | `Color?` | black 40% | Editor barrier color |
| editorSaveWidget | `Widget?` | `Text('SAVE')` | Save button content |
| editorCancelWidget | `Widget?` | `Text('CANCEL')` | Cancel button content |
| onResult | `void Function(EditorResult)?` | `null` | Result callback |

### EditorResult

Sealed class with two variants:
```dart
sealed class EditorResult {
  final String text;
}

final class EditorCompleted extends EditorResult {}
final class EditorDismissed extends EditorResult {}
```

## Platform Behavior

| Platform | Behavior |
|----------|----------|
| Phone (iOS/Android) | Full-screen overlay below safe area |
| Tablet | Positioned popup near target field |
| Mac | Positioned popup near target field |
| Web (narrow) | Full-screen overlay |
| Web (wide) | Positioned popup near target field |

## Newline Handling

- Uses `\n` for newlines (SQLite/database friendly)
- Line count displays actual lines (wraps don't count)
- Character count includes `\n` characters

## License

MIT
