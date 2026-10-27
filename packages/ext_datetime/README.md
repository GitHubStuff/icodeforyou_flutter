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

# ext_datetime

Calendar-aware `DateTime` utilities for Flutter: boundary alignment,
human-readable deltas, precision truncation, guaranteed-unique timestamps, and
a self-correcting timer that ticks exactly on the top of the second, minute,
hour, or day.

Dart's `DateTime.difference` gives you a flat `Duration`. This package gives
you what a person would actually say — *"2 years, 2 months, 4 days"* — and
makes it trivial to schedule work on real clock boundaries instead of
"every N milliseconds from whenever you happened to start".

## Features

The barrel exports exactly four symbols:

| Export           | Kind                    | Purpose                                                                 |
| ---------------- | ----------------------- | ----------------------------------------------------------------------- |
| `DateTimeUnit`   | `enum`                  | The eight calendar/clock units, declared coarsest to finest.            |
| `ExtDateTime`    | `extension on DateTime` | Boundary math, truncation, formatting, closeness, unique timestamps.    |
| `DateTimeDelta`  | `final class`           | Immutable, value-equal calendar difference between two UTC instants.    |
| `BoundaryTimer`  | `class`                 | A repeating timer that re-aligns to the next unit boundary every cycle. |

- **Calendar-correct arithmetic.** Month lengths, leap years (including the
  century rules), and DST are all delegated to `DateTime`'s own constructor
  normalisation — nothing in this package hard-codes "30 days".
- **Nullable component windows.** Ask a delta for "days through minutes" and
  get `null` for everything outside that window instead of noise.
- **No drift.** `BoundaryTimer` and `repeatEvery` recompute every wait from
  the live clock, so scheduler slop in one tick never leaks into the next.
- **Testable by construction.** Every time-dependent entry point takes an
  injectable clock; nothing needs a real `sleep`.

## Getting started

This is a Flutter package (it uses `flutter/foundation.dart` for
`@immutable` and `@visibleForTesting`). It lives in a Melos workspace and is
not published to pub.dev.

```yaml
dependencies:
  ext_datetime:
    path: ../ext_datetime   # or the workspace-resolved path
```

```dart
import 'package:ext_datetime/ext_datetime.dart';
```

`ExtDateTime.toDisplay` uses `package:intl`. The default `en_US` locale data
is built in; for any other locale initialise its date symbols first, exactly
as you would for `DateFormat`.

## Usage

### `DateTimeUnit`

```dart
enum DateTimeUnit { year, month, day, hour, minute, second, msec, usec }
```

Declaration order **is** precision order: `year.index == 0`,
`usec.index == 7`. Every other API in this package compares units with
`unit.index`, and you can too:

```dart
bool isFinerThan(DateTimeUnit a, DateTimeUnit b) => a.index > b.index;

isFinerThan(DateTimeUnit.second, DateTimeUnit.minute); // true
```

`sublist()` returns the unit itself and every finer unit as a `Set`:

```dart
DateTimeUnit.minute.sublist();
// {minute, second, msec, usec}

DateTimeUnit.usec.sublist();
// {usec}
```

### `ExtDateTime`

An extension on `DateTime`. All instance members preserve the receiver's
zone: a UTC input yields a UTC output, a local input yields a local output.

#### `next(DateTimeUnit)` — microseconds to the next boundary

"Next" means the first instant at which `unit` rolls over. The result is
**always strictly positive**: an instant sitting exactly on a boundary
reports one full unit, never `0`.

```dart
final dt = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);

dt.next(DateTimeUnit.usec);    // 1
dt.next(DateTimeUnit.msec);    // 544
dt.next(DateTimeUnit.second);  // 876_544            → 10:30:46.000000
dt.next(DateTimeUnit.minute);  // 14_876_544         → 10:31:00
dt.next(DateTimeUnit.hour);    // 1_754_876_544      → 11:00:00
dt.next(DateTimeUnit.day);     // 48_554_876_544     → Jan 16 00:00
dt.next(DateTimeUnit.month);   // 1_344_554_876_544  → Feb 1 00:00
dt.next(DateTimeUnit.year);    // 30_288_554_876_544 → Jan 1 2027

// On a boundary: one whole unit.
DateTime.utc(2026).next(DateTimeUnit.day);   // 86_400_000_000
DateTime.utc(2024).next(DateTimeUnit.year);  // 366 days (leap year)

// Rollover cascades: the last microsecond of a year is 1 µs from *every*
// boundary.
DateTime.utc(2026, 12, 31, 23, 59, 59, 999, 999).next(DateTimeUnit.year); // 1
```

