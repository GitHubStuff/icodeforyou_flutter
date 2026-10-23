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

# dual_selection

A fixed-size, two-button selector panel for Flutter, plus its one-button
counterpart. Tap a header button and the body cross-fades to the matching
child, fires a haptic, and reports the change — nothing more. The package
depends only on `flutter/widgets.dart` and `haptic_intensity`; it has no
Material or Cupertino dependency and never chooses a colour for you, so it
drops cleanly into any design system.

Use it when you need a compact, bounded "A / B" panel — a date-vs-duration
picker, metric-vs-imperial inputs, a login-vs-register form, a two-tab
settings card — and you want the layout to be deterministic rather than
intrinsic.

## Features

- **`DualSelection`** — two header buttons sharing a row, one body area,
  animated cross-fade between `firstChild` and `secondChild`.
- **`SingleSelection`** — the same frame with a single header and body, no
  tap handling, no animation. Use it beside a `DualSelection` so both render
  pixel-identically.
- **`DualSelectionEnum`** — `first` / `second`, used for the initial
  selection and reported through `onSelectionChanged`.
- **`Defaults`** — every default (dimensions, fade duration, corner radius,
  border width, haptic) exposed as a constant so callers can reference the
  same values.
- **Bounded body constraints.** Each body child is laid out to exactly
  `width × bodyHeight`, so `CupertinoPicker`, `ListView`, `ListWheelScrollView`
  and other widgets that need bounded constraints work without wrapping.
- **Haptic feedback on change** via `haptic_intensity`, configurable per
  widget and never fired when the already-selected button is tapped.
- **Caller-owned colours.** The border colour is required; header backgrounds
  are optional and may be `null` to paint nothing.
- **Deterministic sizing.** The rendered size is
  `(width + 2 × borderWidth) × (headerHeight + bodyHeight + 2 × borderWidth)`.
  Nothing in the widget is intrinsic.
- **Uncontrolled by design.** `selection` seeds the initial state; the widget
  owns it afterwards. Observe changes through `onSelectionChanged`.
- **Assertions on every dimension** so a negative radius or zero height fails
  at construction, not at paint time.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dual_selection:
  haptic_intensity:
```

`haptic_intensity` is a transitive dependency; you only need to list it
yourself if you reference `HapticIntensity` directly (for example to pass
`haptic: HapticIntensity.none`).

Import the barrel file:

```dart
import 'package:dual_selection/dual_selection.dart';
```

The package imports `flutter/widgets.dart` only. It works inside
`MaterialApp`, `CupertinoApp` or a bare `WidgetsApp`.

## Usage

### Minimal

Two labels, two bodies, a border colour. Everything else uses `Defaults`.

```dart
DualSelection(
  first: const Center(child: Text('Date')),
  second: const Center(child: Text('Duration')),
  firstChild: const Center(child: Text('Pick a date')),
  secondChild: const Center(child: Text('Pick a duration')),
  borderColor: Colors.blueGrey,
)
```

### Reacting to selection changes

`onSelectionChanged` fires only when the value actually changes. Tapping the
already-selected button is a no-op.

```dart
class UnitsCard extends StatefulWidget {
  const UnitsCard({super.key});

  @override
  State<UnitsCard> createState() => _UnitsCardState();
}

class _UnitsCardState extends State<UnitsCard> {
  DualSelectionEnum _units = DualSelectionEnum.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DualSelection(
          first: const Center(child: Text('Metric')),
          second: const Center(child: Text('Imperial')),
          firstChild: const _MetricForm(),
          secondChild: const _ImperialForm(),
          borderColor: Theme.of(context).colorScheme.primary,
          onSelectionChanged: (selection) => setState(() => _units = selection),
        ),
        const SizedBox(height: 8),
        Text(
          switch (_units) {
            DualSelectionEnum.first => 'Showing metric units',
            DualSelectionEnum.second => 'Showing imperial units',
          },
        ),
      ],
    );
  }
}
```

### Header colours that follow the selection

The widget paints the selected slot with `selectedHeaderColor` and the other
slot with `unselectedHeaderColor`. The header *content* (`first` / `second`)
is yours, so foreground colours that should change with selection are
driven from your own state.

```dart
final scheme = Theme.of(context).colorScheme;

