# color_grid

A purely presentational 4×4 grid of tappable color cells with a built-in
refresh action. The first fifteen cells render caller-supplied ARGB values;
the sixteenth is a refresh button. The grid holds no state and never mutates
or fetches colors itself — every interaction is reported through callbacks.
Part of the `icodeforyou_flutter` monorepo (`packages/`).

## Features

- **`ColorGrid`** — a `StatelessWidget` rendering exactly fifteen ARGB
  colors in grid order plus a refresh cell. Tapping a color fires
  `onColorTapped` with the cell's index (0–14) and ARGB value via the
  `ColorGridColorTap` typedef; tapping the refresh cell fires
  `onRefreshRequested`. The color count is enforced with a constructor
  assert — exactly fifteen values, no more, no fewer.
- **Haptics on every tap** — each cell tap, including refresh, triggers the
  configured `HapticIntensity` (default `light`) from the monorepo's
  `extensions` package.
- **Responsive spacing** — cells are fixed at 70 logical pixels; a
  `LayoutBuilder` picks the gap: 8px everywhere (internal gaps and border
  inset alike) when the parent is at least wide enough for four cells, five
  wide gaps, and the border on both sides, dropping to 4px in narrower
  parents. The grid hugs its content (`MainAxisSize.min` both axes).
- **Theme-aware border** — a 2px border switches with `Theme.brightness`:
  deep purple (`0xFF6A1B9A`) in light mode, light purple (`0xFFCE93D8`) in
  dark. The refresh icon shares the border color.

## Getting started

This package lives in the monorepo's `packages/` directory and is consumed
via pub workspace resolution. Add it to a consumer's `pubspec.yaml`:

```yaml
dependencies:
  color_grid: ^1.0.0
```

Beyond the Flutter SDK, it depends on the monorepo's `extensions` package
for `HapticIntensity`.

```dart
import 'package:color_grid/color_grid.dart';
```

## Usage

The grid is presentation-only; the host owns the colors and regenerates them
on refresh:

```dart
ColorGrid(
  colors: palette, // exactly 15 ARGB ints
  onColorTapped: (index, colorValue) {
    // e.g. apply Color(colorValue) as the selection
  },
  onRefreshRequested: () {
    // regenerate palette and rebuild with the new list
  },
  haptics: HapticIntensity.medium,
);
```

## Additional information

Part of the `icodeforyou_flutter` monorepo, managed with Melos (all
configuration in `pubspec.yaml`); internal dependencies resolve through the
pub workspace (`resolution: workspace`), never path dependencies. Not
intended for publication to pub.dev. File issues and contribute through the
monorepo's normal workflow.

The package follows the repo's standing conventions: one widget per file,
`_k`-prefixed private constants, dartdoc on all members, `show` clauses on
imports, and `icodeforyou_lints` lint compliance. Layout math is derived
from the constants (`_kWideModeMinWidth` is computed, not hardcoded), so
changing cell size or gaps cannot desynchronize the responsive breakpoint.