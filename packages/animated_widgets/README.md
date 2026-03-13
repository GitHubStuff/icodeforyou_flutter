# animated_widgets

A Flutter package providing a collection of animated widgets.

## Widgets

### `AnimatedCheckbox`

Draws or dissolves a checkmark with a particle effect.

```dart
AnimatedCheckbox(
  draw: true,
  onAnimationComplete: (drawState) { },
)
```

### `GrowWidgetView`

Scales a child widget from 0.0 to 1.0 over a given duration.

```dart
GrowWidgetView(
  duration: const Duration(milliseconds: 600),
  onComplete: () { },
  child: MyWidget(),
)
```

### `GrowAndFadeWidgetView`

Simultaneously scales and fades a child widget from 0.0 to 1.0.

```dart
GrowAndFadeWidgetView(
  duration: const Duration(milliseconds: 600),
  onComplete: () { },
  child: MyWidget(),
)
```

## Platform detection

`PlatformIdentifier` and `DefaultPlatformIdentifier` are exposed for
dependency injection in tests.
