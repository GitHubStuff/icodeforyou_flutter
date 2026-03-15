# Widgetbook Directory Cookbook

## When to use this

After running `melos build`, the generated `main.directories.g.dart` will be alphabetically sorted and unstructured. Use this process to produce the hand-maintained `main.directories.dart` with correct package order and structure.

## Step 1 — run build_runner

```zsh
cd programs/widgetbook_workspace
dart run build_runner build --delete-conflicting-outputs
```

## Step 2 — send to Claude

Upload or paste `lib/main.directories.g.dart` to Claude with this exact prompt:

---

Apply the widgetbook directory ordering to this new `main.directories.g.dart` and produce a new `main.directories.dart`. Use the existing package order and structure from our previous session. Give me the file for download.

---

## Step 3 — replace the file

Copy the downloaded `main.directories.dart` to:

```
programs/widgetbook_workspace/lib/main.directories.dart
```

## Step 4 — update main.dart import

Ensure `lib/main.dart` imports the hand-maintained file, not the generated one:

```dart
import 'package:widgetbook_workspace/main.directories.dart';
```

Not:

```dart
import 'package:widgetbook_workspace/main.directories.g.dart';
```

## Package order

1. adaptive_modal
2. analog_clock_widget
3. animated_widgets
4. edittext_popover
5. random_color_generator
6. scrolling_datetime_pickers
7. settings_widget
8. since_when_widgets
9. sqlite_viewer
10. step_slider_package
11. tag_chip

## Notes

- Never edit `main.directories.g.dart` — it is always overwritten by build_runner
- `main.directories.dart` is the source of truth for ordering
- Use cases within each component are ordered: Default first, then feature-specific, then edge cases (RTL, Truncation etc)
