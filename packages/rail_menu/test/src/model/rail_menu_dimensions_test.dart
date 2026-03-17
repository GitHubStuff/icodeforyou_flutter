// test/src/model/rail_menu_dimensions_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

void main() {
  group('RailMenuDimensions', () {
    group('custom constructor', () {
      test('exposes itemExtent, iconSize, barExtent', () {
        const d = RailMenuDimensions(
          itemExtent: 48,
          iconSize: 20,
          barExtent: 56,
        );
        expect(d.itemExtent, equals(48));
        expect(d.iconSize, equals(20));
        expect(d.barExtent, equals(56));
      });
    });

    group('defaults constructor', () {
      test('itemExtent is 56', () =>
          expect(const RailMenuDimensions.defaults().itemExtent, equals(56)));
      test('iconSize is 24', () =>
          expect(const RailMenuDimensions.defaults().iconSize, equals(24)));
      test('barExtent is 64', () =>
          expect(const RailMenuDimensions.defaults().barExtent, equals(64)));
    });

    group('large constructor', () {
      test('itemExtent is 64', () =>
          expect(const RailMenuDimensions.large().itemExtent, equals(64)));
      test('iconSize is 28', () =>
          expect(const RailMenuDimensions.large().iconSize, equals(28)));
      test('barExtent is 72', () =>
          expect(const RailMenuDimensions.large().barExtent, equals(72)));
    });
  });
}
