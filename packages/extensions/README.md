# extensions

A collection of focused Dart and Flutter extensions on `String`, `int`, `Color`, `DateTime`, `Iterable`, and `Widget`, plus a `HapticIntensity` enum that wraps `HapticFeedback`. One import, eight categories, no third-party runtime dependencies.

## Features

- **`ColorExtension`** on `Color` — channel-wise equality, contrast text picker, 32-bit ARGB integer round-trip.
- **`NullableColorConverter`** — drop-in `JsonConverter<Color?, int?>` for `json_serializable` models.
- **`DateTimeExt`** on `DateTime` — `unique()` for monotonically increasing timestamps, `timeStamp()` for `HH:mm:ss.SSS` formatting, `truncate(...)` to a `DateTimeUnit` precision.
- **`DateTimeDelta`** — immutable, component-wise delta between two `DateTime` values with configurable largest/smallest unit and a flexible format DSL via `DateTimeDeltaFormat`.
- **`DateTimeDeltaText`** widget — renders a formatted delta as a `Text` widget with full `Text` parameter pass-through plus optional `leading` / `trailing`.
- **`DateTimeUnit`** enum — year through microsecond, with calendar constants and `makeLocal` / `makeUtc` truncation helpers.
- **`HapticIntensity`** enum — `light`, `medium`, `heavy`, `selection`, `vibrate`, `none`, with a single `trigger()` method that fires the matching `HapticFeedback` call.
- **`IntExt`** on `int` — `toColor()` (32-bit ARGB) and `toUtc()` (microsecond epoch → UTC `DateTime`).
- **`IterableExt.checkForCycles`** — generic cycle detection for any dependency graph; throws `StateError` with the offending path.
- **`StringExt`** on `String` — `renderSize(...)` measures pixel width/height via `TextPainter`; `toMicrosecondsOrNull()` parses ISO 8601 into a microsecond epoch.
- **`WidgetExt`** on `Widget` — chainable wrappers: `hide`, `remove`, `withBackground`, `withBorder`, `withOpacity`, `withPaddingAll`, `withPaddingOnly`, `withPaddingSymmetric`.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  extensions: ^1.0.2
```

Then import the barrel where you need any of the extensions:

```dart
import 'package:extensions/extensions.dart';
```

The barrel re-exports everything listed above. Individual sub-barrels (`color_ext`, `datetime_ext`, etc.) are also importable when you want to keep imports tight.

## Usage

### `ColorExtension` — equality, contrast, integer round-trip

```dart
const a = Color(0xFF336699);
const b = Color(0xFF336699);

a.equals(b);                  // true — channel-wise compare
a.contrastingTextColor();     // Color(0xFFFFFFFF) — white reads better
final argb = a.toInt();       // 0xFF336699

// Round-trip via int_ext:
argb.toColor();               // Color(0xFF336699)
```

### `NullableColorConverter` — JSON serialization

Drop it on a `@JsonSerializable` model field to round-trip a nullable `Color` through an `int?`:

```dart
@JsonSerializable()
class Theme {
  Theme({this.accent});

  @NullableColorConverter()
  final Color? accent;

  factory Theme.fromJson(Map<String, dynamic> json) => _$ThemeFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeToJson(this);
}
```

> **Note:** `NullableColorConverter` imports `package:json_annotation`. The package is not declared in this package's `pubspec.yaml`, so you'll need to add `json_annotation` to your own `dependencies` if you use the converter.

### `DateTimeExt` — uniqueness, timestamps, truncation

```dart
// A microsecond-unique DateTime even on a clock that doesn't tick fast enough.
final t = await DateTimeExt.unique();

// Fixed-width clock-style timestamp:
DateTime.now().timeStamp();              // '14:07:33.421'

// Truncate to a precision:
DateTime(2026, 5, 20, 14, 7, 33, 421)
    .truncate(atDateTimeUnit: DateTimeUnit.minute);
