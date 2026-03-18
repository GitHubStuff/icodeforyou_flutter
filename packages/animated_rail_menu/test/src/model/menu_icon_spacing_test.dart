// test/src/model/menu_icon_spacing_test.dart

import 'package:animated_rail_menu/src/model/menu_icon_spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuIconSpacing', () {
    test('has two values', () {
      expect(MenuIconSpacing.values.length, 2);
    });

    test('values are expanded and collapsed', () {
      expect(MenuIconSpacing.values, [
        MenuIconSpacing.expanded,
        MenuIconSpacing.collapsed,
      ]);
    });
  });
}
