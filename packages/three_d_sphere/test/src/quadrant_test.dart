// packages/three_d_sphere/test/src/quadrant_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_sphere/src/quadrant.dart';

void main() {
  group('Quadrant', () {
    test('contains exactly 8 values in the expected reading order', () {
      expect(Quadrant.values.length, 8);

      expect(Quadrant.values[0], Quadrant.topLeft);
      expect(Quadrant.values[1], Quadrant.topCenter);
      expect(Quadrant.values[2], Quadrant.topRight);
      expect(Quadrant.values[3], Quadrant.leftCenter);
      expect(Quadrant.values[4], Quadrant.rightCenter);
      expect(Quadrant.values[5], Quadrant.bottomLeft);
      expect(Quadrant.values[6], Quadrant.bottomCenter);
      expect(Quadrant.values[7], Quadrant.bottomRight);
    });
  });
}
