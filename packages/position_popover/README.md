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

# PositionPopover

A typed, anchored popover for Flutter. Wrap any widget in
`PositionPopover<T>`, tap it, and a popover of your own design opens at an
`Alignment` relative to that widget and pops with a `T?` — a value, or
`null` when the user taps away or a timeout elapses.

Use it where `PopupMenuButton` is too opinionated: date pickers, colour
swatches, quick-action trays, inline editors, or anything that should
appear next to the thing that opened it and hand back a result.

## Features

- **Typed result.** The popover closes with `Navigator.pop<T>(context,
  value)`; the trigger receives it through `onResult` as `T?`.
- **Anchored positioning.** Any `Alignment` relative to the tapped widget.
  `Alignment.center` overlays it, `Alignment.topCenter` sits above it,
  `Alignment.bottomRight` hangs below-right; fractional alignments give
  partial overlap. Popovers that would leave the screen are slid back
  inside.
- **Leading and trailing slots.** Optional widgets on either side of the
  tap target, outside the tap area, with their own gesture handling — a
  static glyph on the left, a clear button on the right.
- **Decorated group.** An optional `Decoration` and `padding` draw a border
  or background around the whole strip, while the popover still anchors to
  the tap target alone.
- **Modal barrier.** Configurable colour and dismissibility; barrier taps
  pop with `null`.
- **Timeout.** An optional `Duration` after which the popover dismisses
  itself with `null`.
- **Haptics.** A `HapticIntensity` fired when the popover opens.
- **Composable.** The route (`PositionPopoverRoute`) and layout delegate
  (`PopoverLayoutDelegate`) are public, so you can push a popover from a
  long-press, a drag, or any rectangle you already have.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  position_popover:
```

Then import it:

```dart
import 'package:position_popover/position_popover.dart';
```

The package depends on `haptic_intensity` for the haptic enum; no platform
setup is required.

## Usage

### Minimal

```dart
PositionPopover<String>(
  onResult: (String? choice) => debugPrint('$choice'),
  parent: const Text('Pick one'),
  popover: const ChoiceMenu(),
)
```

Where `ChoiceMenu` is any widget that closes itself:

```dart
class ChoiceMenu extends StatelessWidget {
  const ChoiceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final choice in <String>['Alpha', 'Bravo', 'Charlie'])
            ListTile(
              title: Text(choice),
              onTap: () => Navigator.pop<String>(context, choice),
            ),
        ],
      ),
    );
  }
}
```

### Date field with leading glyph, trailing clear, and a border

```dart
PositionPopover<DateTime>(
  alignment: Alignment.bottomCenter,
  decoration: BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.outline),
    borderRadius: BorderRadius.circular(8),
  ),
  padding: const EdgeInsets.only(left: 12, right: 4),
  onResult: (DateTime? picked) {
    if (picked != null) setDate(picked);
  },
  leadingIcon: const Icon(Icons.calendar_today),
  trailingIcon: IconButton(
    icon: const Icon(Icons.clear),
    onPressed: clearDate,
  ),
  parent: Text(formattedDate),
  popover: const DatePickerPopover(),
)
```

The clear button never opens the popover; it is outside the tap area and
runs its own `onPressed`.

### Timeout and non-dismissible barrier

```dart
PositionPopover<bool>(
  timeout: const Duration(seconds: 5),
  barrierDismissible: false,
  barrierColor: Colors.black87,
  hapticIntensity: HapticIntensity.medium,
  onResult: (bool? confirmed) => handle(confirmed ?? false),
  parent: const Icon(Icons.delete),
  popover: const ConfirmTray(),
)
```

### Pushing the route directly

When you already have the anchor rectangle — from a long-press, a drag, or
a measured render object — skip the trigger widget:

```dart
final result = await Navigator.of(context).push<Color>(
  PositionPopoverRoute<Color>(
    popover: const SwatchGrid(),
    anchor: anchorRect,
    alignment: Alignment.topCenter,
    barrierDismissible: true,
    barrierColor: Colors.black54,
  ),
);
```

`anchor` must be in the coordinate space of the navigator's overlay.

A fuller example, including a Widgetbook use case for every alignment,
lives in `/example`.

## Additional information

- **Positioning rules.** The popover's `-alignment` point is placed on the
  parent's `alignment` point. If the result would overflow the overlay on
  an axis, it is clamped on that axis only; the requested alignment is not
  otherwise preserved, and nothing reports the adjustment to the popover.
  See the `PopoverLayoutDelegate` docs for details.
- **Sizing.** The popover sizes itself; constraints are loosened, never
  tightened. Cap the popover's own size if it could grow unbounded.
- **Result semantics.** `onResult` receives `null` for a barrier tap, a
  timeout, or a pop with no value. A popover that legitimately returns
  `null` is indistinguishable from a dismissal; use a sentinel or a sealed
  result type if that matters.
- **Contributing.** Issues and pull requests are welcome in the
  `icodeforyou_flutter` monorepo. The package follows
  `very_good_analysis`, targets 100% line coverage, and formats at 80
  columns; run `melos_test test packages position_popover` before opening a
  PR.