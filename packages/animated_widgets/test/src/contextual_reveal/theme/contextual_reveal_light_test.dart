// test/src/contextual_reveal/src/theme/contextual_reveal_light_test.dart

import 'package:animated_widgets/src/contextual_reveal/src/theme/_contextual_reveal_defaults.dart';
import 'package:animated_widgets/src/contextual_reveal/src/theme/contextual_reveal_light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextualRevealLight', () {
    test('exposes the documented light defaults', () {
      const theme = ContextualRevealLight();

      expect(theme.barrierColor, kLightBarrierColor);
      expect(theme.popoverBackgroundShade, kLightPopoverBackground);
      expect(theme.popoverGap, kPopoverGap);
      expect(theme.fadeInDuration, kFadeInDuration);
      expect(theme.fadeOutDuration, kFadeOutDuration);
      expect(theme.showDuration, kShowDuration);
      expect(theme.backButton, isNull);
    });

    group('copyWith', () {
      test('falls back to every base value when given no arguments', () {
        final copy = const ContextualRevealLight().copyWith();

        expect(copy.barrierColor, kLightBarrierColor);
        expect(copy.popoverBackgroundShade, kLightPopoverBackground);
        expect(copy.popoverGap, kPopoverGap);
        expect(copy.fadeInDuration, kFadeInDuration);
        expect(copy.fadeOutDuration, kFadeOutDuration);
        expect(copy.showDuration, kShowDuration);
        expect(copy.backButton, isNull);
      });

      test('applies every provided override', () {
        const overriddenBarrierColor = Color(0xFF112233);
        const overriddenPopoverBackgroundShade = Color(0xFF445566);
        const overriddenPopoverGap = 42.0;
        const overriddenFadeInDuration = Duration(milliseconds: 11);
        const overriddenFadeOutDuration = Duration(milliseconds: 22);
        const overriddenShowDuration = Duration(milliseconds: 33);
        const overriddenBackButton = SizedBox(key: Key('back'));

        final copy = const ContextualRevealLight().copyWith(
          barrierColor: overriddenBarrierColor,
          popoverBackgroundShade: overriddenPopoverBackgroundShade,
          popoverGap: overriddenPopoverGap,
          fadeInDuration: overriddenFadeInDuration,
          fadeOutDuration: overriddenFadeOutDuration,
          showDuration: overriddenShowDuration,
          backButton: overriddenBackButton,
        );

        expect(copy.barrierColor, overriddenBarrierColor);
        expect(copy.popoverBackgroundShade, overriddenPopoverBackgroundShade);
        expect(copy.popoverGap, overriddenPopoverGap);
        expect(copy.fadeInDuration, overriddenFadeInDuration);
        expect(copy.fadeOutDuration, overriddenFadeOutDuration);
        expect(copy.showDuration, overriddenShowDuration);
        expect(copy.backButton, same(overriddenBackButton));
      });
    });

    group('lerp', () {
      // A fully distinct theme so each interpolation endpoint is unambiguous.
      const otherBackButton = SizedBox(key: Key('other-back'));
      final other = const ContextualRevealLight().copyWith(
        barrierColor: const Color(0xFFAABBCC),
        popoverBackgroundShade: const Color(0xFFDDEEFF),
        popoverGap: 99,
        fadeInDuration: const Duration(milliseconds: 111),
        fadeOutDuration: const Duration(milliseconds: 222),
        showDuration: const Duration(milliseconds: 333),
        backButton: otherBackButton,
      );

      test('returns itself when the other theme is null', () {
        const theme = ContextualRevealLight();

        final result = theme.lerp(null, 0.3);

        expect(identical(result, theme), isTrue);
      });

      test('keeps its own values at t below 0.5', () {
        const theme = ContextualRevealLight();

        final result = theme.lerp(other, 0);

        expect(result.barrierColor, kLightBarrierColor);
        expect(result.popoverGap, kPopoverGap);
        expect(result.fadeInDuration, kFadeInDuration);
        expect(result.fadeOutDuration, kFadeOutDuration);
        expect(result.showDuration, kShowDuration);
        expect(result.backButton, isNull);
      });

      test('adopts the other theme values at t of 0.5 and above', () {
        const theme = ContextualRevealLight();

        final result = theme.lerp(other, 1);

        expect(result.barrierColor, other.barrierColor);
        expect(result.popoverBackgroundShade, other.popoverBackgroundShade);
        expect(result.popoverGap, other.popoverGap);
        expect(result.fadeInDuration, other.fadeInDuration);
        expect(result.fadeOutDuration, other.fadeOutDuration);
        expect(result.showDuration, other.showDuration);
        expect(result.backButton, same(otherBackButton));
      });
    });
  });
}
