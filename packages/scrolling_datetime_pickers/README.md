# Scrolling DateTime Pickers

Apple-style scrolling date and time picker widgets for Flutter with smooth animations, haptic feedback, and extensive customization options.

## Features

- **ScrollingDatePicker** - iOS-style scrolling date picker (day, month, year)
- **ScrollingTimePicker** - iOS-style scrolling time picker (hour, minute, second, AM/PM)
- **DateTimePickerPopover** - Combined date/time picker in a popover overlay
- **DateTimePickerField** - Convenience wrapper that shows popover on tap
- Smooth infinite scrolling with snap-to-item behavior
- Haptic feedback on selection changes
- Customizable dividers with glow/blur effects
- Configurable fade gradients (light/dark theme presets)
- Portrait and landscape size support

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  scrolling_datetime_pickers:
    path: packages/scrolling_datetime_pickers
```

## Usage

### Import

```dart
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
```

### ScrollingDatePicker

Basic date picker with day, month, and year columns:

```dart
ScrollingDatePicker(
  initialDate: DateTime.now(),
  onDateChanged: (date) {
    print('Selected: ${date.year}-${date.month}-${date.day}');
  },
)
```

With custom styling:

```dart
ScrollingDatePicker(
  initialDate: DateTime.now(),
  onDateChanged: (date) => print(date),
  backgroundColor: const Color(0xFF1A1A2E),
  borderRadius: 12.0,
  dateStyle: const TextStyle(
    color: Colors.white,
    fontSize: 18,
  ),
  dividerConfiguration: DividerConfiguration.withGlow(
    color: Colors.blue,
  ),
  fadeConfiguration: FadeConfiguration.dark(),
  dayAscending: true,  // Day-Month-Year order
  enableHaptics: true,
)
```

### ScrollingTimePicker

Basic time picker with hour, minute, and AM/PM:

```dart
ScrollingTimePicker(
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) {
    print('Selected: ${dateTime.hour}:${dateTime.minute}');
  },
)
```

With seconds column:

```dart
ScrollingTimePicker(
  initialDateTime: DateTime.now(),
  showSeconds: true,
  onDateTimeChanged: (dateTime) {
    print('${dateTime.hour}:${dateTime.minute}:${dateTime.second}');
  },
)
```

### DateTimePickerPopover

Show a combined date/time picker in a popover near an anchor widget:

```dart
final GlobalKey _anchorKey = GlobalKey();

// In your build method:
GestureDetector(
  key: _anchorKey,
  onTap: () async {
    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _anchorKey,
      initialDateTime: DateTime.now(),
      option: DateTimeOption.dateTime,
    );
    
    if (result != null) {
      print('Selected: $result');
    }
  },
  child: Text('Tap to select date/time'),
)
```

#### DateTimeOption Modes

```dart
// Both date and time with toggle buttons
option: DateTimeOption.dateTime

// Date picker only
option: DateTimeOption.date

// Time picker only  
option: DateTimeOption.time
```

#### Light Theme Popover

```dart
DateTimePickerPopover.show(
  context: context,
  anchorKey: _anchorKey,
  popoverBackgroundColor: const Color(0xFFF5F5F5),
  pickerBackgroundColor: Colors.white,
  headerDateTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
  headerTimeTextStyle: const TextStyle(color: Colors.black87, fontSize: 18),
  dateButtonTextStyle: const TextStyle(color: Colors.black87),
  timeButtonTextStyle: const TextStyle(color: Colors.black87),
  dateStyle: const TextStyle(color: Colors.black87, fontSize: 20),
  timeStyle: const TextStyle(color: Colors.black87, fontSize: 20),
  fadeConfiguration: FadeConfiguration.light(),
  dividerConfiguration: const DividerConfiguration(color: Colors.black12),
)
```

#### Dark Theme Popover

```dart
DateTimePickerPopover.show(
  context: context,
  anchorKey: _anchorKey,
  popoverBackgroundColor: const Color(0xFF2D2D2D),
  pickerBackgroundColor: const Color(0xFF1E1E1E),
  headerDateTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
  headerTimeTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
  dateButtonTextStyle: const TextStyle(color: Colors.white),
  timeButtonTextStyle: const TextStyle(color: Colors.white),
  dateStyle: const TextStyle(color: Colors.white, fontSize: 20),
  timeStyle: const TextStyle(color: Colors.white, fontSize: 20),
  fadeConfiguration: FadeConfiguration.dark(),
)
```

### DateTimePickerField

Convenience wrapper that automatically handles the anchor key and tap gesture:

```dart
DateTimePickerField(
  onDateTimeSelected: (dateTime) {
    if (dateTime != null) {
      setState(() => _selectedDateTime = dateTime);
    }
  },
  initialDateTime: _selectedDateTime,
  option: DateTimeOption.dateTime,
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(_selectedDateTime?.toString() ?? 'Select date/time'),
  ),
)
```

## Configuration Classes

### DividerConfiguration

Customize the horizontal divider lines that highlight the selected row:

```dart
// Default
const DividerConfiguration()

