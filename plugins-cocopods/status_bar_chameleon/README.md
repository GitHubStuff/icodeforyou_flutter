# status_bar_chameleon

Control the system status bar (fullscreen behavior) on iOS and Android.

---

## Features

- Hide / show status bar
- Works on iOS and Android
- No widget wrappers required
- Simple, direct API

---

## Getting started

Add to your pubspec:

```yaml
dependencies:
  status_bar_chameleon:
```

---

## iOS setup (required)

Add this to your app's `ios/Runner/Info.plist`:

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

Without this, iOS will ignore status bar changes.

---

## Usage

```dart
import 'package:status_bar_chameleon/status_bar_chameleon.dart';

// Hide status bar
await StatusBarChameleon.setStatusBarHidden(hidden: true);

// Show status bar
await StatusBarChameleon.setStatusBarHidden(hidden: false);
```

---

## Example

```dart
ElevatedButton(
  onPressed: () async {
    await StatusBarChameleon.setStatusBarHidden(hidden: true);
  },
  child: const Text('Hide Status Bar'),
)
```

---

## Platform support

| Platform | Supported |
|----------|----------|
| iOS      | ✅       |
| Android  | ✅       |
| Web      | ❌       |
| macOS    | ❌       |
| Windows  | ❌       |
| Linux    | ❌       |

---

## Notes

- iOS requires the Info.plist configuration above
- Android works out of the box
- Calls are no-ops on unsupported platforms

---

## License

MIT
