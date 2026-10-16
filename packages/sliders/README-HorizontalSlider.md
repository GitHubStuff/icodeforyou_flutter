# HorizontalSlider

A stateless horizontal slider that reports value changes to its parent.
The parent owns the value and passes it back in, so the widget is a pure,
easily testable view. It always renders a round thumb on a continuous,
tick-free track, whatever the ambient Material 3 theme says.

## Features

- Controlled: `value` in, `onChanged` out. Nothing is stored in the widget.
- Lenient range: an out-of-range `value` is displayed at the nearest bound
  without touching the caller's state; the first `onChanged` after a drag
  reports an in-range value.
- `divisions` snaps drags to a grid and limits `onChanged` to grid values;
  `null` is continuous.
- `onChanged: null` disables the slider, as with Material's `Slider`.
- One `color` tints the active and inactive track, the thumb and the press
  halo.
- Round thumb, rounded track, no track gap, no tick marks, and tight
  horizontal padding so it sits close to neighbouring widgets — regardless
  of the ambient theme.
- Four-layer theme resolution, each layer overriding the last: ambient
  `SliderTheme` → `HorizontalSlider.defaultShapes` → `color` tint →
  `sliderTheme`. Set only the fields you want to change.

## Getting started

Add the package to a workspace member's `pubspec.yaml`:

```yaml
dependencies:
  sliders:
```

It resolves through the monorepo's pub workspace; no `path:` reference is
needed. This widget depends on `flutter` only.

## Usage

A volume slider from 0 to 10 in whole steps:

```dart
import 'package:flutter/material.dart';
import 'package:sliders/sliders.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 5;

  @override
  Widget build(BuildContext context) {
    return HorizontalSlider(
      value: _volume,
      min: 0,
      max: 10,
      divisions: 10,
      color: Colors.deepOrange,
      onChanged: (value) => setState(() => _volume = value),
    );
  }
}
```

To change one thing the tint doesn't cover, pass a `sliderTheme` with just
that field; it is merged last, so everything else stays as resolved:

```dart
HorizontalSlider(
  value: _volume,
  color: Colors.deepOrange,
  sliderTheme: const SliderThemeData(trackHeight: 8),
  onChanged: (value) => setState(() => _volume = value),
)
```

A continuous slider (no `divisions`) calls `onChanged` on every pointer
move during a drag. If the parent only wants discrete changes, set
`divisions`.

## Additional information