Turn it into an instant with `add`:

```dart
final topOfHour = dt.add(Duration(microseconds: dt.next(DateTimeUnit.hour)));
```

#### `truncate({atDateTimeUnit})` — floor to a unit

Zeroes every unit finer than `atDateTimeUnit`; `month` and `day` floor to
`1`, everything else to `0`. Defaults to `DateTimeUnit.second`.

```dart
final dt = DateTime.utc(2026, 7, 19, 13, 47, 58, 321, 654);

dt.truncate();                                     // 2026-07-19 13:47:58.000000Z
dt.truncate(atDateTimeUnit: DateTimeUnit.msec);    // 2026-07-19 13:47:58.321000Z
dt.truncate(atDateTimeUnit: DateTimeUnit.hour);    // 2026-07-19 13:00:00Z
dt.truncate(atDateTimeUnit: DateTimeUnit.day);     // 2026-07-19 00:00:00Z
dt.truncate(atDateTimeUnit: DateTimeUnit.month);   // 2026-07-01 00:00:00Z
dt.truncate(atDateTimeUnit: DateTimeUnit.year);    // 2026-01-01 00:00:00Z
```

Truncation is idempotent and never moves the instant later.

#### `isWithin(other, {tolerance})` — zone-safe closeness

Symmetric, inclusive, compared on the absolute timeline. Default tolerance
is 250 µs. A negative tolerance throws `ArgumentError`.

```dart
final a = DateTime.utc(2026, 1, 15, 10, 30);

a.isWithin(a.add(const Duration(microseconds: 250)));   // true  (inclusive)
a.isWithin(a.add(const Duration(microseconds: 251)));   // false
a.isWithin(a.toLocal());                                // true  (same instant)
a.isWithin(
  a.add(const Duration(seconds: 3)),
  tolerance: const Duration(seconds: 5),
);                                                      // true
```

#### `isLeapYear`

```dart
DateTime(2024).isLeapYear;  // true
DateTime(1900).isLeapYear;  // false (century, not divisible by 400)
DateTime(2000).isLeapYear;  // true  (divisible by 400)
```

#### `toDisplay([pattern])` and `timeStamp({showMilliseconds})`

```dart
final dt = DateTime(2026, 3, 27, 17, 9, 4, 45);

dt.toDisplay();                        // Fri 27-Mar-2026 5:09:04 PM
dt.toDisplay('yyyy-MM-dd');            // 2026-03-27
ExtDateTime.uiPattern;                 // 'EEE dd-MMM-yyyy h:mm:ss a'

dt.timeStamp();                        // 17:09:04
dt.timeStamp(showMilliseconds: true);  // 17:09:04.045
```

#### `repeatEvery(unit, task)` — boundary-aligned loop

Waits for the next `unit` boundary, runs `task`, and repeats until `task`
returns `false`. The first wait is measured from the receiver, so call it
on a fresh `DateTime.now()`. Returns the instant whose boundary the loop
was waiting on when it stopped.

```dart
var ticks = 0;
final last = await DateTime.now().repeatEvery(
  DateTimeUnit.second,
  () => ++ticks < 5,   // run on five consecutive second boundaries
);
```

Prefer `BoundaryTimer` when you need to stop the loop from outside.

#### `ExtDateTime.unique({now})` — strictly increasing timestamps

Returns a `DateTime` that is guaranteed to differ from every previous call,
even in a tight loop or if the system clock steps backwards. The clock is
injectable; `reset()` (test-only) clears the internal high-water mark.

```dart
final a = ExtDateTime.unique();
final b = ExtDateTime.unique();
assert(b.microsecondsSinceEpoch > a.microsecondsSinceEpoch);

// Deterministic in tests:
final frozen = DateTime.utc(2026);
ExtDateTime.unique(now: () => frozen).microsecondsSinceEpoch; // frozen
ExtDateTime.unique(now: () => frozen).microsecondsSinceEpoch; // frozen + 1
ExtDateTime.reset();
```

### `DateTimeDelta`

