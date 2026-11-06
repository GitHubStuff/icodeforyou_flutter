// packages/popover_toast/test/src/popover_toast_test.dart

import 'package:test/test.dart';

import '../../lib/popover_toast.dart' show PopoverToast;

void main() {
  group('PopoverToast', () {
    late PopoverToast popoverToast;

    setUp(() {
      popoverToast = PopoverToast();
    });

    test('can be instantiated', () {
      expect(popoverToast, isA<PopoverToast>());
    });
  });
}