DualSelection(
  first: const Center(child: Text('Sign in')),
  second: const Center(child: Text('Register')),
  firstChild: const SignInForm(),
  secondChild: const RegisterForm(),
  borderColor: scheme.outline,
  selectedHeaderColor: scheme.primaryContainer,
  unselectedHeaderColor: scheme.surfaceContainerHighest,
)
```

Pass `null` (the default) for either colour to paint nothing in that state:

```dart
DualSelection(
  first: const Center(child: Text('Day')),
  second: const Center(child: Text('Night')),
  firstChild: const DayPanel(),
  secondChild: const NightPanel(),
  borderColor: Colors.white24,
  selectedHeaderColor: Colors.white12,
  // unselectedHeaderColor stays null — the unselected slot is transparent.
)
```

### Starting on the second option

```dart
DualSelection(
  selection: DualSelectionEnum.second,
  first: const Center(child: Text('Monthly')),
  second: const Center(child: Text('Yearly')),
  firstChild: const MonthlyPricing(),
  secondChild: const YearlyPricing(),
  borderColor: Colors.green,
)
```

### Bounded children: pickers and scrollables

Body children receive exact constraints of `width × bodyHeight`, so widgets
that normally need an explicit `SizedBox` or `Expanded` just work.

```dart
DualSelection(
  first: const Center(child: Text('Hours')),
  second: const Center(child: Text('Minutes')),
  firstChild: CupertinoPicker(
    itemExtent: 32,
    onSelectedItemChanged: (index) => debugPrint('hour $index'),
    children: List.generate(24, (i) => Center(child: Text('$i'))),
  ),
  secondChild: ListView.builder(
    itemCount: 60,
    itemBuilder: (_, i) => ListTile(title: Text('$i min')),
  ),
  borderColor: CupertinoColors.systemGrey,
)
```

### Custom dimensions, radius and border

Every dimension is a constructor parameter. The content area is `width` by
`headerHeight + bodyHeight`; the border is drawn *around* it.

```dart
DualSelection(
  width: 320,
  headerHeight: 44,
  bodyHeight: 180,
  borderWidth: 1,
  cornerRadius: 16,
  first: const Center(child: Text('List')),
  second: const Center(child: Text('Map')),
  firstChild: const ResultsList(),
  secondChild: const ResultsMap(),
  borderColor: Colors.black12,
)
// Rendered size: (320 + 2) × (44 + 180 + 2) = 322 × 226.
```

A `borderWidth` of `0` removes the border entirely while keeping the clip:

```dart
DualSelection(
  borderWidth: 0,
  cornerRadius: 12,
  first: const Center(child: Text('A')),
  second: const Center(child: Text('B')),
  firstChild: const PanelA(),
  secondChild: const PanelB(),
  borderColor: Colors.transparent,
)
```

### Fade duration and haptics

```dart
DualSelection(
  fadeDuration: const Duration(milliseconds: 200),
  haptic: HapticIntensity.medium,
  first: const Center(child: Text('Before')),
  second: const Center(child: Text('After')),
  firstChild: const BeforeImage(),
  secondChild: const AfterImage(),
  borderColor: Colors.amber,
)
```

Disable the cross-fade and haptic altogether:

```dart
DualSelection(
  fadeDuration: Duration.zero,
  haptic: HapticIntensity.none,
  first: const Center(child: Text('Raw')),
  second: const Center(child: Text('Formatted')),
  firstChild: const RawJsonView(),
  secondChild: const FormattedJsonView(),
  borderColor: Colors.grey,
)
```

### Rich header buttons

`first` and `second` each fill `width / 2 × headerHeight` via
`SizedBox.expand`. They own their own alignment, padding and foreground
styling — the widget only supplies the background and the tap target.

```dart
DualSelection(
  first: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today, size: 18),
        SizedBox(width: 6),
        Text('Date'),
      ],
    ),
  ),
  second: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 18),
        SizedBox(width: 6),
        Text('Duration'),
      ],
    ),
  ),
  firstChild: const DatePickerBody(),
  secondChild: const DurationPickerBody(),
  borderColor: Colors.indigo,
)
```

### `SingleSelection` — the one-option counterpart

When a screen shows a two-option panel next to a one-option panel,
`SingleSelection` gives you the same frame, radius, border and sizing with no
selection behaviour. The header fills the full `width × headerHeight`.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    DualSelection(
      first: const Center(child: Text('Start')),
      second: const Center(child: Text('End')),
      firstChild: const StartPicker(),
      secondChild: const EndPicker(),
      borderColor: Colors.teal,
      selectedHeaderColor: Colors.teal.shade100,
    ),
    SingleSelection(
      first: const Center(child: Text('Summary')),
      firstChild: const SummaryBody(),
      borderColor: Colors.teal,
    ),
  ],
)
```

`SingleSelection` accepts the same dimension parameters:

```dart
SingleSelection(
  width: 160,
  headerHeight: 40,
  bodyHeight: 120,
  cornerRadius: 10,
  borderWidth: 2,
  first: const ColoredBox(
    color: Colors.black,
    child: Center(
      child: Text('Preview', style: TextStyle(color: Colors.white)),
    ),
  ),
  firstChild: const PreviewBody(),
  borderColor: Colors.black,
)
```

