// test/src/model/rail_direction_test.dart

import 'package:animated_rail_menu/src/model/rail_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailDirection', () {
    test('has two values', () {
      expect(RailDirection.values.length, 2);
    });

    test('values are horizontal and vertical', () {
      expect(RailDirection.values, [
        RailDirection.horizontal,
        RailDirection.vertical,
      ]);
    });
  });
}
