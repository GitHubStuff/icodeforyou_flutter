# StepSliderPackage

A customizable Flutter slider widget with increment/decrement buttons and optional haptic feedback.

## Features

- Self-contained state management via internal Cubit
- Isolated rebuilds—no parent widget interference
- Configurable step increments
- Optional haptic feedback with multiple intensity levels
- Buttons auto-disable at min/max bounds
- Fully themeable

## Installation

```yaml
dependencies:
  step_slider_package:
    path: ../step_slider_package
```

## Usage

```dart
import 'package:step_slider_package/step_slider_package.dart';

// Basic usage
StepSlider(
  initialValue: 50,
  max: 100,
  onChanged: (val) => print('Value: $val'),
)

// With haptic feedback
StepSlider(
  initialValue: 50,
  max: 100,
  step: 5,
  enableHapticFeedback: true,
  hapticFeedbackType: HapticFeedbackType.selection,
  onChanged: (val) => print('Value: $val'),
)

// Fully customized
StepSlider(
  initialValue: 1.0,
  min: 0.5,
  max: 3.0,
  step: 0.1,
  divisions: 25,
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  thumbColor: Colors.blueAccent,
  buttonColor: Colors.blue,
  buttonIconColor: Colors.white,
  buttonSize: 40.0,
  enableHapticFeedback: true,
  hapticFeedbackType: HapticFeedbackType.light,
  onChanged: (val) => print('Zoom: $val'),
)
```

## Haptic Feedback Types

| Type        | Description                        |
|-------------|------------------------------------|
| `light`     | Subtle tap (default)               |
| `medium`    | Moderate tap                       |
| `heavy`     | Strong thud                        |
| `selection` | Crisp click for discrete steps     |
| `vibrate`   | Standard vibration                 |

## API

### StepSlider

| Parameter              | Type                  | Default                     |
|------------------------|-----------------------|-----------------------------|
| `initialValue`         | `double`              | `0.0`                       |
| `min`                  | `double`              | `0.0`                       |
| `max`                  | `double`              | `100.0`                     |
| `step`                 | `double`              | `1.0`                       |
| `divisions`            | `int?`                | `null`                      |
| `label`                | `String?`             | `null`                      |
| `onChanged`            | `ValueChanged<double>?` | `null`                    |
| `activeColor`          | `Color?`              | Theme primary               |
| `inactiveColor`        | `Color?`              | Theme default               |
| `thumbColor`           | `Color?`              | Theme default               |
| `buttonColor`          | `Color?`              | Theme primary               |
| `buttonIconColor`      | `Color?`              | Theme onPrimary             |
| `buttonSize`           | `double`              | `36.0`                      |
| `enableHapticFeedback` | `bool`                | `false`                     |
| `hapticFeedbackType`   | `HapticFeedbackType`  | `HapticFeedbackType.light`  |