// 2026-05-20 14:07:00.000
```

`DateTimeUnit.makeLocal(null)` and `DateTimeUnit.makeUtc(null)` are shorthand for "now, truncated to seconds, in the requested zone."

### `DateTimeDelta` — component-wise time differences

`DateTimeDelta.delta(...)` computes a delta between two UTC `DateTime` values, with the largest and smallest units configurable:

```dart
final start = DateTime.utc(2024, 1, 1, 9);
final end = DateTime.utc(2026, 5, 20, 14, 30);

final d = DateTimeDelta.delta(
  startTime: start,
  endTime: end,
  firstDateTimeUnit: DateTimeUnit.year,
  precision: DateTimeUnit.minute,
);

d.toString();          // '2y 4mo 19d 5h 30m'
d.format();            // uses the default pattern
d.format(r'${D}d ${hh}:${mm}');   // '869d 05:30' — custom pattern
```

The `format` DSL supports star-gating (`$*{...}` — only render when the value is non-zero) and cascade (`>` — only render when this unit or any larger unit is non-zero), plus zero-padding via repeated symbols (e.g. `hh` for two-digit hours). The full grammar is documented on `DateTimeDeltaFormat.format`.

### `DateTimeDeltaText` — drop-in widget

Renders a `DateTimeDelta` as text with full `Text` parameter pass-through:

```dart
DateTimeDeltaText(
  delta: DateTimeDelta.delta(startTime: startedAt.toUtc()),
  format: r'${hh}:${mm}:${ss}',
  style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
  leading: const Icon(Icons.timer_outlined, size: 16),
)
```

### `HapticIntensity` — single-call haptics

```dart
HapticIntensity.medium.trigger();   // HapticFeedback.mediumImpact()
HapticIntensity.selection.trigger();// HapticFeedback.selectionClick()
HapticIntensity.none.trigger();     // no-op
```

Pass `HapticIntensity` as a configuration field on your own widgets — `HapticIntensity.none` is a clean "off" without a separate boolean.

### `IntExt` — int conversions

```dart
0xFF336699.toColor();                 // Color(0xFF336699)
1747750053000000.toUtc();             // DateTime in UTC, parsed from a microsecond epoch
```

Pairs naturally with `StringExt.toMicrosecondsOrNull()` and `ColorExtension.toInt()` for symmetric round-trips.

### `IterableExt.checkForCycles` — generic graph validation

Detects circular dependencies in any iterable whose items expose an id and a list of dependency ids. Throws `StateError` with the full cycle path:

```dart
final services = [
  ServiceSpec(id: 'a', deps: ['b']),
  ServiceSpec(id: 'b', deps: ['c']),
  ServiceSpec(id: 'c', deps: ['a']),
];

services.checkForCycles(
  idOf: (s) => s.id,
  dependenciesOf: (s) => s.deps,
);
// throws StateError: Circular dependency detected: a -> b -> c -> a
```

An unknown dependency id also throws — useful at startup validation time, before any wiring runs.

### `StringExt` — layout measurement and date parsing

```dart
final size = 'Hello world'.renderSize(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
// (width: 89.4..., height: 19.0...)

'2026-05-20T14:07:33Z'.toMicrosecondsOrNull();
// 1747750053000000

'not a date'.toMicrosecondsOrNull();
// null
```

`renderSize` is the right tool when you need to size a container, badge, or chip to its text content before the text itself has been laid out.

### `WidgetExt` — chainable wrappers

A focused set of wrapper extensions, each doing one thing:

```dart
Text('Saved')
    .withPaddingSymmetric(horizontal: 16, vertical: 8)
    .withBackground(color: Colors.green.shade100)
    .withBorder(color: Colors.green, width: 1, radius: 8)
    .withOpacity(0.95)
    .hide(!_justSaved);

ErrorBanner()
    .remove(!_hasError);
```

`hide(true)` keeps the layout slot and only zeroes opacity; `remove(true)` returns a `SizedBox.shrink()` and gives the slot back. `withBorder`, `withOpacity`, and the padding methods throw `ArgumentError` on negative or out-of-range values.

## Additional information

Each sub-folder ships its own barrel (`color_ext.dart`, `datetime_ext.dart`, etc.), so if you only need one area you can import that barrel instead of the full one. The package has no third-party runtime dependencies — only `flutter`. If you use `NullableColorConverter`, add `json_annotation` to your own `pubspec.yaml`.
