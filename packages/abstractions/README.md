# Abstractions

A Flutter package providing abstract base classes that simplify common widget patterns and reduce boilerplate code.

## Features

- **ExtendedStatefulWidget** — An abstract `State` class that automatically handles `WidgetsBindingObserver` lifecycle and provides convenient callbacks for common app events.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  abstractions:
    path: packages/abstractions  # adjust path as needed
```

## Usage

### ExtendedStatefulWidget

Extend `ExtendedStatefulWidget` instead of `State` to gain automatic observer management and lifecycle callbacks without the boilerplate.

```dart
import 'package:abstractions/abstractions.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ExtendedStatefulWidget<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Called once after the first frame is rendered.
    // Safe to access context, perform navigation, show dialogs, etc.
    debugPrint('First layout complete!');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // React to app lifecycle changes (resumed, paused, inactive, etc.)
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed');
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics(); // Must call super
    // Device metrics changed (orientation, screen size, etc.)
    // MediaQuery is guaranteed to be updated when this fires.
  }

  @override
  void didChangePlatformBrightness() {
    // Platform brightness changed (light/dark mode toggle)
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    debugPrint('Brightness: $brightness');
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    // Called on init and whenever text scale factor changes.
    debugPrint('Text scale factor: $textScaleFactor');
  }
}
```

## API Reference

### ExtendedStatefulWidget\<T extends StatefulWidget\>

An abstract class that extends `State<T>` and mixes in `WidgetsBindingObserver`.

#### Lifecycle

| Method | Description |
|--------|-------------|
| `initState()` | Automatically registers the observer and schedules `afterFirstLayout`. Always call `super.initState()`. |
| `dispose()` | Automatically removes the observer. Always call `super.dispose()`. |

#### Callbacks

| Callback | When Called |
|----------|-------------|
| `afterFirstLayout(BuildContext context)` | Once, after the first frame renders. Safe for context-dependent operations. |
| `didChangeAppLifecycleState(AppLifecycleState state)` | When the app lifecycle state changes. |
| `didChangeMetrics()` | When device metrics change. Uses post-frame callback to ensure `MediaQuery` is updated. |
| `didChangePlatformBrightness()` | When the platform brightness (light/dark mode) changes. |
| `didChangeTextScaleFactor()` | When the system text scale factor changes. |
| `reportTextScaleFactor(double? textScaleFactor)` | Called on init and when text scale changes. Override to react to text scaling. |

## Why Use This?

Without `ExtendedStatefulWidget`, you'd write:

```dart
class _MyWidgetState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // after first layout logic
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // handle state
  }

  // ... more overrides
}
```

With `ExtendedStatefulWidget`, observer registration, cleanup, and common callbacks are handled for you—just override what you need.

## Requirements

- Flutter SDK
- Dart SDK >=3.22.0 <4.0.0

## License

See LICENSE file for details.
