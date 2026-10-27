# SliderButton

An icon button that gives haptic feedback on tap. Built for the two buttons
that flank a slider, but usable anywhere a single tappable icon needs a
tooltip, an accessible name, and a vibration the caller doesn't have to
remember to trigger.

## Features

- Wraps Material's `IconButton`, so ink, focus, hover and the 48 dp touch
  target come for free.
- Haptic fires first, then `onTap` — the caller's callback stays pure
  business logic.
- `haptic` is selectable per button via `HapticIntensity`; defaults to a
  light impact, silenced with `HapticIntensity.none`.
- `onTap: null` disables the button: disabled styling, not focusable, no
  haptic.
- `hint` is required. It shows as a tooltip on long-press and is what
  assistive technology announces for the button, so an icon-only button
  can never ship without an accessible name.

## Getting started

Add the package to a workspace member's `pubspec.yaml` alongside the
`extensions` package, which supplies `HapticIntensity`:

```yaml
dependencies:
  extensions:
  sliders:
```

Both resolve through the monorepo's pub workspace; no `path:` reference is
needed.

## Usage

A pair of buttons that step a value the parent owns:

```dart
import 'package:flutter/material.dart';
import 'package:sliders/sliders.dart';

class StepButtons extends StatelessWidget {
  const StepButtons({
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  /// `null` disables the decrease button.
  final VoidCallback? onDecrease;

  /// `null` disables the increase button.
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderButton(
          icon: const Icon(Icons.remove_circle_outline),
          hint: 'Decrease',
          onTap: onDecrease,
        ),
        SliderButton(
          icon: const Icon(Icons.add_circle_outline),
          hint: 'Increase',
          haptic: HapticIntensity.medium,
          onTap: onIncrease,
        ),
      ],
    );
  }
}
```

Disable a button by passing `null` rather than an empty callback; an empty
callback still fires the haptic and still reads as enabled to screen
readers.

## Additional information