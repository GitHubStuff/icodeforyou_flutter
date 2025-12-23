# Animated Checkbox Widget

A Flutter widget that animates a checkmark with draw and dissolve effects.

## Features

- Smooth checkmark drawing animation
- Particle-based dissolve effect when unchecking
- Customizable checkmark shape via normalized offsets
- Configurable colors, size, duration, and animation curves
- Platform-optimized particle rendering
- Completion callback for state synchronization

## Installation

```yaml
dependencies:
  animated_checkbox_widget: ^1.0.0
```

## Usage

### Basic

```dart
import 'package:animated_checkbox_widget/animated_checkbox_widget.dart';

bool isChecked = false;

AnimatedCheckbox(
  draw: isChecked,
  onAnimationComplete: (value) {
    setState(() => isChecked = value);
  },
)
```

### Styled

```dart
AnimatedCheckbox(
  width: 64.0,
  draw: isChecked,
  strokeColor: Colors.green,
  background: Colors.grey.shade200,
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutBack,
  onAnimationComplete: (value) => setState(() => isChecked = value),
)
```

### Custom Checkmark Shape

Offsets are normalized (0.0–1.0) relative to widget size:

```dart
AnimatedCheckbox(
  draw: isChecked,
  startOffset: const Offset(0.1, 0.5),   // Left point
  midOffset: const Offset(0.4, 0.8),     // Bottom point  
  finishOffset: const Offset(0.9, 0.2),  // Right point
  onAnimationComplete: (value) => setState(() => isChecked = value),
)
```

## API

### AnimatedCheckbox

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double` | `100.0` | Widget size in pixels (min: 5.0) |
| `draw` | `bool` | required | `true` to draw, `false` to dissolve |
| `strokeColor` | `Color` | `Colors.purple` | Checkmark color |
| `background` | `Color` | `Colors.transparent` | Background color |
| `duration` | `Duration` | `850ms` | Animation duration |
| `curve` | `Curve` | `Curves.easeInOutQuart` | Animation curve |
| `startOffset` | `Offset` | `(0.05, 0.52)` | Left point (normalized) |
| `midOffset` | `Offset` | `(0.45, 0.95)` | Bottom point (normalized) |
| `finishOffset` | `Offset` | `(0.95, 0.06)` | Right point (normalized) |
| `onAnimationComplete` | `ValueChanged<bool>` | required | Completion callback |

### PlatformOptimizer

Provides platform-specific rendering optimizations:

```dart
final optimizer = PlatformOptimizer();

// Get optimal particle count for widget size
int particles = optimizer.calculateOptimalParticleCount(100.0);

// Get optimal frame rate for platform
Duration frameRate = optimizer.calculateOptimalFrameRate();

// Check if high performance mode available
bool highPerf = optimizer.isHighPerformanceModeEnabled();

// Get current platform name
String platform = optimizer.getCurrentPlatformName();
```

Static methods also available:

```dart
PlatformOptimizer.getOptimalParticleCount(100.0);
PlatformOptimizer.getOptimalFrameRate();
PlatformOptimizer.shouldUseHighPerformanceMode();
PlatformOptimizer.getPlatformName();
```

### PlatformIdentifier

Testable platform detection with dependency injection:

```dart
// Default usage
const identifier = DefaultPlatformIdentifier();
print(identifier.isIOS);
print(identifier.platformName);

// Mock for testing
final mockIdentifier = DefaultPlatformIdentifier(
  iosChecker: () => true,
  androidChecker: () => false,
);
```

## Animation Behavior

### Draw Animation
When `draw: true`, the checkmark is progressively drawn from start → mid → finish using the specified curve.

### Dissolve Animation  
When `draw: false`:
1. Checkmark fades out over first 10% of duration
2. Particles explode outward from checkmark path
3. Particles fade and shrink until animation completes

## Architecture

```
animated_checkbox_widget.dart    # Barrel file (exports)
src/
├── animated_checkbox.dart       # Main widget and state
├── _checkmark_painter.dart      # CustomPainter for rendering
├── _checkmark_path_builder.dart # Path geometry calculations
├── _dissolve_particle.dart      # Particle state and physics
├── _particle_generator.dart     # Particle creation from path
├── platform_identifier.dart     # Platform detection abstraction
└── platform_optimizer.dart      # Platform-specific optimizations
```

### Design Principles

- **Single Responsibility**: Each class handles one concern
- **Dependency Injection**: Platform detection is injectable for testing
- **Immutability**: Particle and path data are immutable

## License

See LICENSE file.
