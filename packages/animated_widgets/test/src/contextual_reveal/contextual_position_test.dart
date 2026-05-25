// animated_widgets/test/src/contextual_reveal/contextual_position_test.dart

import 'package:animated_widgets/src/contextual_reveal/src/contextual_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextualPosition', () {
    test('has exactly four values', () {
      expect(ContextualPosition.values, hasLength(4));
    });

    test('popover case exists', () {
      expect(ContextualPosition.values, contains(ContextualPosition.popover));
    });

    test('modal case exists', () {
      expect(ContextualPosition.values, contains(ContextualPosition.modal));
    });

    test('bottomSheet case exists', () {
      expect(
        ContextualPosition.values,
        contains(ContextualPosition.bottomSheet),
      );
    });

    test('push case exists', () {
      expect(ContextualPosition.values, contains(ContextualPosition.push));
    });

    test('values are in declaration order', () {
      expect(ContextualPosition.values, [
        ContextualPosition.popover,
        ContextualPosition.modal,
        ContextualPosition.bottomSheet,
        ContextualPosition.push,
      ]);
    });
  });
}
