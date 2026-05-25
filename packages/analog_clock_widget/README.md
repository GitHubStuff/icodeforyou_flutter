# Analog Clock Widget

A customizable, real-time analog clock widget for Flutter.

## Features

- Real-time updates with smooth hand movement
- Three clock face styles: Classic, Modern, Minimal
- Three hand styles: Traditional, Modern (tapered), Sleek
- Timezone support via UTC offset
- Theme-aware with full color customization
- Dependency injection for testing
- Efficient rendering with configuration caching

## Installation

```yaml
dependencies:
  analog_clock_widget: ^1.0.0
```

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  abstractions: ^1.0.0
  extensions: ^1.0.0
```

## Usage

### Basic

```dart
import 'package:analog_clock_widget/analog_clock_widget.dart';

// Default clock
AnalogClock()

// Custom size
AnalogClock(radius: 100)
```

### Styled

```dart
AnalogClock(
  radius: 120,
  style: ClockStyle(
    faceColor: Colors.white,
    borderColor: Colors.black87,
    hourHandColor: Colors.black,
    minuteHandColor: Colors.black54,
    secondHandColor: Colors.red,
    showNumbers: true,
    showSecondHand: true,
    faceStyle: ClockFaceStyle.modern,
    handStyle: HandStyle.modern,
  ),
)
```

### Timezone

```dart
// New York (UTC-5)
AnalogClock(utcMinuteOffset: -300)

// Tokyo (UTC+9)
AnalogClock(utcMinuteOffset: 540)

// London (UTC+0)
AnalogClock(utcMinuteOffset: 0)
```

### Minimal

```dart
AnalogClock(
  radius: 80,
  style: ClockStyle(
    faceStyle: ClockFaceStyle.minimal,
    handStyle: HandStyle.sleek,
    showSecondHand: false,
  ),
)
```

## API

### AnalogClock

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `radius` | `double` | `30.0` | Clock radius in pixels (min: 30) |
| `utcMinuteOffset` | `int?` | `null` | UTC offset in minutes |
| `style` | `ClockStyle` | `ClockStyle.defaultStyle` | Visual configuration |
| `timeProvider` | `TimeProvider?` | `SystemTimeProvider` | Time source (testing) |
| `themeProvider` | `ThemeProvider?` | `FlutterThemeProvider` | Theme source (testing) |

### ClockStyle

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `faceColor` | `Color?` | Theme `primaryFixed` | Clock face background |
| `borderColor` | `Color?` | Theme `secondary` | Border and tick color |
| `hourHandColor` | `Color?` | Theme `secondary` | Hour hand color |
| `minuteHandColor` | `Color?` | Hour hand color | Minute hand color |
| `secondHandColor` | `Color?` | Hour hand color | Second hand color |
| `showNumbers` | `bool` | `true` | Display hour numbers |
| `showSecondHand` | `bool` | `true` | Display second hand |
| `faceStyle` | `ClockFaceStyle` | `classic` | Face style |
| `handStyle` | `HandStyle` | `traditional` | Hand style |

### ClockFaceStyle

| Value | Description |
|-------|-------------|
| `classic` | 60 tick marks, longer marks at hours |
| `modern` | 12 hour marks only, rounded caps |
| `minimal` | Dots at 12, 3, 6, 9 only |

### HandStyle

| Value | Description |
|-------|-------------|
| `traditional` | Simple lines with rounded caps |
| `modern` | Tapered shape, wider at base |
| `sleek` | Thin elegant lines |

## Testing

Inject mock providers for deterministic tests:

```dart
class MockTimeProvider implements TimeProvider {
  @override
  DateTime get now => DateTime(2024, 6, 15, 10, 30, 45);
}

testWidgets('clock displays correct time', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AnalogClock(
        timeProvider: MockTimeProvider(),
      ),
    ),
  );
});
```

## Architecture

```
analog_clock_widget.dart       # Barrel file (exports)
src/
├── analog_clock.dart          # Widget, enums, DI interfaces
├── clock_style.dart           # Public style configuration
├── _clock_constants.dart      # Named constants
├── _clock_models.dart         # Value objects
├── _clock_painter.dart        # CustomPainter rendering
├── _clock_services.dart       # Time streaming
└── _clock_state.dart          # State management
```

### Design Principles

- **Single Responsibility**: Each class has one job
- **Dependency Inversion**: Abstractions for time and theme
- **Immutability**: All configuration objects are immutable
- **No Magic Numbers**: All values defined as named constants

## License

See LICENSE file.