### Reusing `Defaults`

`Defaults` is an `abstract final class` of constants. Reference them when a
sibling widget must line up exactly with a `DualSelection`.

```dart
SizedBox(
  width: Defaults.kWidth + 2 * Defaults.kBorderWidth,
  height: Defaults.kHeaderHeight + Defaults.kBodyHeight + 2 * Defaults.kBorderWidth,
  child: const Placeholder(),
)
```

| Constant                   | Value                        |
| -------------------------- | ---------------------------- |
| `Defaults.kFirstSelection` | `DualSelectionEnum.first`    |
| `Defaults.kFadeDuration`   | `Duration(milliseconds: 750)` |
| `Defaults.kCornerRadius`   | `8.1`                        |
| `Defaults.kHaptic`         | `HapticIntensity.light`      |
| `Defaults.kBorderWidth`    | `3`                          |
| `Defaults.kHeaderHeight`   | `50`                         |
| `Defaults.kBodyHeight`     | `275`                        |
| `Defaults.kWidth`          | `240`                        |

### Driving a Cubit from the selection

The widget is uncontrolled, so wire the callback into whatever state
management you use. With `flutter_bloc`:

```dart
BlocBuilder<PricingCubit, PricingState>(
  builder: (context, state) {
    return DualSelection(
      selection: state.isYearly
          ? DualSelectionEnum.second
          : DualSelectionEnum.first,
      first: const Center(child: Text('Monthly')),
      second: const Center(child: Text('Yearly')),
      firstChild: MonthlyPlans(plans: state.monthly),
      secondChild: YearlyPlans(plans: state.yearly),
      borderColor: Theme.of(context).colorScheme.outline,
      onSelectionChanged: (selection) => context
          .read<PricingCubit>()
          .setYearly(selection == DualSelectionEnum.second),
    );
  },
)
```

Because the widget owns its selection after the first build, `selection`
seeds the initial value only; later state changes do not re-select the
widget. If you need the widget to follow external state, give it a new
`Key` when that state changes:

```dart
DualSelection(
  key: ValueKey(state.isYearly),
  selection: state.isYearly
      ? DualSelectionEnum.second
      : DualSelectionEnum.first,
  // ...
)
```

### Testing

Both widgets are plain `flutter/widgets.dart` widgets and need no
`MaterialApp`. The header buttons are the direct children of the header
`Row`, so tap them by finding your own header content.

```dart
testWidgets('tapping second reports the change once', (tester) async {
  final changes = <DualSelectionEnum>[];

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: DualSelection(
          first: const Text('A'),
          second: const Text('B'),
          firstChild: const Text('Body A'),
          secondChild: const Text('Body B'),
          borderColor: const Color(0xFF000000),
          haptic: HapticIntensity.none,
          onSelectionChanged: changes.add,
        ),
      ),
    ),
  );

  await tester.tap(find.text('B'));
  await tester.pumpAndSettle();
  expect(changes, [DualSelectionEnum.second]);

  // Tapping the already-selected button is a no-op.
  await tester.tap(find.text('B'));
  await tester.pumpAndSettle();
  expect(changes, [DualSelectionEnum.second]);
});
```

## Additional information

### Design notes

- **No Material dependency.** The package imports `flutter/widgets.dart`
  only. Every colour is supplied by the caller; the widget never reads a
  `Theme`. Pass `Theme.of(context).colorScheme.*` yourself if you want
  theme-awareness.
- **Fixed size on purpose.** Intrinsic sizing makes `AnimatedCrossFade`
  jump between children of different heights and breaks pickers that need
  bounded constraints. Pinning both body children to `width × bodyHeight`
  removes both problems.
- **Clip radius.** The body is clipped at `cornerRadius - borderWidth`
  (clamped to zero) so the inner corners sit flush against the border.
- **Assertions.** `cornerRadius` and `borderWidth` must be `>= 0`;
  `headerHeight`, `bodyHeight` and `width` must be `> 0`. Violations throw
  in debug builds at construction.

### Public API

| Export              | Kind                   |
| ------------------- | ---------------------- |
| `DualSelection`     | `StatefulWidget`       |
| `SingleSelection`   | `StatelessWidget`      |
| `DualSelectionEnum` | `enum { first, second }` |
| `Defaults`          | `abstract final class` of constants |

### Contributing

This package lives in the `icodeforyou_flutter` monorepo and is managed with
Melos. Contributions must keep 100% LCOV coverage and pass
`very_good_analysis` with no warnings:

```sh
melos bootstrap
melos run analyze
melos run test
```

### Issues

File issues in the monorepo's issue tracker. Include a minimal reproduction
(a single `DualSelection` or `SingleSelection` construction is usually
enough) and the Flutter version from `fvm flutter --version`.
