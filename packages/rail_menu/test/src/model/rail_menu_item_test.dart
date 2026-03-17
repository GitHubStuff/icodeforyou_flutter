// test/src/model/rail_menu_item_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

void main() {
  group('RailMenuTransition', () {
    test('has four values', () {
      expect(RailMenuTransition.values, hasLength(4));
    });

    test('contains all expected cases', () {
      expect(
        RailMenuTransition.values,
        containsAll([
          RailMenuTransition.slideFromLeft,
          RailMenuTransition.slideFromRight,
          RailMenuTransition.fade,
          RailMenuTransition.none,
        ]),
      );
    });
  });

  group('RailMenuItem', () {
    test('defaults are applied', () {
      const item = RailMenuItem(child: SizedBox.shrink());
      expect(item.onTap, isNull);
      expect(item.enableHaptic, isTrue);
      expect(item.transitionFromLeft, equals(RailMenuTransition.slideFromLeft));
      expect(
        item.transitionFromRight,
        equals(RailMenuTransition.slideFromRight),
      );
    });

    test('accepts custom values', () {
      var tapped = false;
      final item = RailMenuItem(
        child: const SizedBox.shrink(),
        onTap: () => tapped = true,
        enableHaptic: false,
        transitionFromLeft: RailMenuTransition.fade,
        transitionFromRight: RailMenuTransition.none,
      );
      item.onTap?.call();
      expect(tapped, isTrue);
      expect(item.enableHaptic, isFalse);
      expect(item.transitionFromLeft, equals(RailMenuTransition.fade));
      expect(item.transitionFromRight, equals(RailMenuTransition.none));
    });
  });
}