An `@immutable final class` with value equality and a stable `hashCode`.
Fields: `years`, `months`, `days`, `hours`, `minutes`, `seconds`,
`milliseconds`, `microseconds` — all `int?` — and `isFuture` (`bool`).

#### Computing one

```dart
final delta = DateTimeDelta.delta(
  startTime: DateTime.utc(2024, 1, 15, 10, 30),
  endTime: DateTime.utc(2026, 3, 20, 8, 15),
);

delta.years;     // 2
delta.months;    // 2
delta.days;      // 4
delta.hours;     // 21
delta.minutes;   // 45
delta.seconds;   // 0
delta.isFuture;  // true
print(delta);    // 2y 2mo 4d 21h 45m
```

**Both instants must be UTC.** A local `DateTime` throws `ArgumentError`
rather than producing DST-dependent nonsense. Convert with `toUtc()` first.

Omit `endTime` to measure against now:

```dart
final sinceLaunch = DateTimeDelta.delta(startTime: launchedAtUtc);
```

#### Choosing the window

| Parameter           | Default      | Effect                                                                  |
| ------------------- | ------------ | ----------------------------------------------------------------------- |
| `firstDateTimeUnit` | `year`       | Coarsest unit reported. Coarser units are `null`.                       |
| `precision`         | `second`     | Finest unit reported.                                                   |
| `truncate`          | `true`       | Units finer than `precision` are `0` when `true`, `null` when `false`.  |

`firstDateTimeUnit` must not be finer than `precision`; equal is fine.

```dart
final delta = DateTimeDelta.delta(
  startTime: DateTime.utc(2026, 10, 1),
  endTime: DateTime.utc(2026, 10, 21, 14, 30, 45),
  firstDateTimeUnit: DateTimeUnit.day,
  precision: DateTimeUnit.minute,
  truncate: false,
);

delta.years;    // null  (coarser than firstDateTimeUnit)
delta.months;   // null
delta.days;     // 20
delta.hours;    // 14
delta.minutes;  // 30
delta.seconds;  // null  (finer than precision, truncate: false)
print(delta);   // 20d 14h 30m
```

Dropping coarse units never redistributes their magnitude — asking for days
and finer across a two-year span still reports `days: 4`, not `days: 795`.

#### Direction

Component magnitudes are always non-negative; direction lives only in
`isFuture`.

```dart
final past = DateTimeDelta.delta(
  startTime: DateTime.utc(2026, 3, 20, 8, 15),
  endTime: DateTime.utc(2024, 1, 15, 10, 30),
);
past.isFuture;  // false
print(past);    // -2y 2mo 4d 21h 45m
```

#### Identical instants

Return a delta with every component `null` (not `0`) and `isFuture == true`.
`toString()` renders `0`.

#### Calendar semantics

Days borrow the length of the *actual* preceding month and walk back one
month per borrow, so multi-borrow cases are correct:

```dart
// Jan 31 23:00 → Mar 1 00:00 (common year): Feb (28) isn't enough, so the
// second borrow consults Jan (31).
DateTimeDelta.delta(
  startTime: DateTime.utc(2026, 1, 31, 23),
  endTime: DateTime.utc(2026, 3),
);                        // 28d 1h

// Same span in a leap year.
DateTimeDelta.delta(
  startTime: DateTime.utc(2024, 1, 31, 23),
  endTime: DateTime.utc(2024, 3),
);                        // 29d 1h

// Feb 29 → next Feb 28 is not a year.
DateTimeDelta.delta(
  startTime: DateTime.utc(2024, 2, 29),
  endTime: DateTime.utc(2025, 2, 28),
);                        // 11mo 30d

// A whole month is absorbed when the end lands on the day after the
// start's month-end equivalent.
DateTimeDelta.delta(
  startTime: DateTime.utc(2026, 3, 31),
  endTime: DateTime.utc(2026, 5),
);                        // 1mo
```

#### Equality

```dart
const a = DateTimeDelta(isFuture: true, days: 3);
final b = DateTimeDelta.delta(
  startTime: DateTime.utc(2026),
  endTime: DateTime.utc(2026, 1, 4),
  firstDateTimeUnit: DateTimeUnit.day,
  precision: DateTimeUnit.day,
  truncate: false,
);
a == b;          // true
{a}.contains(b); // true
```

