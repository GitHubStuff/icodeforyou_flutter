<!-- packages/status_bar_visibility/README.md -->
<!-- Version: 1.0.0 StatusBarVisibility -->

# status_bar_visibility

A single entry point for showing and hiding the system status bar on
Android and iOS. It wraps the standalone `status_bar_android` and
`status_bar_ios` plugins behind one static facade and is a safe no-op on
every other platform.

## Features

- One call to hide or show the status bar on both mobile platforms.
- Edge-to-edge system UI mode applied on initialization.
- Platform dispatch via `platform_tools` (`OSPlatform.current`).
- Explicit `NotInitializedError` instead of silent misuse.
- Fully unit-testable: `reset()` and `OSPlatform.override` let tests
  exercise every branch without a device.

## Platform support

| Platform | Supported | `setVisibility` returns |
| -------- | --------- | ----------------------- |
| Android  | Yes       | `true`                  |
| iOS      | Yes       | `true`                  |
| Fuchsia  | No        | `false`                 |
| Linux    | No        | `false`                 |
| macOS    | No        | `false`                 |
| Web      | No        | `false`                 |
| Windows  | No        | `false`                 |

## Getting started

This package is a workspace member of the `icodeforyou_flutter`
monorepo (`publish_to: none`). Add it as a dependency:

```yaml
dependencies:
  status_bar_visibility: ^1.0.0
```

It depends on the following workspace packages:

- `custom_errors`
- `platform_tools`
- `status_bar_android`
- `status_bar_ios`

## Usage

Initialize once, before the first frame. `init` sets
`SystemUiMode.edgeToEdge` and applies the initial visibility
(`setHidden` defaults to `true`).

```dart
import 'package:flutter/widgets.dart';
import 'package:status_bar_visibility/status_bar_visibility.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StatusBarVisibility.init();
  runApp(const App());
}
```

Toggle visibility at any later point:

```dart
// Hide
StatusBarVisibility.setVisibility();

// Show
StatusBarVisibility.setVisibility(isHidden: false);

// Inspect the last requested state (null before init)
final bool? hidden = StatusBarVisibility.isHidden;
```

`setVisibility` throws a `NotInitializedError` if `init` has not been
called.

## API

| Member                                  | Description                     |
| --------------------------------------- | ------------------------------- |
| `Future<bool> init({bool setHidden})`   | Configure system UI and apply   |
|                                         | the initial visibility.         |
| `bool setVisibility({bool isHidden})`   | Hide or show the status bar.    |
| `bool? isHidden`                        | Last requested state.           |
| `void reset()`                          | Testing only: clear state.      |

## Testing

Tests mock `SystemChannels.platform` and the two plugin method channels,
then drive each `OSPlatform` branch with `OSPlatform.override`.

```sh
fvm flutter test
```

## License

MIT — see `LICENSE`.