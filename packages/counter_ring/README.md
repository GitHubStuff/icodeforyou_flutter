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

# counter_ring

A Flutter circular progress ring driven by a timer-backed Cubit. Give it a
`start`, a `finish`, a `step`, and an `interval`, and `counter_ring` advances
the value on a periodic timer, fills the ring to match, and tells you when it
arrives. Counting up and counting down are both first-class: the direction is
derived from whether `finish` is above or below `start`, so a 60-second
countdown and a 0-to-100 progress counter are the same widget with different
arguments.

Use it for countdown timers, rest timers, cooking timers, stepped progress
indicators, or anything else that should tick from one number to another and
draw an arc while it does.

## Features

- **`CounterRing`** — a `StatelessWidget` that binds a `CounterRingCubit` to
  a ring. Rebuilds on every state emission, provides the cubit to its subtree
  via `BlocProvider`, and exposes `onValueChanged` and `onFinish` callbacks.
- **`CounterRingCubit`** — owns the `Timer`. `start()`, `stop()` (pause),
  and `cancel()` (rewind). The timer is cancelled on stop, cancel, finish,
  and `close()`, so no tick can ever fire against a stale cubit.
- **`CounterRingState`** — an immutable, `Equatable` state carrying `start`,
  `finish`, `step`, `currentValue`, and `status`, with helpers such as
  `isCountingUp`, `direction`, `isRunning`, `isFinished`, and
  `hasReachedFinish`.
- **`CounterRingStatus`** — the lifecycle enum: `idle` → `running` →
  `stopped` / `finished`, and back to `idle` on cancel.
- **`RangeProgressRing`** — the pure-presentation ring, usable on its own
  with any `startValue` / `finishValue` / `currentValue` you already have.
  Fills clockwise when counting up and unwinds counter-clockwise when
  counting down.
- **Exact arrival** — when the next tick would reach or overshoot `finish`,
  the cubit clamps to `finish` exactly and emits `finished` once. No
  floating-point drift past the end.
- **Customisable centre** — supply a `centerBuilder` for the middle of the
  ring, or accept the default readout (whole numbers without a decimal
  point, everything else to one decimal place, styled with
  `textTheme.headlineMedium`).
- **Theme-aware defaults** — `color` and `backgroundColor` are forwarded as
  nullable, so leaving them unset falls through to Material's
  `CircularProgressIndicator` defaults.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  counter_ring:
  flutter_bloc:
```

`counter_ring` is built on `flutter_bloc` and `equatable`. You only need to
declare `flutter_bloc` yourself if you plan to read the cubit from the widget
tree (for example with `context.read<CounterRingCubit>()` inside a
`centerBuilder`); otherwise the single `counter_ring` dependency is enough.

Then import it:

```dart
import 'package:counter_ring/counter_ring.dart';
```

## Usage

### A 60-second countdown

The caller owns the cubit and is responsible for closing it.

```dart
import 'package:counter_ring/counter_ring.dart';
import 'package:flutter/material.dart';

class RestTimer extends StatefulWidget {
  const RestTimer({super.key});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late final CounterRingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CounterRingCubit(start: 60, finish: 0, step: 1)..start();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CounterRing(
      ringCubit: _cubit,
      size: 160,
      strokeWidth: 12,
      onFinish: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rest over')),
      ),
      centerBuilder: (context, state) => Text(
        '${state.currentValue.toInt()}s',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
```

Because `start > finish`, the ring begins full and unwinds to empty.

### A 0-to-100 counter in ten steps

Swap the arguments and the same widget counts up and fills clockwise.

```dart
final cubit = CounterRingCubit(
  start: 0,
  finish: 100,
  step: 10,
  interval: const Duration(milliseconds: 250),
);

CounterRing(
  ringCubit: cubit,
  onValueChanged: (value) => debugPrint('now at $value'),
  onFinish: (finish) => debugPrint('reached $finish'),
);
```

### Controlling the cubit

```dart
cubit.start();   // idle/stopped → running; no-op if already running or finished
cubit.stop();    // running → stopped (pauses at the current value)
cubit.start();   // stopped → running (resumes from the paused value)
cubit.cancel();  // any → idle, currentValue rewound to start; timer cancelled
await cubit.close(); // cancels the timer, then closes the stream
```

`start()` after `finished` does nothing; call `cancel()` first to rewind and
run again.

### Reacting to state

`CounterRing` wraps its subtree in `BlocProvider<CounterRingCubit>.value`, so
anything inside the `centerBuilder` can read the cubit directly:

```dart
centerBuilder: (context, state) => IconButton(
  icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
  onPressed: state.isFinished
      ? null
      : () => state.isRunning
          ? context.read<CounterRingCubit>().stop()
          : context.read<CounterRingCubit>().start(),
),
```

### Callback semantics

`onValueChanged` and `onFinish` fire from a `BlocConsumer` listener whenever
`currentValue` **or** `status` changes:

- `onValueChanged` receives the new `currentValue` on every such emission —
  including status-only transitions like start and stop, where the value is
  unchanged.
- `onFinish` receives the `finish` value exactly once, on the emission that
  transitions the status to `finished`.

### Using the ring without the cubit

`RangeProgressRing` has no state management of its own. Drive it from any
value you already hold:

```dart
RangeProgressRing(
  startValue: 0,
  finishValue: 250,
  currentValue: downloadedBytes.toDouble(),
  size: 48,
  strokeWidth: 4,
  child: const Icon(Icons.download),
);
```

`startValue` and `finishValue` must differ; the constructor asserts this.

## Additional information

### Constraints

- `start` must differ from `finish` (asserted in both `CounterRingCubit` and
  `RangeProgressRing`).
- `step` must be positive. Direction is never encoded in `step`; it is
  derived from `start` and `finish`.
- `start`, `finish`, and `step` are fixed for the lifetime of a cubit.
  `CounterRingState.copyWith` only accepts `currentValue` and `status`.
- `CounterRing` does **not** own its cubit. Create it in `initState`, close
  it in `dispose`, or hand it to a `BlocProvider` that will close it for you.

### Public API

| Export               | Kind              | Purpose                                             |
| -------------------- | ----------------- | --------------------------------------------------- |
| `CounterRing`        | `StatelessWidget` | Cubit-bound ring with callbacks and centre builder  |
| `CounterRingCubit`   | `Cubit`           | Timer owner; `start`, `stop`, `cancel`, `close`     |
| `CounterRingState`   | `Equatable`       | Immutable snapshot of the counter                   |
| `CounterRingStatus`  | `enum`            | `idle`, `running`, `stopped`, `finished`            |
| `RangeProgressRing`  | `StatelessWidget` | Stateless ring for an arbitrary start/finish/value  |

### Contributing and issues

This package lives in the `icodeforyou_flutter` monorepo. Issues and pull
requests are welcome there. Contributions are expected to keep the existing
standards: `very_good_analysis` lints clean, full LCOV coverage on new code,
and the cubit remaining the sole owner of its timer.