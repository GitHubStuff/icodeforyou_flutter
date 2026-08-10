// test/enum/src/window_size_category_test.dart

import 'package:extensions/enum/src/window_size_category.dart'
    show WindowSizeCategory;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WindowSizeCategory', () {
    test('declares five categories ordered narrowest to widest', () {
      expect(WindowSizeCategory.values, const <WindowSizeCategory>[
        WindowSizeCategory.compact,
        WindowSizeCategory.medium,
        WindowSizeCategory.expanded,
        WindowSizeCategory.large,
        WindowSizeCategory.extraLarge,
      ]);
    });

    test('carries the Material breakpoint upper bounds', () {
      expect(WindowSizeCategory.compact.upperBound, 600);
      expect(WindowSizeCategory.medium.upperBound, 840);
      expect(WindowSizeCategory.expanded.upperBound, 1200);
      expect(WindowSizeCategory.large.upperBound, 1600);
      expect(WindowSizeCategory.extraLarge.upperBound, double.infinity);
    });

    test('upper bounds strictly increase so ranges never overlap', () {
      for (var i = 1; i < WindowSizeCategory.values.length; i++) {
        expect(
          WindowSizeCategory.values[i].upperBound,
          greaterThan(WindowSizeCategory.values[i - 1].upperBound),
        );
      }
    });
  });
}
