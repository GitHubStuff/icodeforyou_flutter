// test/src/model/rail_menu_direction_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

void main() {
  group('RailMenuDirection', () {
    test('has four values', () {
      expect(RailMenuDirection.values, hasLength(4));
    });

    test('contains top, bottom, left, right', () {
      expect(
        RailMenuDirection.values,
        containsAll([
          RailMenuDirection.top,
          RailMenuDirection.bottom,
          RailMenuDirection.left,
          RailMenuDirection.right,
        ]),
      );
    });
  });
}
