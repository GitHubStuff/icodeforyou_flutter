# animated_widgets

A collection of eight small, focused animation widgets for Flutter.

## AnimatedCheckbox

Draws a checkmark in, or dissolves it out with a particle effect, depending on the `draw` flag. Configurable stroke colour, size, duration, curve, and the three normalised stroke control points. Calls `onAnimationComplete` with the final `draw` state.

```dart
AnimatedCheckbox(
  draw: _checked,
  strokeColor: Colors.green,
  width: 80,
  onAnimationComplete: (drew) => debugPrint('done: $drew'),
)
```

## AnimatedOverlay

A `Stack`-based overlay host driven by `AnimatedOverlayCubit`. Wrap your app's body in `AnimatedOverlay`, provide the cubit above it, then call `showOverlay(child)`, `updateOverlay(child)`, `fadeOverlay()`, or `removeOverlay()` from anywhere in the tree. The status bar auto-hides while an overlay is visible.

```dart
BlocProvider(
  create: (_) => AnimatedOverlayCubit(),
  child: AnimatedOverlay(
    child: HomePage(),
  ),
)

// Later, from any descendant:
context.read<AnimatedOverlayCubit>().showOverlay(const CircularProgressIndicator());
// ...then:
context.read<AnimatedOverlayCubit>().fadeOverlay();
```

## ContextualReveal

Wraps a `body` widget with three independent gesture handlers — tap, long-press, and double-tap — each revealing its own child. Tap and long-press children are non-interactive (auto-dismissed on timer or release); the double-tap child is interactive and placed via `ContextualPosition` (`popover`, `modal`, `bottomSheet`, or `push`). Use `ContextualReveal.simple` when all three gestures share one child.

```dart
ContextualReveal(
  body: const Icon(Icons.info, size: 48),
  tapChild: const Text('Tapped'),
  longChild: const Text('Holding…'),
  doubleChild: const DetailsPanel(),
  doublePosition: ContextualPosition.bottomSheet,
)
```

## FadeInOutView

A one-shot fade animation from `startOpacity` to `endOpacity` over `duration`. Defaults fade out (1.0 → 0.0); flip the values for a fade-in. Optional `onComplete` fires when the animation finishes.

```dart
FadeInOutView(
  duration: const Duration(milliseconds: 400),
  startOpacity: 0,
  endOpacity: 1,
  onComplete: () => debugPrint('faded in'),
  child: const Text('Hello'),
)
```

## GrowAndFadeWidgetView

Simultaneously scales `child` from 0 → 1 and fades it from 0 → 1, centred in its parent, over a single shared `duration` and `curve`. Optional `onComplete` callback.

```dart
GrowAndFadeWidgetView(
  duration: const Duration(milliseconds: 350),
  onComplete: () => debugPrint('grew + faded'),
  child: const FlutterLogo(size: 96),
)
```

## GrowWidgetView

Scales `child` from 0 → 1, centred in its parent, over `duration`. Calls the required `onComplete` callback when the animation reaches 1.0.

```dart
GrowWidgetView(
  duration: const Duration(milliseconds: 300),
  onComplete: () => debugPrint('grown'),
  child: const Icon(Icons.star, size: 64),
)
```

## LengthColoredBorderField

A `TextField` whose border colour is driven by current text length via a `ColorPointRamp` — a validated, strictly ascending sequence of `(length, color)` thresholds. When `maxLength` is non-null, input is hard-capped and a counter pill (`current/max`) renders on the top-right of the border in the active colour.

```dart
LengthColoredBorderField(
  maxLength: 50,
  ramp: ColorPointRamp(const [
    ColorPoint(point: 0,  color: Colors.red),
    ColorPoint(point: 10, color: Colors.orange),
    ColorPoint(point: 30, color: Colors.green),
  ]),
)
```

## PulseWidget

Applies a scale-bounce (1.0 → 1.2 → 1.0) to `child` every time `trigger` flips from `false` to `true`. Useful for drawing attention to a badge, icon, or counter on update.

```dart
PulseWidget(
  trigger: _justUpdated,
  duration: const Duration(milliseconds: 200),
  child: Badge(label: Text('$_count'), child: const Icon(Icons.notifications)),
)
```
