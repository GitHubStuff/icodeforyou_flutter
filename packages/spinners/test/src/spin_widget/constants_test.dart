// packages/spinners/test/src/spin_widget/constants_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:spinners/src/spin_widget/constants.dart' show degreesPerTurn;

void main() {
  group('constants', () {
    test('degreesPerTurn is one full revolution', () {
      expect(degreesPerTurn, 360);
    });
  });
}
