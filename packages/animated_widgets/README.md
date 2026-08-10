# animated_widgets

A Flutter package of reusable animated widgets, popovers, and animation-flow
building blocks. Part of the `icodeforyou_flutter` monorepo (`packages/`).

All public members are dartdoc'd; each widget lives in its own file. Barrel
exports are curated in `lib/animated_widgets.dart` with explicit `show`
clauses.

## Dependencies

Beyond the Flutter SDK, the package depends on:

- `flutter_bloc` — cubit-driven widgets (`SplashCubit`, `FaderCubit`,
  `CrossFadeWidgetsCubit`)
- `equatable` — value equality for animation specs and ramp models
- `custom_widgets` — `DirectionalController`, `DirectionalSliderAndButtons`,
  `UninheritedText`
- `theme_manager` — `CrossFadeTheme`

## Library structure

```
lib/
├── animated_widgets.dart              # Barrel — curated public API
└── src/
    ├── animated_barrier/              # Full-screen animated popover barrier
    ├── animated_checkbox/             # Draw-in / dissolve-out checkmark
    ├── combination_animation/         # Fluent, sequenced scale/opacity steps
    ├── contextual_reveal/             # Gesture-driven contextual popovers
    ├── crossfade_widgets/             # Slider-driven cross-fade carousel
    ├── fade_in_out_view/              # One-shot opacity animation
    ├── fader_widget/                  # FIFO string fader (cubit-driven)
    ├── grow_and_fade_widget/          # Simultaneous scale + fade entrance
    ├── grow_widget/                   # Scale-from-zero entrance
    ├── length_colored_border_field/   # Text field with length-driven border
    ├── pill_widget/                   # Tappable tag pill
    ├── pulse_widget/                  # Single grow-hold-shrink pulse
    ├── splash_widget/                 # Splash → progress → landing flow
    └── timed_widget/                  # Show child, fire callback on elapse
```

## Widgets and building blocks

### AnimatedBarrier

A full-screen animated barrier with a positioned popover child riding on top.
Construct an immutable spec, then call `show` to insert it into the overlay;
the returned `PopoverHandle.dismiss` animates it away using the same
animation spec run in reverse.

- **`BarrierAnimation`** — sealed hierarchy of entrance/exit specs:
  `FadeBarrier`, `SlideFromTopBarrier`, `SlideFromBottomBarrier`. Symmetric by
  construction: the entrance spec drives the reverse exit, with
  `Curve.flipped` mirroring the easing.
- **`PopoverPosition`** — anchors the child to a target widget's `GlobalKey`
  on a preferred side (`left`, `right`, `above`, `below`) or centers it. When
  the preferred side does not fit inside the safe area, placement walks an
  ordered fallback chain and finally centers.
- Sizing is a maximum constraint, not a forced size — a long `ListView` hits
  the cap and scrolls; a small menu stays small. Optional haptics and
  status-bar hiding are built in.

### AnimatedCheckbox

Animates a checkmark being drawn in (`draw: true`) or dissolved out with a
particle effect (`draw: false`). Fully configurable stroke color, background,
duration, curve, and the three path offsets defining the checkmark shape.
Internals: `CheckmarkPainter`, `CheckmarkPathBuilder`, `DissolveParticle`,
`ParticleGenerator`.

### Combination animation (`AnimatesWidgetExt`)

Fluent, sequenced scale/opacity animations on any `Widget`, played
back-to-back on a single controller. Two entry points with identical per-step
parameters:

```dart
// AnimatedSteps — itself a Widget; a lone call is a one-step animation.
widget
  .animatedSteps(/* step 1 */)
  .step(/* step 2 */)
  .step(/* step 3 */);

// AnimationSequence — a builder finished with .animate(), immune to the
// type-widening footgun AnimatedSteps carries.
widget
  .animationSequence(/* step 1 */)
  .step(/* step 2 */)
  .animate();
```

- **`CombinationAnimationStep`** — one phase: its own scale tween, optional
  opacity tween, duration, curve, and an `onComplete` side-effect hook
  (deliberately excluded from `Equatable` props so fresh closures do not
  break equality).
- **`AnimationTween`** — immutable, normalized begin/end scalar pair sampled
  by `t ∈ [0, 1]`, with `AnimationTween.up`, `.down`, and `.none` factories.
- Steps that only scale skip the opacity layer entirely, avoiding an
  unnecessary compositing layer.

### ContextualReveal

Reveals contextual child widgets in response to tap, long-press, and
double-tap gestures — a different child per gesture, with placement and
dismissal controlled per gesture. `ContextualReveal.simple` shares one child
across all three gestures.

- **`ContextualPosition`** — how the double-tap child presents: `popover`,
  `modal`, `bottomSheet`, or `push` (navigation stack).
- **`ContextualRevealTheme`** — abstract `ThemeExtension` with
  `ContextualRevealLight` / `ContextualRevealDark` implementations. Resolve
  via `ContextualRevealTheme.of(context)`, which falls back on platform
  brightness when no extension is registered. Controls barrier color, popover
  background shade, gap, fade durations, show duration, and an optional back
  button override for pushed reveals.

### CrossFadeWidgets

