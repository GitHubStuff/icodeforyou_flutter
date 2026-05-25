// animated_rail_menu/test/src/model/rail_direction_test.dart

import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailDirection', () {
    test('has three values', () {
      expect(RailDirection.values.length, 3);
    });

    test('values are adaptive, horizontal and vertical', () {
      expect(RailDirection.values, [
        RailDirection.adaptive,
        RailDirection.horizontal,
        RailDirection.vertical,
      ]);
    });
  });
}
