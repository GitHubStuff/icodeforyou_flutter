// packages/animated_barrier/test/animated_barrier_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('animated_barrier barrel', () {
    test('exports public surface', () {
      // Touch each public symbol so the barrel file is exercised by LCOV.
      expect(const FadeBarrier(), isA<BarrierAnimation>());
      expect(const SlideFromTopBarrier(), isA<BarrierAnimation>());
      expect(const SlideFromBottomBarrier(), isA<BarrierAnimation>());
      expect(PopoverPosition.center(), isA<PopoverPosition>());
      expect(
        const AnimatedBarrier(child: SizedBox.shrink()),
        isA<AnimatedBarrier>(),
      );
    });
  });
}