// With glow effect
DividerConfiguration.withGlow(
  color: Colors.blue,
  transparency: 0.9,
)

// With blur effect
DividerConfiguration.withBlur(
  color: Colors.purple,
  transparency: 0.8,
)

// Fully custom
DividerConfiguration(
  color: Colors.cyan,
  thickness: 2.0,
  transparency: 1.0,
  indent: 16.0,
  endIndent: 16.0,
  blurStyle: BlurStyle.outer,
  blurRadius: 4.0,
  spreadRadius: 2.0,
)
```

### FadeConfiguration

Customize the fade gradient at top and bottom edges:

```dart
// Default (dark theme)
const FadeConfiguration()

// Light theme preset
FadeConfiguration.light()

// Dark theme preset
FadeConfiguration.dark()

// Auto-generate from background color
FadeConfiguration.forBackground(Colors.white)

// No fade effect
FadeConfiguration.noFade()

// Fully custom
FadeConfiguration(
  enabled: true,
  fadeDistance: 40.0,
  topColors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
  bottomColors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
)
```

## API Reference

### ScrollingDatePicker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialDate` | `DateTime?` | `null` | Initial selected date |
| `onDateChanged` | `Function(DateTime)` | required | Callback when date changes |
| `portraitSize` | `Size` | `Size(200, 200)` | Size in portrait orientation |
| `landscapeSize` | `Size` | `Size(280, 150)` | Size in landscape orientation |
| `backgroundColor` | `Color` | Dark blue | Background color |
| `dateStyle` | `TextStyle?` | `null` | Text style for date items |
| `dividerConfiguration` | `DividerConfiguration` | default | Divider styling |
| `fadeConfiguration` | `FadeConfiguration` | default | Fade gradient styling |
| `dayAscending` | `bool` | `true` | Day-Month-Year (true) or Year-Month-Day (false) |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `borderRadius` | `double` | `0.0` | Corner radius |

### ScrollingTimePicker

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initialDateTime` | `DateTime?` | `null` | Initial selected time |
| `onDateTimeChanged` | `Function(DateTime)` | required | Callback when time changes |
| `portraitSize` | `Size` | `Size(200, 200)` | Size in portrait orientation |
| `landscapeSize` | `Size` | `Size(280, 150)` | Size in landscape orientation |
| `backgroundColor` | `Color` | Dark blue | Background color |
| `timeStyle` | `TextStyle?` | `null` | Text style for time items |
| `dividerConfiguration` | `DividerConfiguration` | default | Divider styling |
| `fadeConfiguration` | `FadeConfiguration` | default | Fade gradient styling |
| `showSeconds` | `bool` | `false` | Show seconds column |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `borderRadius` | `double` | `0.0` | Corner radius |

### DateTimePickerPopover.show()

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `context` | `BuildContext` | required | Build context |
| `anchorKey` | `GlobalKey` | required | Key of anchor widget |
| `initialDateTime` | `DateTime?` | `null` | Initial selected datetime |
| `option` | `DateTimeOption` | `dateTime` | Picker mode |
| `dateFormat` | `String` | `'EEE, dd-MMM-yyyy'` | Header date format |
| `timeFormat` | `String` | `'hh:mm:ss a'` | Header time format |
| `showSeconds` | `bool` | `true` | Show seconds in time picker |
| `popoverBackgroundColor` | `Color` | Dark grey | Popover background |
| `pickerBackgroundColor` | `Color?` | `null` | Picker area background |
| `dateButtonColor` | `Color` | Blue | DATE tab selected color |
| `timeButtonColor` | `Color` | Purple | TIME tab selected color |
| `confirmButtonColor` | `Color` | Green | Confirm button color |
| `confirmButtonText` | `String` | `'Set'` | Confirm button text |
| `fadeConfiguration` | `FadeConfiguration?` | auto | Fade styling |
| `dividerConfiguration` | `DividerConfiguration?` | default | Divider styling |
| `enableHaptics` | `bool` | `true` | Enable haptic feedback |
| `dayAscending` | `bool` | `true` | Date column order |

## Dependencies

- `flutter_bloc: ^9.1.1` - State management for picker cubits
- `intl` - Date/time formatting

## License

MIT
