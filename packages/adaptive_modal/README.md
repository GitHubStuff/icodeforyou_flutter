# adaptive_modal

A Flutter package that provides a responsive, anchor-aware modal overlay that adapts its layout and behaviour across phone, tablet, desktop, and web.

On **phone** the modal fills the screen. On **tablet, desktop, and web** the modal is constrained to a configurable size and positioned near the trigger widget that opened it — automatically flipping sides if it doesn't fit.

Built entirely on Flutter's `Overlay` system — no `showDialog`, no `Navigator` route — which means background widgets can remain fully interactive when the barrier is disabled.

---

## Features

- **Adaptive layout** — full-screen on phone, anchored and constrained on large surfaces
- **Anchor-aware positioning** — modal appears adjacent to the trigger widget, auto-flips above/below as needed
- **Interactive background** — disable the barrier entirely so underlying widgets stay tappable
- **Typed return value** — `show()` returns `Future<T?>`, resolved via `controller.resolve(value)`
- **Configurable close button** — replace the default `×` with any widget
- **Haptic feedback** — light impact on dismiss, configurable
- **Rotation safe** — re-resolves position on device rotation or window resize
- **Controller-based API** — clean lifecycle matching Flutter's own controller pattern

---

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  adaptive_modal: ^1.0.0
```

---

## Usage

### Minimal setup

```dart
class _MyWidgetState extends State<MyWidget> {
  final _anchorKey = GlobalKey();
  late final AdaptiveModalController<void> _modal;

  @override
  void initState() {
    super.initState();
    _modal = AdaptiveModalController<void>(
      anchorKey: _anchorKey,
      child: const MyModalContent(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modal.attach(context);
  }

  @override
  void dispose() {
    _modal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: _anchorKey,
      onPressed: () => _modal.show(context),
      child: const Text('Open'),
    );
  }
}
```

### Returning a value from the modal

Use `AdaptiveModalController<T>` and call `resolve(value)` from inside the modal content. The `show()` future completes with the value.

```dart
_modal = AdaptiveModalController<String>(
  anchorKey: _anchorKey,
  child: MyModalContent(
    onConfirm: (value) => _modal.resolve(value),
  ),
);

// At the call site:
final result = await _modal.show(context);
if (result != null) {
  debugPrint('User selected: $result');
}
```

Dismissing via the close button or barrier completes the future with `null`.

### Custom close icon

```dart
AdaptiveModalController<void>(
  anchorKey: _anchorKey,
  child: const MyModalContent(),
  config: const AdaptiveModalConfig(
    closeIcon: Icon(Icons.arrow_back_ios_new, size: 18),
  ),
);
```

### No barrier — interactive background

When `barrierDismissible` is `false` no barrier `OverlayEntry` is inserted. The modal floats above the screen but all background widgets remain fully tappable. Close the modal via the close button or `controller.hide()`.

```dart
AdaptiveModalController<void>(
  anchorKey: _anchorKey,
  child: const MyModalContent(),
  config: const AdaptiveModalConfig(
    barrierDismissible: false,
  ),
);
```

### Dismissing from inside the modal

Pass `controller.hide` as a plain `VoidCallback` to your modal content. The content widget never needs to import the package directly.

```dart
AdaptiveModalController<void>(
  anchorKey: _anchorKey,
  child: MyModalContent(
    onDismiss: _modal.hide,
  ),
);
```

---

## AdaptiveModalConfig

All fields are optional with sensible defaults.

| Field | Type | Default | Description |
|---|---|---|---|
| `closeIcon` | `Widget?` | `Icon(Icons.close)` | Widget rendered as the close button |
| `barrierDismissible` | `bool` | `true` | Whether tapping the barrier closes the modal |
| `barrierColor` | `Color` | `Colors.black54` | Barrier overlay colour — ignored when `barrierDismissible` is false |
| `maxWidth` | `double` | `400.0` | Max modal width on large surfaces (logical px) |
| `maxHeight` | `double` | `700.0` | Max modal height on large surfaces (logical px) |
| `animationDuration` | `Duration` | `200ms` | Show and hide animation duration |
| `animationCurve` | `Curve` | `Curves.easeInOut` | Show and hide animation curve |
| `hapticFeedback` | `bool` | `true` | Light haptic impulse on all dismissal paths |

---

## AdaptiveModalController\<T\>

| Member | Signature | Description |
|---|---|---|
| `attach` | `void attach(BuildContext)` | Wires to the nearest `Overlay`. Call from `didChangeDependencies`. |
| `show` | `Future<T?> show(BuildContext)` | Shows the modal. Returns a future that completes with `T?`. |
| `resolve` | `void resolve(T value)` | Dismisses and completes `show` with `value`. |
| `hide` | `void hide()` | Dismisses and completes `show` with `null`. |
| `isVisible` | `bool` | Whether the modal is currently visible. |
| `dispose` | `void dispose()` | Releases all resources. Call from `State.dispose`. |

---

## Lifecycle pattern

The controller follows the same lifecycle pattern as Flutter's built-in controllers (`ScrollController`, `AnimationController`, etc.).

```dart
@override
void initState() {
  super.initState();
  _modal = AdaptiveModalController<void>(
    anchorKey: _anchorKey,
    child: const MyContent(),
  );
}

// attach() in didChangeDependencies — not initState —
// because Overlay.of(context) is not available until after
// the widget is fully inserted into the tree.
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _modal.attach(context);
}

@override
void dispose() {
  _modal.dispose(); // always dispose before super
  super.dispose();
}
```

---

## Platform behaviour

| Platform | Layout | Positioning |
|---|---|---|
| Phone (< 600dp) | Full screen | None — fills available space |
| Tablet (≥ 600dp) | Constrained to `maxWidth` × `maxHeight` | Adjacent to anchor, auto-flips, clamps to safe area |
| Desktop | Constrained to `maxWidth` × `maxHeight` | Adjacent to anchor, auto-flips, clamps to screen |
| Web | Constrained to `maxWidth` × `maxHeight` | Adjacent to anchor, auto-flips, clamps to screen |

The 600dp breakpoint matches Material Design 3 window size class guidance.

---

## Animation

The modal uses a **fade + scale** animation on both show and hide. The scale origin is derived from the modal's position relative to the anchor:

- **Below anchor** — scales from `Alignment.topCenter`
- **Above anchor** — scales from `Alignment.bottomCenter`
- **Full screen (phone)** — scales from `Alignment.bottomCenter`

Scale runs from `0.85` → `1.0` on show and reverses on hide.

---

## File structure

```
lib/
  adaptive_modal.dart          # Public barrel — exports only
  src/
    types.dart                 # AdaptiveModalConfig and internal types
    _controller.dart           # AdaptiveModalController (public API)
    _overlay_manager.dart      # OverlayEntry lifecycle and animation
    _position_resolver.dart    # RenderBox math, flip and clamp logic
    _modal_shell.dart          # Modal UI widget, close button, animation
    _barrier.dart              # Barrier overlay widget
    _platform_detector.dart    # Platform and screen size detection
```

All `src/` files prefixed with `_` are private implementation detail and not accessible to package consumers.
