# Extensions

A collection of Dart and Flutter extension methods for common types.

## Features

- **Widget extensions** — Chainable methods for padding, borders, opacity, visibility
- **DateTime extensions** — Unique timestamps, truncation, delta calculations, formatting
- **String extensions** — Date parsing utilities
- **Int extensions** — Microsecond to DateTime conversion

## Installation

```yaml
dependencies:
  extensions: ^1.0.0
```

## Usage

```dart
import 'package:extensions/extensions.dart';
```

---

## Widget Extensions

Chainable methods for composing widget decorations.

```dart
Text('Hello')
  .withPaddingAll(16.0)
  .withBackground(color: Colors.blue)
  .withBorder(color: Colors.black, width: 2.0, radius: 8.0)
  .withOpacity(0.9);
```

### Methods

| Method | Description |
|--------|-------------|
| `hide(bool)` | Makes widget transparent (maintains layout space) |
| `remove(bool)` | Removes widget from tree (`SizedBox.shrink`) |
| `withBackground(color:)` | Wraps with solid background color |
| `withBorder(color:, width:, radius:, style:)` | Adds customizable border |
| `withOpacity(double)` | Sets opacity (0.0–1.0) |
| `withPaddingAll(double)` | Uniform padding on all sides |
| `withPaddingOnly(left:, top:, right:, bottom:)` | Individual side padding |
| `withPaddingSymmetric(horizontal:, vertical:)` | Symmetric axis padding |

### Examples

```dart
// Conditional visibility
MyWidget()
  .hide(isLoading)      // Transparent when loading
  .remove(shouldHide);  // Removed from tree when hidden

// Complex padding
Container()
  .withPaddingOnly(left: 16.0, top: 8.0)
  .withPaddingSymmetric(horizontal: 24.0);
```

---

## DateTime Extensions

### Unique Timestamps

Generate guaranteed-unique timestamps for database keys:

```dart
final timestamp = await DateTimeExt.unique();
```

Handles clock drift automatically with configurable threshold.

### Truncation

Truncate DateTime to specific precision:

```dart
final now = DateTime.now();

now.truncate(atDateTimeUnit: DateTimeUnit.day);    // Start of day
now.truncate(atDateTimeUnit: DateTimeUnit.hour);   // Start of hour
now.truncate(atDateTimeUnit: DateTimeUnit.second); // Default
```

### DateTimeUnit

Enum with time constants and utilities:

```dart
// Create truncated timestamps
final local = DateTimeUnit.makeLocal(DateTime.now(), truncateAt: DateTimeUnit.minute);
final utc = DateTimeUnit.makeUtc(DateTime.now(), truncateAt: DateTimeUnit.second);

// Constants
DateTimeUnit.kHoursPerDay      // 24
DateTimeUnit.kMinutesPerHour   // 60
DateTimeUnit.kSecondsPerMinute // 60
DateTimeUnit.kMsecPerSecond    // 1000
```

### DateTime Delta

Calculate human-readable differences between dates:

```dart
final delta = DateTimeDelta.delta(
  startTime: pastDate.toUtc(),
  endTime: DateTime.now().toUtc(),
  firstDateTimeUnit: DateTimeUnit.year,
  precision: DateTimeUnit.second,
);

print(delta); // "2y 3mo 15d 4h 30m 22s"
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `startTime` | `DateTime` | required | Start time (must be UTC) |
| `endTime` | `DateTime?` | `DateTime.now()` | End time (must be UTC) |
| `firstDateTimeUnit` | `DateTimeUnit` | `year` | Largest unit to include |
| `precision` | `DateTimeUnit` | `second` | Smallest unit to include |
| `truncate` | `bool` | `true` | Zero-fill units below precision |

#### Properties

```dart
delta.years       // int?
delta.months      // int?
delta.days        // int?
delta.hours       // int?
delta.minutes     // int?
delta.seconds     // int?
delta.milliseconds // int?
delta.microseconds // int?
delta.isFuture    // bool - true if endTime >= startTime
```

### Delta Formatting

Custom format strings with conditional rendering:

```dart
// Default format
delta.format(); // "2y 3mo 15d 4h 30m 22s"

// Custom format
delta.format(r'${D} days, ${hh}:${mm}:${ss}');
```

#### Format Syntax

| Token | Description |
|-------|-------------|
| `${X}` | Always show unit X |
| `$*{X}` | Show only if value > 0 |
| `${X>}` | Cascade: show if this or higher unit > 0 |
| `${XX}` | Zero-pad to width (e.g., `${hh}` → "04") |
| `${[X]}` | Wrap value in brackets |

#### Unit Symbols

| Symbol | Unit |
|--------|------|
| `Y` | Years |
| `M` | Months |
| `D` | Days |
| `h` | Hours |
| `m` | Minutes |
| `s` | Seconds |
| `S` | Milliseconds |
| `u` | Microseconds |

### DateTimeDeltaText Widget

Display formatted delta in a Text widget:

```dart
DateTimeDeltaText(
  delta: myDelta,
  format: r'${D}d ${hh}:${mm}:${ss}',
  style: TextStyle(fontSize: 16),
  leading: Icon(Icons.timer),
  trailing: Text(' elapsed'),
)
```

### DateTimeOrdering

Compare two DateTime objects:

```dart
final ordering = DateTimeOrdering.direction(start, end);

switch (ordering) {
  case DateTimeOrdering.before: // start < end
  case DateTimeOrdering.after:  // start > end
  case DateTimeOrdering.now:    // start == end
}
```

---

## String Extensions

```dart
// Parse date string to microseconds (null-safe)
final micros = "2024-01-15T10:30:00Z".toMicrosecondsOrNull();
```

---

## Int Extensions

```dart
// Convert microseconds to UTC DateTime
final dateTime = 1705312200000000.toUtc();
```

---

## Architecture

```
lib/
├── extensions.dart              # Main barrel file
├── widget_ext/
│   └── widget_ext.dart          # Widget extension methods
├── string_ext/
│   └── string_ext.dart          # String extension methods
├── int_ext/
│   └── int_ext.dart             # Int extension methods
└── datetime_ext/
    ├── datetime_ext.dart        # DateTime barrel file
    ├── datetime_extension.dart  # Core DateTime extensions
    ├── datetime_unit.dart       # DateTimeUnit enum
    ├── datetime_delta.dart      # DateTimeDelta class
    ├── datetime_delta_format.dart # Format extension
    ├── datetime_delta_text.dart # Text widget
    └── datetime_ordering.dart   # Ordering enum
```

## License

See LICENSE file.
