// packages/animated_barrier/test/src/barrier_animation_test.dart

import 'package:animated_widgets/animated_widgets.dart' show BarrierAnimation, FadeBarrier, SlideFromBottomBarrier, SlideFromTopBarrier;
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarrierAnimation defaults', () {
    test('FadeBarrier has 250ms duration and easeOutCubic curve by default', () {
      const sut = FadeBarrier();
      expect(sut.duration, const Duration(milliseconds: 250));
      expect(sut.curve, Curves.easeOutCubic);
    });

    test('SlideFromTopBarrier inherits the same defaults', () {
      const sut = SlideFromTopBarrier();
      expect(sut.duration, const Duration(milliseconds: 250));
      expect(sut.curve, Curves.easeOutCubic);
    });

    test('SlideFromBottomBarrier inherits the same defaults', () {
      const sut = SlideFromBottomBarrier();
      expect(sut.duration, const Duration(milliseconds: 250));
      expect(sut.curve, Curves.easeOutCubic);
    });
  });

  group('BarrierAnimation overrides', () {
    test('FadeBarrier accepts custom duration and curve', () {
      const sut = FadeBarrier(
        duration: Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      expect(sut.duration, const Duration(milliseconds: 500));
      expect(sut.curve, Curves.linear);
    });

    test('SlideFromTopBarrier accepts custom duration and curve', () {
      const sut = SlideFromTopBarrier(
        duration: Duration(milliseconds: 800),
        curve: Curves.bounceIn,
      );
      expect(sut.duration, const Duration(milliseconds: 800));
      expect(sut.curve, Curves.bounceIn);
    });

    test('SlideFromBottomBarrier accepts custom duration and curve', () {
      const sut = SlideFromBottomBarrier(
        duration: Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
      );
      expect(sut.duration, const Duration(milliseconds: 1200));
      expect(sut.curve, Curves.elasticOut);
    });
  });

  group('BarrierAnimation sealed exhaustiveness', () {
    test('switch over BarrierAnimation matches every variant', () {
      // This exists so the analyzer enforces exhaustive switches at the call
      // site, and so a regression that adds a variant without updating
      // _BarrierTransition is caught here too.
      String describe(BarrierAnimation anim) => switch (anim) {
        FadeBarrier() => 'fade',
        SlideFromTopBarrier() => 'top',
        SlideFromBottomBarrier() => 'bottom',
      };

      expect(describe(const FadeBarrier()), 'fade');
      expect(describe(const SlideFromTopBarrier()), 'top');
      expect(describe(const SlideFromBottomBarrier()), 'bottom');
    });
  });
}
