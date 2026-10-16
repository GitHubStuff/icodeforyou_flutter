# sliders

A horizontal slider flanked by decrease and increase buttons:
`HSliderWithButtons`. The buttons nudge the value by a fixed step with
haptic feedback; the slider is dragged freely or snapped to divisions. Both
report through one `onChanged` callback, so the parent never needs to know
which control the user touched.

## Features

- One callback for every change, whether it came from a drag or a tap.
- Buttons step by a fixed amount, independent of the slider's snap grid.
- Decrease button disables at `min`, increase button disables at `max`;
  the slider stays live at both bounds.
- `onChanged: null` disables the slider and both buttons together.
- Haptic feedback on every tap, selectable per widget via
  `HapticIntensity`, or silenced with `HapticIntensity.none`.
- Out-of-range `initialValue` is clamped, not asserted; a range moved out
  from under the value re-clamps it silently.
- Single `color` tints the icons, track, thumb and overlay; a
  `SliderThemeData` override reaches the slider for anything finer.
- Round thumb on a continuous track with no tick marks and tight
  horizontal padding, regardless of the ambient Material 3 theme.

## Getting started

Add the package to a workspace member's `pubspec.yaml` alongside the
`extensions` package, which supplies `HapticIntensity`:

```yaml
dependencies:
  extensions:
  sliders:
```

Both resolve through the monorepo's pub workspace; no `path:` reference is
needed. The package depends on `flutter` and `extensions` only.

## Usage

A volume control from 0 to 10 that nudges by one per tap:

```dart
import 'package:flutter/material.dart';
import 'package:sliders/sliders.dart';

class VolumeControl extends StatelessWidget {
  const VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return HSliderWithButtons(
      min: 0,
      max: 10,
      step: 1,
      divisions: 10,
      initialValue: 5,
      color: Colors.deepOrange,
      onChanged: (value) => debugPrint('volume: $value'),
    );
  }
}
```

The widget is uncontrolled: it owns its value and reads `initialValue` only
once, when its state is created. To reset it from the parent, remount it
with a new `Key`.

A continuous slider (no `divisions`) reports on every pointer move during a
drag. If the parent only wants discrete changes, set `divisions`.

## Additional information