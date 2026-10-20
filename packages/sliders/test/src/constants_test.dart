// packages/sliders/test/constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sliders/src/constants.dart';

void main() {
  group('Constants', () {
    test('iconSize is 48 logical pixels', () {
      expect(Constants.iconSize, 48);
    });

    test('sliderWidth is 340 logical pixels', () {
      expect(Constants.sliderWidth, 340);
    });
  });
}
