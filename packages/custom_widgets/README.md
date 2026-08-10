# custom_widgets

General-purpose Flutter widgets shared across the `icodeforyou_flutter` monorepo. Each widget makes a small set of opinionated decisions — sizing, theming, lifecycle ownership — so app code composes instead of re-deciding.

The package follows the monorepo's standing conventions: one widget per file, dartdoc on every public and private member, `final class` for concrete non-widget classes, `show` clauses on all imports, `_k` prefix for private constants, and a test suite targeting 100% LCOV line coverage.

Internal packages resolve through the pub workspace (`resolution: workspace`). Import the barrel only — everything under `lib/src` is private:

```dart
import 'package:custom_widgets/custom_widgets.dart';
```

## anchored

Positions a child relative to an anchor widget using a `Placement` plus an optional additive `Offset`. The anchor is laid out first and defines the box; the child is aligned to `atPlacement` over that box, then nudged by `offset`. The child is not clipped (`Clip.none`), so it may overhang — intended for badges, markers, and edge decorations.

### Usage

```dart
Anchored(
  toAnchor: const Icon(Icons.notifications, size: 48),
  atPlacement: Placement.topRight,
  offset: const Offset(4, -4),
  child: const Badge(label: Text('3')),
)
```

The anchor must take a definite size from its own constraints, as the surrounding `Stack` sizes to it.

## crash_screen

A terminal error screen the user cannot navigate away from. Displays `error` (and optionally `stackTrace`) as selectable text so the user can copy it for a help-desk report. System back gestures and buttons are blocked via `PopScope(canPop: false)`.

### Optional actions

If `resumePath` is non-null, a resume button routes there via `context.go`, replacing the broken navigation stack. If `onReport` is non-null, a report button is shown — wire it to a crash-reporting service later without changing the widget.

### CrashScreenArgs

Carries `error`, `stackTrace`, and `resumePath` through `GoRouter`'s `state.extra`. The route guard throws `StateError` when the extra is missing, so a misrouted navigation fails loudly in development instead of rendering an empty crash screen.

## default_welcome_screen

A full-screen welcome surface: the analog clock (from `analog_clock_widget`) beside a "Welcome" label in Archivo Black, centred on a deep purple background. Takes no parameters — it is the placeholder home for freshly templated apps.

### Testing note

The Archivo Black face loads through `google_fonts`. Widget tests must disable runtime fetching (`GoogleFonts.config.allowRuntimeFetching = false`) or bundle the font as a test asset.

## directional_slider

A snapped slider system in three parts, exported together.

### DirectionalController

Holds the current value and notifies listeners when it changes. Callers construct it, hand it to the slider, and optionally to widgets that drive the slider externally. Writes to `value` update only the slider's subtree — the caller's widget does not rebuild. Same lifecycle contract as `TextEditingController`: the owner must `dispose()` it. Setting the same value twice (bit-exact `==`) does not notify.

### DirectionalSlider

The slider itself. Values snap to a `step` grid between `min` and `max`; `rotation` orients the track horizontally or vertically; `minValueFirst` controls polarity; `placement` positions the value label. Optional haptics fire on bucket crossings when `enableHapticFeedback` is set, at the configured `HapticIntensity`.

### DirectionalSliderAndButtons

Wraps the slider with a minus button on the `min` side and a plus button on the `max` side, oriented to match `axis`. Tap a button to step once; press-and-hold to auto-repeat. The slider remains fully draggable. Buttons disable automatically at the range limits.

### Usage

```dart
DirectionalSliderAndButtons(
  controller: _volume, // caller-owned DirectionalController
  min: 0,
  max: 10,
  step: 0.5,
)
```

## expanding_textfield

A multiline input that grows with its content from `minLines` (default 4) to `maxLines` (default 10, nullable for unbounded). Defaults to a bold 18pt monospace style, `TextInputType.multiline`, a newline input action, autofocus, and autocorrect off. The outline color follows the theme primary unless `borderColor` overrides it.

## orientation_flex

A `Flex` whose direction is selected from the current viewport's aspect shape.

### AspectShape

`AspectShape.fromSize` classifies a `Size` as `portrait`, `landscape`, or `square`. A viewport counts as square when its long-to-short side ratio is within `squareTolerance` of 1:1; degenerate sizes (zero or negative extent) classify as square.