`null` and `0` are distinct: `DateTimeDelta(isFuture: true)` is not equal to
`DateTimeDelta(isFuture: true, years: 0)`.

### `BoundaryTimer`

A repeating timer that fires on the next `unit` boundary and then re-targets
the *next* boundary from the live clock after every tick. It never drifts,
never queues late callbacks, and holds at most one `Timer` at a time.

```dart
BoundaryTimer({
  required DateTimeUnit unit,
  required FutureOr<bool> Function() onTick,
  DateTime Function()? now,                                 // default: DateTime.now
  void Function(Object error, StackTrace stackTrace)? onError,
})
```

| Member     | Behaviour                                                              |
| ---------- | ---------------------------------------------------------------------- |
| `start()`  | Schedules the first tick. No-op if already active.                     |
| `stop()`   | Cancels the pending wait synchronously. No-op if idle.                 |
| `isActive` | `true` between `start()` and whichever stop happens first.             |
| `unit`     | The boundary being aligned to.                                         |

#### Basic use

```dart
final timer = BoundaryTimer(
  unit: DateTimeUnit.minute,
  onTick: () {
    refreshClockFace();
    return true;          // keep going
  },
)..start();

// Later, from anywhere:
timer.stop();
```

#### Stopping from inside the tick

Return `false`:

```dart
var remaining = 10;
BoundaryTimer(
  unit: DateTimeUnit.second,
  onTick: () => --remaining > 0,   // stops after ten boundaries
).start();
```

#### Async ticks

`onTick` may return a `Future<bool>`. The next boundary is scheduled only
after the future completes, so slow work skips boundaries rather than
piling up:

```dart
BoundaryTimer(
  unit: DateTimeUnit.hour,
  onTick: () async {
    await syncWithServer();   // may take minutes; no ticks queue behind it
    return true;
  },
).start();
```

#### Errors

A thrown error (sync or async) stops the timer and is delivered to
`onError` if provided; otherwise it is swallowed and the timer simply stops.
The timer can be restarted afterwards.

```dart
final timer = BoundaryTimer(
  unit: DateTimeUnit.second,
  onTick: riskyWork,
  onError: (error, stackTrace) {
    log.severe('tick failed', error, stackTrace);
  },
)..start();
```

#### Deterministic tests

Inject `now` and drive it with `package:fake_async`:

```dart
fakeAsync((FakeAsync fake) {
  // 500 ms before a second boundary → every wait is exactly 500 ms.
  final frozen = DateTime.utc(2026, 1, 1, 0, 0, 0, 500);
  var ticks = 0;

  final timer = BoundaryTimer(
    unit: DateTimeUnit.second,
    onTick: () => ++ticks < 3,
    now: () => frozen,
  )..start();

  fake.elapse(const Duration(milliseconds: 499));
  expect(ticks, 0);
  fake.elapse(const Duration(milliseconds: 1));
  expect(ticks, 1);
  fake.elapse(const Duration(seconds: 5));
  expect(ticks, 3);
  expect(timer.isActive, isFalse);
});
```

## Additional information

### Semantics worth knowing

- **`next()` is exclusive of the current instant.** It never returns `0`; on
  a boundary it returns one full unit.
- **Month arithmetic is calendar arithmetic.** `Mar 31 → May 1` reports
  `1mo`; `Jan 31 → Mar 1` (common year) reports `29d`, never `1mo 1d`. This
  mirrors how `DateTime`'s constructor normalises overflowed fields.
- **`DateTimeDelta` requires UTC.** Local instants are rejected, not
  converted, so a DST transition can never silently shift a result.
- **`BoundaryTimer.stop()` is synchronous.** A tick already awaiting an async
  callback finishes its work but does not reschedule.
- **`ExtDateTime.unique()` has process-wide static state.** Call
  `ExtDateTime.reset()` in `setUp` if tests depend on its first value.

### Contributing

The package is linted with `icodeforyou_lints` (built on
`very_good_analysis`) and held to 100 % LCOV coverage.

```sh
flutter analyze
flutter test --coverage
```

Every behavioural change needs a test that fails without it. The difference
algorithm has a regression suite covering single, double, and year-wrapping
borrows — extend it rather than replacing cases.

### Issues

File issues in the monorepo tracker with a minimal reproduction: the inputs
(UTC instants, unit, parameters), the result you got, and the result you
expected.