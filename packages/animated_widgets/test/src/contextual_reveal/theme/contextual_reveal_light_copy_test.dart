// test/src/contextual_reveal/src/theme/contextual_reveal_light_copy_test.dart

import 'package:animated_widgets/src/contextual_reveal/src/theme/contextual_reveal_light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Override values chosen to differ from every light default, so each
  // assertion proves the copy stores what it was given rather than
  // falling through to the base ContextualRevealLight value.
  const overriddenBarrierColor = Color(0xFF112233);
  const overriddenPopoverBackgroundShade = Color(0xFF445566);
  const overriddenPopoverGap = 42.0;
  const overriddenFadeInDuration = Duration(milliseconds: 11);
  const overriddenFadeOutDuration = Duration(milliseconds: 22);
  const overriddenShowDuration = Duration(milliseconds: 33);
  const overriddenBackButton = SizedBox(key: Key('back'));

  group('_ContextualRevealLightCopy', () {
    test('copyWith builds a copy exposing every overridden value', () {
      const base = ContextualRevealLight();

      final copy = base.copyWith(
        barrierColor: overriddenBarrierColor,
        popoverBackgroundShade: overriddenPopoverBackgroundShade,
        popoverGap: overriddenPopoverGap,
        fadeInDuration: overriddenFadeInDuration,
        fadeOutDuration: overriddenFadeOutDuration,
        showDuration: overriddenShowDuration,
        backButton: overriddenBackButton,
      );

      expect(copy, isA<ContextualRevealLight>());
      expect(copy.barrierColor, overriddenBarrierColor);
      expect(copy.popoverBackgroundShade, overriddenPopoverBackgroundShade);
      expect(copy.popoverGap, overriddenPopoverGap);
      expect(copy.fadeInDuration, overriddenFadeInDuration);
      expect(copy.fadeOutDuration, overriddenFadeOutDuration);
      expect(copy.showDuration, overriddenShowDuration);
      expect(copy.backButton, same(overriddenBackButton));

      // The copy genuinely diverges from the base it was derived from.
      expect(copy.barrierColor, isNot(base.barrierColor));
      expect(copy.popoverGap, isNot(base.popoverGap));
      expect(copy.backButton, isNot(base.backButton));
    });

    test('reports the exact backButton instance it was given', () {
      final copy = const ContextualRevealLight().copyWith(
        backButton: overriddenBackButton,
      );

      expect(copy.backButton, same(overriddenBackButton));
    });
  });
}
