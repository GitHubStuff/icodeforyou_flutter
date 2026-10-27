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

# border_caption

A Flutter widget that places a short text label "in" the top or bottom border
of another widget, the way `OutlineInputBorder` floats a label through the
outline of a text field — but for any bordered widget, not just `TextField`.

```text
┌─ Title ──────────────┐
│  Some static stuff   │
└────── some text ─────┘
```

Use it to caption a `Card`, a `DecoratedBox`, a grouped settings section, a
legend box, or anything else that already draws its own border.

## Features

- **Top or bottom border** — choose which edge carries the label with
  `LabelBorder.top` or `LabelBorder.bottom`.
- **Any horizontal alignment** — `labelAlignment` takes an
  `AlignmentGeometry`, so `centerStart`, `center` and `centerEnd` all work and
  resolve correctly under right-to-left `Directionality`.
- **Corner-safe** — `labelInset` keeps the label clear of both corners so it
  never overlaps a `BorderRadius`.
- **Bring your own border, or let the widget draw one** — the default
  constructor overlays a label on a child that already draws its border;
  `BorderCaption.outlined` wraps plain content in a rectangular outline for
  you.
- **Never clipped** — the label's size is measured before layout and half of
  it is reserved as overhang, so the widget is sized correctly even inside a
  tightly constrained parent.
- **Theme-aware fill** — the box behind the label defaults to
  `ThemeData.scaffoldBackgroundColor`, which is what makes the border appear
  to "break" around the text.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  border_caption:
```

Then import it:

```dart
import 'package:border_caption/border_caption.dart';
```

The package depends on `ext_string` for text measurement; it is pulled in
transitively and needs no setup.

## Usage

### Bring your own border

The child is expected to draw its own border. `BorderCaption` does not touch
it; it paints the label over a filled box whose vertical centre sits exactly on
the chosen edge, hiding the border beneath the text.

```dart
BorderCaption(
  label: 'some text',
  labelAlignment: AlignmentDirectional.center,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text('Some static stuff'),
  ),
)
```

### Let the widget draw the outline

For the common case of a plain rectangular outline, `BorderCaption.outlined`
builds the bordered container for you. Here `child` is the *content*, and the
outline is described by `borderColor`, `borderWidth`, `borderRadius` and
`padding`.

```dart
BorderCaption.outlined(
  label: 'some text',
  labelBorder: LabelBorder.top,
  labelAlignment: AlignmentDirectional.centerStart,
  borderColor: Theme.of(context).colorScheme.outline,
  child: const Text('Some static stuff'),
)
```

There is no `BuildContext` at construction time, so `borderColor` defaults to
opaque black (mirroring `Border.all`). Pass a theme colour at the call site, as
above, for a theme-aware outline.

### Matching the background

The filled box behind the label must be the same colour as whatever is behind
the child's border, otherwise it shows as a visible rectangle rather than a
gap. The default is `Theme.of(context).scaffoldBackgroundColor`; override it
with `backgroundColor` when the widget sits on a `Card`, a coloured surface, or
any other non-scaffold background:

```dart
BorderCaption(
  label: 'Details',
  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
  child: myBorderedWidget,
)
```

### Parameters

| Parameter | Type | Default | Purpose |
| --- | --- | --- | --- |
| `label` | `String` | required | Text shown in the border. Always a single, unwrapped line. |
| `child` | `Widget` | required | The bordered widget (default constructor) or the content inside the generated outline (`outlined`). |
| `labelBorder` | `LabelBorder` | `bottom` | Which edge carries the label. |
| `labelAlignment` | `AlignmentGeometry` | `centerEnd` (default), `centerStart` (`outlined`) | Horizontal position along the border. Only the horizontal component is used. |
| `labelInset` | `double` | `16` | Minimum distance kept clear of both corners. |
| `labelStyle` | `TextStyle?` | `null` | Merged on top of the ambient `DefaultTextStyle`. |
| `labelPadding` | `EdgeInsets` | `symmetric(horizontal: 4)` | Padding inside the filled box. Horizontal padding widens the hidden stretch of border; vertical padding grows the overhang. |
| `backgroundColor` | `Color?` | `scaffoldBackgroundColor` | Fill behind the label. |

Additional parameters on `BorderCaption.outlined` only:

| Parameter | Type | Default | Purpose |
| --- | --- | --- | --- |
| `borderColor` | `Color` | black | Colour of the generated outline. |
| `borderWidth` | `double` | `1` | Thickness of the outline. |
| `borderRadius` | `BorderRadiusGeometry` | `circular(8)` | Corner rounding of the outline. |
| `padding` | `EdgeInsetsGeometry` | `all(16)` | Space between the outline and the content. |

### How it works

1. The label is measured ahead of layout with `String.pixelSize` (from
   `ext_string`) using the resolved text style, `Directionality` and
   `TextScaler`.
2. Half of the label's height (plus half of any vertical `labelPadding`) is
   reserved as padding above or below the child, so the overall widget is
   taller than its child by that overhang.
3. The label is placed in a `PositionedDirectional` slot exactly as wide as
   the child, inset by `labelInset` on both sides, and aligned within that slot
   by `labelAlignment`. No horizontal measurement is needed, so a centred or
   end-aligned label stays correct whatever width the child resolves to.
4. A `ColoredBox` filled with `backgroundColor` sits behind the text and hides
   the border underneath it.

See `OutlineInputBorder` for the same effect achieved by cutting a real gap in
the border path.

## Additional information

This package lives in the `icodeforyou_flutter` monorepo and follows its
conventions: `very_good_analysis` linting, 100% LCOV test coverage, and
`fvm`-pinned SDK versions. Run the test suite from the monorepo root with the
`melos_test` tooling, or from the package directory with `flutter test`.

Issues and contributions are handled through the monorepo's issue tracker.
