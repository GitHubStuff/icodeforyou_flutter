// packages/animated_barrier/test/src/popover_position_test.dart

import 'package:animated_widgets/animated_widgets.dart' show PopoverPosition;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PopoverPosition factories', () {
    test('PopoverPosition.left returns a PopoverPosition', () {
      final key = GlobalKey();
      expect(PopoverPosition.left(key), isA<PopoverPosition>());
    });

    test('PopoverPosition.right returns a PopoverPosition', () {
      final key = GlobalKey();
      expect(PopoverPosition.right(key), isA<PopoverPosition>());
    });

    test('PopoverPosition.above returns a PopoverPosition', () {
      final key = GlobalKey();
      expect(PopoverPosition.above(key), isA<PopoverPosition>());
    });

    test('PopoverPosition.below returns a PopoverPosition', () {
      final key = GlobalKey();
      expect(PopoverPosition.below(key), isA<PopoverPosition>());
    });

    test('PopoverPosition.center returns a PopoverPosition', () {
      expect(PopoverPosition.center(), isA<PopoverPosition>());
    });
  });

  // Behavioral coverage of the fallback chain and anchor rect resolution
  // happens in animated_barrier_test.dart, where positions are exercised via
  // a real overlay and layout pass.
}
