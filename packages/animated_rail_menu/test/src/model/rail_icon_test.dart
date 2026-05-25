// animated_rail_menu/test/src/model/rail_icon_test.dart

import 'package:animated_rail_menu/src/model/rail_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailIcon', () {
    test('has seven values', () {
      expect(RailIcon.values.length, 7);
    });

    group('smallPhone', () {
      test('has correct sizing', () {
        expect(RailIcon.smallPhone.iconSize, 20);
        expect(RailIcon.smallPhone.itemExtent, 48);
        expect(RailIcon.smallPhone.barExtent, 56);
        expect(RailIcon.smallPhone.indicatorHeight, 2);
      });
    });

    group('phone', () {
      test('has correct sizing', () {
        expect(RailIcon.phone.iconSize, 24);
        expect(RailIcon.phone.itemExtent, 56);
        expect(RailIcon.phone.barExtent, 64);
        expect(RailIcon.phone.indicatorHeight, 3);
      });
    });

    group('smallTablet', () {
      test('has correct sizing', () {
        expect(RailIcon.smallTablet.iconSize, 24);
        expect(RailIcon.smallTablet.itemExtent, 60);
        expect(RailIcon.smallTablet.barExtent, 68);
        expect(RailIcon.smallTablet.indicatorHeight, 3);
      });
    });

    group('tablet', () {
      test('has correct sizing', () {
        expect(RailIcon.tablet.iconSize, 28);
        expect(RailIcon.tablet.itemExtent, 64);
        expect(RailIcon.tablet.barExtent, 72);
        expect(RailIcon.tablet.indicatorHeight, 4);
      });
    });

    group('largeTablet', () {
      test('has correct sizing', () {
        expect(RailIcon.largeTablet.iconSize, 28);
        expect(RailIcon.largeTablet.itemExtent, 68);
        expect(RailIcon.largeTablet.barExtent, 80);
        expect(RailIcon.largeTablet.indicatorHeight, 4);
      });
    });

    group('desktop', () {
      test('has correct sizing', () {
        expect(RailIcon.desktop.iconSize, 20);
        expect(RailIcon.desktop.itemExtent, 48);
        expect(RailIcon.desktop.barExtent, 56);
        expect(RailIcon.desktop.indicatorHeight, 2);
      });
    });

    group('web', () {
      test('has correct sizing', () {
        expect(RailIcon.web.iconSize, 20);
        expect(RailIcon.web.itemExtent, 44);
        expect(RailIcon.web.barExtent, 52);
        expect(RailIcon.web.indicatorHeight, 2);
      });
    });
  });
}
