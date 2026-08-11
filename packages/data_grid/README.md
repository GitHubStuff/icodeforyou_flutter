# data_grid

A horizontally scrolling, spreadsheet-style Flutter grid for query results.
`DataGrid` renders a schemaless `List<Map<String, Object?>>` — the shape
returned by a database query — with tri-state column sorting, a pinned
header row, a pinned row-number column, cell inspection dialogs, and a
density system that can never clip text. Part of the `icodeforyou_flutter`
monorepo (`packages/`).

## Features

- **Tri-state column sorting** — tappable headers cycle `unsorted →
  ascending → descending → unsorted`, with an arrow icon beside the active
  column name. One column sorts at a time; tapping a new header resets the
  previous one. Sorting never mutates the caller's `data` — an internal copy
  is sorted, and the third tap restores the original order. Ordering rules:
  numbers numerically, strings per `isCaseSensitive` (raw case by default),
  mixed types by string representation, and nulls always last ascending /
  first descending regardless of the flag.
- **Pinned chrome** — a row-button column along the left edge, numbered
  1..N top to bottom, unaffected by sorting and never scrolling
  horizontally; a pinned header row the data scrolls vertically underneath
  (both pan together horizontally); and a `#` corner cell that animates the
  grid back to its initial scroll position on both axes. The chrome is
  styled uniformly by `headerStyle` and `chromeColor` (default: the theme's
  secondary-container pair, deliberately outside the neutral surface family
  the data rows use, so the frame reads as frame).
- **Cell inspection** — cells are single-line and ellipsize instead of
  wrapping; tapping one opens a barrier-dismissible dialog with the column
  name and the full, selectable value. Nulls render italic and dimmed, in
  cells and dialog alike.
- **Style-derived metrics** — row height, sort icon size, and minimum
  column widths are all computed from `headerStyle`, `dataStyle`, and the
  ambient `TextScaler`, so the grid adapts to both the styles and
  accessibility text scaling. Partial styles merge over the theme's
  `titleSmall` (chrome) and `bodyMedium` (data) bases — a
  `TextStyle(color: Colors.amber)` recolors without changing metrics.
  Column-width overrides via `columnWidths` can widen freely but never
  shrink below the caption plus its sort-indicator slot.
- **Density with a no-clip guarantee** — `density` (a raw `VisualDensity`,
  default `standard`) adjusts the row-height floor and row-button column
  minimum in 4dp steps around Material's 48dp touch target. Density sets
  the floor and the styles set the content's claim; the taller always wins,
  so density can never clip text. The **`DataDensity`** enum provides a
  named ladder (`dense` −3/36dp through `airy` +3/60dp, with `compact`,
  `comfortable`, and `standard` at Material's own values), plus
  `DataDensity.forWindowWidth` mapping Material 3 window size classes onto
  rungs conservatively — touch-sized windows always resolve to `standard`,
  only confidently-desktop widths reach `dense`, and positive rungs are
  never auto-selected.
- **Row taps** — `onRowTap` (typedef `DataGridRowTapCallback`) reports the
  1-based **display position** and the row currently displayed there. The
  position is a display coordinate, not a stable identity: sorting changes
  which data row a number refers to.
- **Haptics everywhere** — every tap (headers, cells, row buttons, corner)
  fires the configured `HapticIntensity` (default `light`;
  `HapticIntensity.none` disables).
- **Controller ownership** — optional `horizontalController` (shared axis:
  header and data pan together) and `verticalController` (data area; the
  row-button column follows automatically and cannot scroll independently).
  Standard rule: provided means the caller owns and disposes; null means
  the widget creates and disposes its own. Controllers are exclusive to
  one `DataGrid`.
- **Theming details** — alternating row backgrounds
  (`surfaceContainerHighest` / `surface`), theme-aware 1dp grid lines
  (`outlineVariant`) painted so every cell reads as a fully enclosed 1dp
  box, and an empty `data` list rendering as `SizedBox.shrink`.

## Getting started

This package lives in the monorepo's `packages/` directory and is consumed
via pub workspace resolution. Add it to a consumer's `pubspec.yaml`:

```yaml
dependencies:
  data_grid: ^1.0.0
```

Beyond the Flutter SDK, it depends on the monorepo's `extensions` package
for `HapticIntensity`.

```dart
import 'package:data_grid/data_grid.dart';
```

`DataGrid` must be given bounded height, as with any vertically scrolling
list.

## Usage

```dart
DataGrid(
  data: queryResults, // List<Map<String, Object?>>
  columnWidths: const {'description': 240},
  isCaseSensitive: false,
  density: DataDensity.forWindowWidth(
    MediaQuery.sizeOf(context).width,
  ).toVisualDensity(),
  onRowTap: (rowNumber, rowData) {
    // rowNumber is the 1-based display position after sorting
  },
);
```

All rows are expected to share the same keys; column order is taken from
the first row's key order.

## Additional information

Part of the `icodeforyou_flutter` monorepo, managed with Melos (all
configuration in `pubspec.yaml`); internal dependencies resolve through the
pub workspace (`resolution: workspace`), never path dependencies. Not
intended for publication to pub.dev. File issues and contribute through the
monorepo's normal workflow.

The package follows the repo's standing conventions: one widget per file,
`_k`-prefixed private constants, dartdoc on all public and private members,
`show` clauses on imports, and `icodeforyou_lints` lint compliance.
Implementation stances worth knowing: measurement and rendering share one
resolved style so measured columns can never overflow at render time; the
row-button follower controller is derived state and deliberately never
exposed (a second writable handle to one scroll position would invite
desyncing the chrome from the data); and an active sort column is always
ascending or descending by invariant — cycling back to unsorted also clears
the column.