// test/infinite_scroll_picking_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('infinite_scroll_picking library', () {
    test('exports public API symbols', () {
      // Touching each exported type ensures the export directives in
      // lib/infinite_scroll_picking.dart are evaluated (and counted by lcov).
      expect(InfiniteScrollPicker, isNotNull);
      expect(InfiniteScrollPickerConfig, isNotNull);
      expect(InfiniteScrollPickerController, isNotNull);
      expect(InfiniteScrollWheelConfig, isNotNull);
    });
  });
}