A slider-driven cross-fade carousel. A `DirectionalSliderAndButtons` (from
`custom_widgets`) steps through `children`; the active child cross-fades on
each index change. With fewer than two children the widget short-circuits:
no slider, controller, or cubit.

- **`CrossFadeAxis`** — which horizontal end is "forward" (`left` / `right`).
- **`CrossFadeWidgetsCubit`** — translates the `DirectionalController`'s
  continuous value into the discrete active index. Owns the step-grid bounds
  (derived from `length`, requires `length >= 2`) so the slider config cannot
  drift out of sync with the child count. Does not own the controller; it
  only subscribes and tears down in `close`.

### FadeInOutView

One-shot opacity animation from `startOpacity` to `endOpacity` over
`duration` (defaults to a 1.0 → 0.0 fade-out), with an `onComplete`
callback. Imports only `widgets.dart`.

### FaderWidget / FaderCubit

A FIFO traffic controller for fading strings through a text widget.
`FaderCubit.push` emits a string immediately when idle or queues it FIFO
otherwise; `FaderWidget` renders `FaderState.current`, fades on every change,
and reports the animation lifecycle back via `fadeStarted` / `fadeComplete`.
The widget holds no traffic-control logic; the cubit owns all decisions and
never infers animation state on its own.

### GrowWidgetView / GrowAndFadeWidgetView

Entrance animations centered in the parent:

- **`GrowWidgetView`** — scales `child` from 0.0 to 1.0 over `duration`,
  calling `onComplete` when done. Backed by `GrowAnimationMixin`.
- **`GrowAndFadeWidgetView`** — the same grow plus a simultaneous fade over
  the shared `duration` and `curve`. Composes `GrowAnimationMixin` with the
  private `FadeAnimationMixin`.

### LengthColoredBorderField

A `TextField` whose border color is driven by the current text length,
resolved through a `ColorPointRamp`. With a non-null `maxLength`, a
`current/max` counter pill renders on the top-right border edge and input is
hard-capped. Controller ownership follows the standard rule: null means the
widget creates and disposes its own `TextEditingController`; supplied means
the caller owns the lifecycle.

- **`ColorPoint`** — a single `(length, color)` pair; `point` is the minimum
  length at which `color` starts applying.
- **`ColorPointRamp`** — a validated, ordered sequence of `ColorPoint`s.
  Guarantees at least one point, a first point of `0`, and strictly ascending
  points (asserted at construction). `colorFor` follows a min-length rule:
  the last point whose threshold is `<=` the supplied length wins.

### PillWidget

A tappable tag pill rendering `label` on a `color` background. The label
color is luminance-picked between `liteThemeColor` and `darkThemeColor`.
Tapping toggles selection (reported via `onSelected`); the selected state
draws a theme-aware border, and the unselected state carries a transparent
border of the same width so selection never changes the pill's size. An
empty label renders as a disabled placeholder. Named sizing constructors
target form factors: `PillWidget.small` (14, phones), `.medium` (16,
tablets), `.large` (18, desktop/web).

### PulseWidget

Scales `child` through a single pulse — grow, hold, shrink — built on the
combination-animation extension. `easeOut` up, `easeIn` down. Each leg runs
for `rate` (default 150ms), so the complete pulse is `rate * 3`; `peakScale`
(default 1.15) sets the apex. Adds no layout of its own.

### Splash flow

A configurable splash flow: splash artwork → optional indeterminate progress
phase while host background tasks run → landing page, with timeout and
task-failure handling.

- **`SplashCubit`** — drives the phase transitions and owns all timers.
  Call `start` with the gating background tasks from the presenting widget's
  `initState`. Terminal states (`LandingShowing`, `TimedOut`,
  `BackgroundTaskFailed`) are final; further callbacks are no-ops.
- **`SplashScreen`** — renders `splashWidget`, then the optional
  `intermediateWidget`, then `landingPage`. One-shot: once the landing page
  is reached, earlier phases never show again. All non-landing phases render
  full-screen and centered — callers do not wrap in `Center` or
  `SizedBox.expand`; the screen owns that layout contract. Provide the cubit
  above via `BlocProvider`.
- **`SplashConfig`** — timing and copy: `splashDuration` (4s),
  `timeoutDuration` (30s, clocked from the start of the indeterminate
  phase), `crossfadeDuration` (200ms), and default timeout/failure messages.
  Every field has a default, so `const SplashConfig()` is a usable baseline.
- **`SplashState`** — sealed states: `SplashShowing`,
  `IndeterminateShowing`, `LandingShowing`, `TimedOut`,
  `BackgroundTaskFailed`.

### TimedWidget

Displays `child` for `duration` (default 1250ms), then invokes `onFinish`.
The timer starts on insertion into the tree; if `duration` changes during the
widget's lifetime, the timer resets and restarts with the new value.

## Conventions

- One widget per file; `part` files for tightly coupled internals.
- Curated barrel exports with explicit `show` clauses.
- `final class` for concrete non-widget classes; sealed hierarchies for
  exhaustive matching (`BarrierAnimation`, `SplashState`).
- Cubits never own controllers they did not construct; ownership is stated
  in the dartdoc.
- Value types (`AnimationTween`, `CombinationAnimationStep`, `ColorPoint`,
  `ColorPointRamp`) use `Equatable`; side-effect callbacks are excluded from
  `props` by design.