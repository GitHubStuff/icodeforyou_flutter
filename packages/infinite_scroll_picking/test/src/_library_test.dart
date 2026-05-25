// test/src/_library_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('_library.dart', () {
    test('aggregates all part files', () {
      // The barrel itself contains no executable code — it stitches the
      // part files together. Instantiating one symbol from each part
      // proves all part files compile and link correctly.
      const wheelConfig =  InfiniteScrollWheelConfig();
      final pickerConfig = InfiniteScrollPickerConfig<int, String>(
        items: const [1],
        pickerId: 'p',
        startingIndex: 0,
      );
      final controller = InfiniteScrollPickerController();

      expect(wheelConfig, isA<InfiniteScrollWheelConfig>());
      expect(pickerConfig, isA<InfiniteScrollPickerConfig<int, String>>());
      expect(controller, isA<InfiniteScrollPickerController>());

      controller.dispose();
    });
  });
}
