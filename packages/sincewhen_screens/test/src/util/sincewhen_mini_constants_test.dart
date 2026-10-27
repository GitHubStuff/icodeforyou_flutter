// packages/sincewhen_screens/test/src/util/sincewhen_mini_constants_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart';

void main() {
  group('SinceWhenMiniDimensions', () {
    test('exposes expected layout constants', () {
      // Screen chrome
      expect(SinceWhenMiniDimensions.screenPadding, equals(16.0));

      // Two-column body
      expect(SinceWhenMiniDimensions.columnGap, equals(24.0));
      expect(SinceWhenMiniDimensions.timestampColumnFlex, equals(2));
      expect(SinceWhenMiniDimensions.textColumnFlex, equals(3));

      // Timestamp column
      expect(SinceWhenMiniDimensions.timestampRowGap, equals(16.0));
      expect(SinceWhenMiniDimensions.labelValueGap, equals(4.0));

      // Event picker field
      expect(SinceWhenMiniDimensions.eventFieldVerticalPadding, equals(8.0));
      expect(SinceWhenMiniDimensions.eventFieldHorizontalPadding, equals(12.0));
      expect(SinceWhenMiniDimensions.eventFieldBorderRadius, equals(4.0));

      // Text column
      expect(SinceWhenMiniDimensions.textFieldGap, equals(12.0));
      expect(SinceWhenMiniDimensions.contentMinLines, equals(3));
      expect(SinceWhenMiniDimensions.contentMaxLines, equals(12));
      expect(SinceWhenMiniDimensions.optionalFieldMinLines, equals(1));
      expect(SinceWhenMiniDimensions.optionalFieldMaxLines, equals(1));

      // Action bar
      expect(SinceWhenMiniDimensions.actionBarTopGap, equals(12.0));
      expect(SinceWhenMiniDimensions.actionBarButtonGap, equals(16.0));
    });
  });
}