### OrientationFlex

Measures the viewport with `MediaQuery.sizeOf`, so the layout updates on device rotation and window resizing through a single signal — no separate rotation-versus-resize path. Each shape maps to its own axis (`forPortrait`, `forLandscape`, `forSquare`), and the trigger is decoupled from the result: `forLandscape: Axis.vertical` is legal. All remaining parameters pass straight through to the underlying `Flex`.

## sized_spinner

A fixed-size (40 logical pixels) activity indicator that follows the platform vendor from `platform_utils`: a `CupertinoActivityIndicator` on Apple platforms, a Material `CircularProgressIndicator` everywhere else.

## slide_index_stack

An `IndexedStack` replacement that slides between children when `index` changes. Keeps the `IndexedStack` contract — every child stays mounted for the widget's whole lifetime, so child state survives switches — but animates the change along `direction`.

### Slide semantics

Direction is derived from index order: moving to a higher index slides the incoming child in from the end; a lower index slides in from the start. With `Axis.horizontal` this reads as left/right paging in declaration order, matching a rail whose buttons are declared in the same order as `children`.

### Cost model

At rest, every non-selected child sits in an `Offstage` with tickers disabled by `TickerMode`, so hidden children cost no layout, paint, or animation work. During a slide only the two involved children come on stage. A retarget mid-slide restarts the animation from the new pair.

## solid_screen_color

A chrome-free surface that fills the entire viewport — including the status bar and system navigation bar regions — with a single solid color, via an `AnnotatedRegion<SystemUiOverlayStyle>` that disables contrast enforcement on both bars. Defaults to black. Useful as a splash surface or backdrop where no scaffold chrome should show.

## textfield

Outlined text inputs with shared sizing and slot rules.

### InputField

A self-sizing outlined text input. Its width is driven by a `WindowSizeCategory` (default `extraLarge`) rather than the parent; a trailing `suffixWidget` is centred in a fixed slot so it can never clip the border and aligns with sibling fields; a helper line is permanently reserved so a field showing `errorText` keeps the same height as a sibling that is not — stacked fields never desync vertically. Autocorrect and suggestions default to off. `controller` and `focusNode` are caller-owned.

### PasswordField

`InputField`'s obscured sibling with a reveal/hide toggle in the suffix slot. The toggle announces `Show password` / `Hide password` to assistive technology, refocuses the field on toggle, and parks the caret at the end of the text so typing continues where the user left off.

## uniform_cluster

Equal-extent layout for sibling actions.

### UniformCluster

Lays out `children` along `axis` so they share a uniform main-axis extent. Vertical: every child stretches to the widest child via `IntrinsicWidth` + `CrossAxisAlignment.stretch`, and the cluster is only as wide as its longest child. Horizontal: every child is wrapped in `Expanded`, taking an equal share of the available width — the idiomatic button-bar behavior. `spacing` uses native `Flex` spacing (Flutter 3.27+) and defaults to `DipScale.sm`.

### ButtonPair

A Save/Cancel pair built on `UniformCluster`. Horizontal: Cancel (outlined) leading, Save (filled) trailing, in logical order so RTL mirrors correctly via `Directionality`. Vertical: Save on top, both stretched to the wider label. Save is the emphasized action; labels are customizable via `primaryText` / `secondaryText`, and null callbacks disable their buttons.

## uninherited_text

A standalone fallback message that renders correctly with no inherited `DefaultTextStyle`, `Directionality`, or `Material` — for subtrees mounted above `MaterialApp`, such as a splash flow. Defaults to bold 32pt red-accent text on black, with `TextDecoration.none` set explicitly so the yellow double-underline of unstyled text never appears.

## Dependencies

Internal: `extensions` (`Placement`, `HapticIntensity`, `WindowSizeCategory`), `platform_utils` (`PlatformVendor`, `DipScale`), `theme_manager` (`CrossFadeTheme` button sizing), `analog_clock_widget`, `three_d_sphere`.

Pub: `gap`, `go_router`, `google_fonts`.

## Testing

The `test/` tree mirrors `lib/src` one-to-one, targeting 100% LCOV line coverage:

```zsh
flutter test --coverage
```

Lifecycle objects (`TextEditingController`, `FocusNode`, `DirectionalController`) are caller-owned throughout the package; tests and app code alike must dispose them.