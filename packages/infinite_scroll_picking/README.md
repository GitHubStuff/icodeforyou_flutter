# infinite_scroll_picking

An Apple-style infinite scrolling picker for Flutter. Cycles through a list of
items in either direction, with magnification, 3D perspective, selection
dividers, and a top/bottom fade — all driven by a `FixedExtentScrollController`
under the hood and seeded with a multiplier large enough that no realistic user
will ever reach the edge.

The package ships:

- `InfiniteScrollPicker<T, K>` — a labeled, framed picker widget.
- `InfiniteScrollPickerConfig<T, K>` — items, starting index, picker id, and
  framing.
- `InfiniteScrollWheelConfig` — wheel sizing, dividers, perspective,
  magnification, debounce.
- `InfiniteScrollPickerController` — imperative handle for jumping, animating,
  resetting, and observing the selection.

## Features

- **True infinite scrolling.** Wraps in both directions; no end stops.
- **Apple-style visuals.** Magnified center item, 3D perspective via
  `ListWheelScrollView.useDelegate`, selection band dividers, and a fade
  gradient that blends edge items into the surrounding container.
- **Generic over both item type and picker id.** `T` is the item type. `K` is
  the picker id type — use `String` for casual identifiers, or an enum / sealed
  class for type-safe routing when one handler serves multiple pickers.
- **Imperative control.** `InfiniteScrollPickerController` exposes
  `jumpToIndex`, `animateToIndex`, `reset` (snap or animated), and
  `currentIndex`. It extends `ChangeNotifier`, so consumers can `addListener`
  to observe selection changes without wiring `onItemSelected`.
