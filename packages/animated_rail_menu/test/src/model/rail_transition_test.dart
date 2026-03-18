// test/src/model/rail_transition_test.dart

import 'package:animated_rail_menu/src/model/rail_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailTransition', () {
    test('has seven values', () {
      expect(RailTransition.values.length, 7);
    });

    test('values are correct', () {
      expect(RailTransition.values, [
        RailTransition.crossFade,
        RailTransition.slideLeft,
        RailTransition.slideRight,
        RailTransition.slideDirectional,
        RailTransition.scale,
        RailTransition.slideUp,
        RailTransition.slideDown,
      ]);
    });
  });
}
