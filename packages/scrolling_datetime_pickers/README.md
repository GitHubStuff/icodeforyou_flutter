# Scrolling DateTime Pickers

Apple-style scrolling date and time picker widgets for Flutter.

## Features

- iOS-style wheel picker interface
- Infinite scrolling with automatic recentering
- Time picker with optional seconds column
- Date picker with configurable column order
- Customizable dividers with glow/blur effects
- Configurable fade effects at edges
- Haptic feedback support
- Responsive sizing for portrait/landscape
- State management with flutter_bloc

## Installation

```yaml
dependencies:
  scrolling_datetime_pickers: ^1.0.0
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  intl: ^0.20.2
```

## Usage

### Time Picker

```dart
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

ScrollingTimePicker(
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) {
    print('Selected: ${dateTime.hour}:${dateTime.minute}');
  },
)
```

### Time Picker with Options

```dart
ScrollingTimePicker(
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) => setState(() => _time = dateTime),
  showSeconds: true,
  enableHaptics: true,
  backgroundColor: Colors.white,
  timeStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  borderRadius: 12.0,
  portraitSize: Size(200, 220),
  landscapeSize: Size(300, 180),
)
```

### Date Picker

```dart
ScrollingDatePicker(
  initialDate: DateTime.now(),
  onDateChanged: (date) {
    print('Selected: ${date.year}-${date.month}-${date.day}');
  },
)
```

### Date Picker with Options

```dart
ScrollingDatePicker(
  initialDate: DateTime.now(),
  onDateChanged: (date) => setState(() => _date = date),
  dayAscending: true,  // day-month-year order
  enableHaptics: true,
  backgroundColor: Colors.grey.shade100,
  dateStyle: TextStyle(fontSize: 18),
  borderRadius: 16.0,
)
```

## Configuration

### DividerConfiguration

Customize the selection indicator dividers:

```dart
// Default dividers
ScrollingTimePicker(
  dividerConfiguration: DividerConfiguration(),
  // ...
)

// Dividers with glow effect
ScrollingTimePicker(
  dividerConfiguration: DividerConfiguration.withGlow(
    color: Colors.blue,
    transparency: 0.8,
    thickness: 2.0,
  ),
  // ...
)

// Dividers with blur effect
ScrollingTimePicker(
  dividerConfiguration: DividerConfiguration.withBlur(
    color: Colors.grey,
    blurStyle: BlurStyle.normal,
  ),
  // ...
)

// Fully custom
ScrollingTimePicker(
  dividerConfiguration: DividerConfiguration(
    color: Colors.blue,
    transparency: 1.0,
    thickness: 1.5,
    indent: 8.0,
    endIndent: 8.0,
    blurStyle: BlurStyle.outer,
    blurRadius: 2.0,
    spreadRadius: 1.0,
  ),
  // ...
)
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `color` | `Color` | `0xFFE0E0E0` | Divider line color |
| `transparency` | `double` | `1.0` | Opacity (0.0–1.0) |
| `thickness` | `double` | `1.5` | Line thickness |
| `indent` | `double` | `0.0` | Left padding |
| `endIndent` | `double` | `0.0` | Right padding |
| `blurStyle` | `BlurStyle?` | `null` | Blur effect style |
| `blurRadius` | `double` | `0.0` | Blur radius |
| `spreadRadius` | `double` | `0.0` | Glow spread radius |

### FadeConfiguration

Customize the edge fade effects:

```dart
// Default fade
ScrollingTimePicker(
  fadeConfiguration: FadeConfiguration(),
  // ...
)

// No fade
ScrollingTimePicker(
  fadeConfiguration: FadeConfiguration.noFade(),
  // ...
)

// Custom fade distance with easing
ScrollingTimePicker(
  fadeConfiguration: FadeConfiguration.withDistance(
    distance: 60.0,
    curve: Curves.easeOut,
  ),
  // ...
)

// Ease-in fade
ScrollingTimePicker(
  fadeConfiguration: FadeConfiguration.easeIn(fadeDistance: 50.0),
  // ...
)
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Enable fade effect |
| `fadeDistance` | `double` | `40.0` | Fade gradient distance |
| `fadeCurve` | `Curve` | `Curves.linear` | Fade animation curve |
| `topColors` | `List<Color>` | Dark gradient | Top fade colors |
| `bottomColors` | `List<Color>` | Dark gradient | Bottom fade colors |
| `stops` | `List<double>` | `[0.0, 1.0]` | Gradient stops |
| `selectedAlwaysOpaque` | `bool` | `true` | Keep selected item fully visible |

## API Reference

### ScrollingTimePicker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialDateTime` | `DateTime?` | `DateTime.now()` | Initial time value |
| `onDateTimeChanged` | `Function(DateTime)` | required | Change callback |
| `showSeconds` | `bool` | `false` | Show seconds column |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `backgroundColor` | `Color` | Dark gray | Background color |
| `timeStyle` | `TextStyle?` | `null` | Text style for items |
| `borderRadius` | `double` | `0.0` | Container border radius |
| `portraitSize` | `Size` | `175×200` | Size in portrait mode |
| `landscapeSize` | `Size` | `175×200` | Size in landscape mode |
| `dividerConfiguration` | `DividerConfiguration` | Default | Divider styling |
| `fadeConfiguration` | `FadeConfiguration` | Default | Fade effect styling |

### ScrollingDatePicker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialDate` | `DateTime?` | `DateTime.now()` | Initial date value |
| `onDateChanged` | `Function(DateTime)` | required | Change callback |
| `dayAscending` | `bool` | `true` | Day-month-year order (vs year-month-day) |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `backgroundColor` | `Color` | Dark gray | Background color |
| `dateStyle` | `TextStyle?` | `null` | Text style for items |
| `borderRadius` | `double` | `0.0` | Container border radius |
| `portraitSize` | `Size` | `175×200` | Size in portrait mode |
| `landscapeSize` | `Size` | `175×200` | Size in landscape mode |
| `dividerConfiguration` | `DividerConfiguration` | Default | Divider styling |
| `fadeConfiguration` | `FadeConfiguration` | Default | Fade effect styling |

## Architecture

```
lib/
├── scrolling_datetime_pickers.dart    # Barrel file
└── src/
    ├── core/
    │   ├── constants/
    │   │   ├── dimensions_constants.dart
    │   │   ├── style_constants.dart
    │   │   └── timing_constants.dart
    │   ├── mixins/
    │   │   ├── infinite_scroll_mixin.dart
    │   │   ├── picker_transform_mixin.dart
    │   │   ├── divider_rendering_mixin.dart
    │   │   └── timing_constants.dart
    │   └── models/
    │       ├── divider_configuration.dart
    │       └── fade_configuration.dart
    └── presentation/
        ├── cubits/
        │   ├── date_picker/
        │   │   ├── date_picker_cubit.dart
        │   │   └── date_picker_state.dart
        │   └── time_picker/
        │       ├── time_picker_cubit.dart
        │       └── time_picker_state.dart
        └── widgets/
            ├── scrolling_date_picker.dart
            ├── scrolling_date_picker_column.dart
            ├── scrolling_date_picker_content.dart
            ├── scrolling_time_picker.dart
            ├── scrolling_time_picker_column.dart
            └── scrolling_time_picker_content.dart
```

### Design Principles

- **Cupertino-style**: Mimics iOS wheel picker behavior
- **Infinite scroll**: Seamless wrapping with automatic recentering
- **State management**: Uses flutter_bloc for predictable state
- **Configurable**: Extensive customization via configuration objects
- **Responsive**: Adapts to portrait/landscape orientations

## License

See LICENSE file.