- **Optional debouncing.** `InfiniteScrollWheelConfig.selectionDebounce`
  coalesces rapid scroll changes so expensive callbacks fire once the user
  settles. Defaults to `Duration.zero` (synchronous, matching
  `ListWheelScrollView`'s native cadence).
- **Shortest-path animation.** `animateToIndex` always wraps around the wheel
  the short way — going `0 → length-1` rotates backward by one slot, not
  forward by `length-1` slots.
- **Efficient rebuilds.** Wheel items subscribe to a `ValueListenable<int>` for
  the selected index, so only the previously- and newly-selected items rebuild
  on a selection change — not the entire wheel.
- **Theming.** Picks up colors from `Theme.of(context).colorScheme`
  (`surfaceContainerHigh` for the background and fade endpoints,
  `primary` for the border and dividers).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  infinite_scroll_picking: ^1.0.0
```

Then import the public library:

```dart
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';
```

The package depends only on `flutter/material.dart` and `flutter/foundation.dart`.

## Usage

### Minimal example

```dart
InfiniteScrollPicker<String, String>(
  label: const Text('Fruit'),
  config: InfiniteScrollPickerConfig<String, String>(
    items: const ['🍎', '🍌', '🍇', '🍊', '🍉'],
    pickerId: 'fruit',
    startingIndex: 0,
  ),
  itemBuilder: (item, isSelected) => Text(
    item,
    style: TextStyle(
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
  onItemSelected: (id, item) => debugPrint('$id picked $item'),
);
```

### With an enum picker id

When one handler serves multiple pickers, use an enum (or sealed class) for
`K` so routing stays type-safe:

```dart
enum TimeUnit { hours, minutes, seconds }

void onPicked(TimeUnit which, int value) {
  switch (which) {
    case TimeUnit.hours:   /* ... */
    case TimeUnit.minutes: /* ... */
    case TimeUnit.seconds: /* ... */
  }
}

InfiniteScrollPicker<int, TimeUnit>(
  label: const Text('Minutes'),
  config: InfiniteScrollPickerConfig<int, TimeUnit>(
    items: List<int>.generate(60, (i) => i),
    pickerId: TimeUnit.minutes,
    startingIndex: 0,
  ),
  itemBuilder: (m, isSelected) => Text(m.toString().padLeft(2, '0')),
  onItemSelected: onPicked,
);
```

### Imperative control

Pass an `InfiniteScrollPickerController` to drive the picker from outside its
widget subtree — a Cubit, a parent widget, or a test:

```dart
class _MyState extends State<MyWidget> {
  final _controller = InfiniteScrollPickerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfiniteScrollPicker<String, String>(
          controller: _controller,
          config: /* ... */,
          label: const Text('Pick'),
          itemBuilder: (item, isSelected) => Text(item),
          onItemSelected: (_, _) {},
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _controller.jumpToIndex(0),
              child: const Text('Snap to first'),
            ),
            TextButton(
              onPressed: () => _controller.animateToIndex(
                5,
                duration: const Duration(milliseconds: 400),
              ),
              child: const Text('Animate to 5'),
            ),
            TextButton(
              onPressed: () => _controller.reset(
                duration: const Duration(milliseconds: 300),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}
```

If you don't supply a controller, the picker creates and disposes its own
internally. If you do supply one, you own its lifecycle — dispose it when
you're done.

A controller can drive **one picker at a time**. Attaching the same controller
to two pickers simultaneously is a programming error and asserts in debug
builds.

### Observing without `onItemSelected`

`InfiniteScrollPickerController` extends `ChangeNotifier`, so you can wire a
plain listener instead of (or in addition to) `onItemSelected`:

```dart
_controller.addListener(() {
  debugPrint('selection changed -> index ${_controller.currentIndex}');
});
```

The listener fires whenever the picker commits a new selection — i.e. after
the debounce window if one is configured.

### Debouncing rapid changes

If the consumer's callback is expensive (a network call, a heavy state update),
debounce the selection so the callback only fires once the user settles:

```dart
InfiniteScrollPickerConfig<String, String>(
  items: items,
  pickerId: 'p',
  startingIndex: 0,
  wheelConfig: const InfiniteScrollWheelConfig(
    selectionDebounce: Duration(milliseconds: 200),
  ),
);
```

The wheel still tracks every tick visually; only the `onItemSelected` callback
(and the controller's `notifyListeners`) is coalesced.

### Visual customization

`InfiniteScrollWheelConfig` controls the wheel itself. All fields have sensible
defaults:

```dart
const InfiniteScrollWheelConfig(
  itemExtent: 24.0,            // height of a single item slot
  wheelWidth: 56.0,            // width of the wheel column
  wheelHeight: 48.0,           // total wheel height (>= 1.1 * itemExtent)
  perspectiveDiameter: 1.2,    // 3D perspective; smaller = more curved
  magnification: 1.25,         // scale of the centered item; >= 1.0
  dividerThickness: 1.0,       // selection band line thickness
  dividerInset: 4.0,           // horizontal inset of the dividers
  wheelBorderRadius: 8.0,
  showBorder: true,
  selectionDebounce: Duration.zero,
);
```

`InfiniteScrollPickerConfig` controls the framing around the wheel:

```dart
InfiniteScrollPickerConfig<T, K>(
  items: /* required, non-empty */,
  pickerId: /* required */,
  startingIndex: /* required, 0 <= n < items.length */,
  wheelConfig: const InfiniteScrollWheelConfig(),
  frameBorderRadius: 8.0,
  frameHorizontalPadding: 12.0,
  frameVerticalPadding: 6.0,
);
```

Both configs implement `==` / `hashCode` and `InfiniteScrollPickerConfig` has a
`copyWith` for nudging a single field inside `didUpdateWidget` flows or Cubit
state.

## Reference

### `InfiniteScrollPicker<T, K>`

| Property         | Type                                       | Notes                                              |
| ---------------- | ------------------------------------------ | -------------------------------------------------- |
| `config`         | `InfiniteScrollPickerConfig<T, K>`         | Items, starting index, picker id, framing.        |
| `label`          | `Widget`                                   | Shown to the left of the wheel — typically `Text`. |
| `itemBuilder`    | `Widget Function(T item, bool isSelected)` | Builds each slot. `isSelected` is true for center. |
| `onItemSelected` | `void Function(K pickerId, T item)`        | Fires when the centered item changes (debounced). |
| `controller`     | `InfiniteScrollPickerController?`          | Optional — picker creates one if null.            |

### `InfiniteScrollPickerController`

| Member                             | Returns         | Notes                                                                     |
| ---------------------------------- | --------------- | ------------------------------------------------------------------------- |
| `currentIndex`                     | `int?`          | Real index in `[0, items.length)`, or `null` if not attached.             |
| `jumpToIndex(int)`                 | `void`          | Snaps to the index. Wraps via modulo.                                     |
| `animateToIndex(int, {duration, curve})` | `Future<void>` | Animates via the shortest wrap-around path.                            |
| `reset({duration, curve})`         | `Future<void>`  | Returns to the config's `startingIndex`. `duration: null` snaps.          |
| `addListener(VoidCallback)`        | `void`          | (Inherited from `ChangeNotifier`.) Fires on each committed selection.    |
| `dispose()`                        | `void`          | Caller-owned lifecycle when an external controller is supplied.           |

## Behavior notes

- **Empty `items` is rejected.** `InfiniteScrollPickerConfig` asserts
  `items.length > 0`. Same for negative paddings/radii and out-of-range
  starting indices.
- **`startingIndex` must be in range.** `0 <= startingIndex < items.length`.
- **Updating the config.** When the picker rebuilds with new
  `config.items` (different content or length) or a new `startingIndex`, the
  underlying scroll controller is rebuilt and the selection resets. Identity
  and `==` fast-paths skip the rebuild when nothing actually changed.
- **`mounted` guard.** A debounced selection that fires after the picker is
  unmounted is dropped silently — the controller's `notifyListeners` is also
  skipped in that case.
- **Modulo indexing.** `jumpToIndex` and `animateToIndex` interpret their
  argument modulo `items.length`. `-1` lands on the last item;
  `items.length` lands on the first.

## Testing

A `@visibleForTesting` accessor — `InfiniteScrollPickerConfig.initialWheelOffset`
— exposes the seed offset used by the underlying `FixedExtentScrollController`.
The seed is `items.length * 10000 + startingIndex`, which guarantees congruence
to `startingIndex` modulo `items.length` regardless of list size. Tests can
verify wrap behavior without scrolling thousands of items.

## License

Proprietary / personal monorepo package.
