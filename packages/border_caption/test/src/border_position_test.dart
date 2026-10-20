// packages/border_caption/test/src/border_position_test.dart

import 'package:border_caption/src/border_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BorderPosition', () {
    test('has exactly top and bottom, in that order', () {
      expect(BorderPosition.values, [BorderPosition.top, BorderPosition.bottom]);
    });

    test('names', () {
      expect(BorderPosition.top.name, 'top');
      expect(BorderPosition.bottom.name, 'bottom');
    });

    test('values are distinct', () {
      expect(BorderPosition.top, isNot(BorderPosition.bottom));
    });
  });
}
