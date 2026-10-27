<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# haptic_intensity

Declarative haptic feedback for Flutter controls.

`HapticIntensity` is a single enum that lets a widget expose *which* haptic it
gives as an ordinary constructor parameter, and lets the caller wire that
haptic into any callback with one method call. No `HapticFeedback` imports
scattered through widget code, no `if (enabled) { vibrate(); callback(); }`
boilerplate, and a disabled control stays disabled for free.

## Features

- **One value, one platform call.** `light`, `medium`, `heavy`, `selection`
  and `vibrate` map one-to-one onto `HapticFeedback`; `none` switches
  feedback off without changing any wiring.
- **Callback decorators.** `wrap` for `VoidCallback`, `wrapValue<T>` for
  `ValueChanged<T>`. Each fires the haptic immediately before the wrapped
  callback runs.
- **Disabled state preserved.** Both decorators return `null` for a `null`
  callback, so Material's "null callback means disabled" convention passes
  straight through and no haptic fires on a dead button.
- **Fire-and-forget.** `trigger()` never awaits the platform; it is safe to
  call from a gesture handler or a `setState` path.
- **Zero footprint where it doesn't apply.** On desktop, web and simulators
  `HapticFeedback` is a no-op, so the same code ships everywhere.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  haptic_intensity:
```

Then import it:

```dart
import 'package:haptic_intensity/haptic_intensity.dart';
```

The package depends only on the Flutter SDK. Haptics are produced by the
platform, so a physical iOS or Android device is required to feel them; on
every other target the calls resolve silently.

## Usage

### Expose the haptic as a widget parameter

The intended pattern: the widget takes a `HapticIntensity`, defaults it, and
hands its callback through `wrap`. The caller decides the strength; the
widget never touches `HapticFeedback` directly.

```dart
class StepButton extends StatelessWidget {
  const StepButton({
    required this.icon,
    this.onTap,
    this.haptic = .light,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final HapticIntensity haptic;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: haptic.wrap(onTap),
    );
  }
}
```

A `null` `onTap` yields a `null` `onPressed`, so the `IconButton` renders
disabled and gives no feedback.

### Wrap a callback that takes a value

`wrapValue` is the counterpart for `ValueChanged<T>` signatures. `T` is
inferred from the callback.

```dart
Switch(
  value: isOn,
  onChanged: HapticIntensity.selection.wrapValue(onToggled),
)
```

```dart
SegmentedButton<Unit>(
  segments: segments,
  selected: {unit},
  onSelectionChanged: HapticIntensity.light.wrapValue(onUnitChanged),
)
```

### Fire a haptic directly

When there is no callback to decorate, call `trigger()`.

```dart
void _onThresholdCrossed() {
  HapticIntensity.heavy.trigger();
  // ...
}
```

### Silence feedback without rewiring

Pass `none` for controls that fire continuously, such as a slider reporting
on every pointer move, or to honour a user preference. The callback is still
wrapped, so the call site does not change.

```dart
StepButton(
  icon: const Icon(Icons.add),
  haptic: settings.hapticsEnabled ? .light : .none,
  onTap: increment,
)
```

### Choosing a level

| Value       | Platform call                     | Typical use                                   |
| ----------- | --------------------------------- | --------------------------------------------- |
| `light`     | `HapticFeedback.lightImpact`      | Frequent, low-stakes taps: stepping a value   |
| `medium`    | `HapticFeedback.mediumImpact`     | Deliberate actions: confirm, submit           |
| `heavy`     | `HapticFeedback.heavyImpact`      | Rare, significant actions: finish a flow      |
| `selection` | `HapticFeedback.selectionClick`   | Moving through a picker or segmented control  |
| `vibrate`   | `HapticFeedback.vibrate`          | Alerts rather than acknowledgements           |
| `none`      | —                                 | Continuous controls; user has haptics off     |

iOS and Android interpret the impact strengths in their own way, so treat the
levels as relative intent rather than a guaranteed sensation.

## Additional information

This package is part of the `icodeforyou_flutter` monorepo and is consumed by
the UI packages there (`sliders`, `dual_selection`, `ping_pong`, among
others). It is intentionally tiny: one enum, three methods, no dependencies
beyond Flutter, and it is expected to stay that way.

- **API reference:** every member carries dartdoc; run `dart doc` in the
  package directory to generate it locally.
- **Tests:** `flutter test` from the package directory. The package targets
  100% line coverage.
- **Issues and contributions:** open an issue or pull request in the
  monorepo. Changes must keep the one-to-one mapping between enum values and
  `HapticFeedback` calls, preserve the `null`-in / `null`-out contract of
  `wrap` and `wrapValue`, and ship with tests.
  