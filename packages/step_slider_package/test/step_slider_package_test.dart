// test/step_slider_package_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:step_slider_package/step_slider_package.dart';

void main() {
  group('step_slider_package exports', () {
    test('exports StepSlider', () {
      expect(StepSlider, isNotNull);
    });

    test('exports HapticFeedbackType', () {
      expect(HapticFeedbackType.values, isNotEmpty);
    });

    test('HapticFeedbackType has all expected values', () {
      expect(HapticFeedbackType.values, containsAll([
        HapticFeedbackType.light,
        HapticFeedbackType.medium,
        HapticFeedbackType.heavy,
        HapticFeedbackType.selection,
        HapticFeedbackType.vibrate,
      ]));
    });
  });
}
