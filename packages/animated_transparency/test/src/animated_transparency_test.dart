// packages/animated_transparency/test/animated_transparency_test.dart

import 'package:test/test.dart';

import '../../lib/animated_transparency.dart' show AnimatedTransparency;

void main() {
  group('AnimatedTransparency', () {
    late AnimatedTransparency animatedTransparency;

    setUp(() {
      animatedTransparency = AnimatedTransparency();
    });

    test('can be instantiated', () {
      expect(animatedTransparency, isA<AnimatedTransparency>());
    });
  });
}
