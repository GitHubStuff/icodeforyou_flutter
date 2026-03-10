// test/src/types_test.dart
// ignore_for_file: lines_longer_than_80_chars

import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — construction and defaults
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig defaults', () {
    const config = AdaptiveModalConfig();

    test('closeIcon is null', () => expect(config.closeIcon, isNull));
    test('barrierDismissible is true', () => expect(config.barrierDismissible, isTrue));
    test('barrierColor is black54', () => expect(config.barrierColor, const Color(0x80000000)));
    test('maxWidth is 400', () => expect(config.maxWidth, 400.0));
    test('maxHeight is 700', () => expect(config.maxHeight, 700.0));
    test('animationDuration is 200ms', () => expect(config.animationDuration, const Duration(milliseconds: 200)));
    test('animationCurve is easeInOut', () => expect(config.animationCurve, Curves.easeInOut));
    test('hapticFeedback is true', () => expect(config.hapticFeedback, isTrue));
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — custom construction
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig custom values', () {
    const config = AdaptiveModalConfig(
      closeIcon: Icon(Icons.arrow_back),
      barrierDismissible: false,
      barrierColor: Colors.red,
      maxWidth: 300,
      maxHeight: 500,
      animationDuration: Duration(milliseconds: 400),
      animationCurve: Curves.bounceIn,
      hapticFeedback: false,
    );

    test('closeIcon is set', () => expect(config.closeIcon, isNotNull));
    test('barrierDismissible is false', () => expect(config.barrierDismissible, isFalse));
    test('barrierColor is red', () => expect(config.barrierColor, Colors.red));
    test('maxWidth is 300', () => expect(config.maxWidth, 300.0));
    test('maxHeight is 500', () => expect(config.maxHeight, 500.0));
    test('animationDuration is 400ms', () => expect(config.animationDuration, const Duration(milliseconds: 400)));
    test('animationCurve is bounceIn', () => expect(config.animationCurve, Curves.bounceIn));
    test('hapticFeedback is false', () => expect(config.hapticFeedback, isFalse));
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — asserts
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig asserts', () {
    test('throws when maxWidth is zero', () {
      expect(
        () => AdaptiveModalConfig(maxWidth: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws when maxWidth is negative', () {
      expect(
        () => AdaptiveModalConfig(maxWidth: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws when maxHeight is zero', () {
      expect(
        () => AdaptiveModalConfig(maxHeight: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws when maxHeight is negative', () {
      expect(
        () => AdaptiveModalConfig(maxHeight: -100),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — copyWith
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig.copyWith', () {
    const base = AdaptiveModalConfig();

    test('returns equal config when no fields overridden', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides barrierDismissible', () {
      final copy = base.copyWith(barrierDismissible: false);
      expect(copy.barrierDismissible, isFalse);
      expect(copy.maxWidth, base.maxWidth);
    });

    test('overrides barrierColor', () {
      final copy = base.copyWith(barrierColor: Colors.blue);
      expect(copy.barrierColor, Colors.blue);
    });

    test('overrides maxWidth', () {
      final copy = base.copyWith(maxWidth: 320);
      expect(copy.maxWidth, 320.0);
      expect(copy.maxHeight, base.maxHeight);
    });

    test('overrides maxHeight', () {
      final copy = base.copyWith(maxHeight: 600);
      expect(copy.maxHeight, 600.0);
    });

    test('overrides animationDuration', () {
      final copy = base.copyWith(animationDuration: const Duration(milliseconds: 500));
      expect(copy.animationDuration, const Duration(milliseconds: 500));
    });

    test('overrides animationCurve', () {
      final copy = base.copyWith(animationCurve: Curves.linear);
      expect(copy.animationCurve, Curves.linear);
    });

    test('overrides hapticFeedback', () {
      final copy = base.copyWith(hapticFeedback: false);
      expect(copy.hapticFeedback, isFalse);
    });

    test('overrides closeIcon', () {
      const icon = Icon(Icons.close);
      final copy = base.copyWith(closeIcon: icon);
      expect(copy.closeIcon, isNotNull);
    });

    test('preserves all other fields when one is overridden', () {
      final copy = base.copyWith(maxWidth: 350);
      expect(copy.barrierDismissible, base.barrierDismissible);
      expect(copy.barrierColor, base.barrierColor);
      expect(copy.maxHeight, base.maxHeight);
      expect(copy.animationDuration, base.animationDuration);
      expect(copy.animationCurve, base.animationCurve);
      expect(copy.hapticFeedback, base.hapticFeedback);
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — equality
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig equality', () {
    test('two defaults are equal', () {
      expect(const AdaptiveModalConfig(), equals(const AdaptiveModalConfig()));
    });

    test('identical instance equals itself', () {
      const config = AdaptiveModalConfig();
      expect(config, equals(config));
    });

    test('different barrierDismissible are not equal', () {
      expect(
        const AdaptiveModalConfig(),
        isNot(equals(const AdaptiveModalConfig(barrierDismissible: false))),
      );
    });

    test('different barrierColor are not equal', () {
      expect(
        const AdaptiveModalConfig(barrierColor: Colors.red),
        isNot(equals(const AdaptiveModalConfig(barrierColor: Colors.blue))),
      );
    });

    test('different maxWidth are not equal', () {
      expect(
        const AdaptiveModalConfig(maxWidth: 300),
        isNot(equals(const AdaptiveModalConfig())),
      );
    });

    test('different maxHeight are not equal', () {
      expect(
        const AdaptiveModalConfig(maxHeight: 500),
        isNot(equals(const AdaptiveModalConfig())),
      );
    });

    test('different animationDuration are not equal', () {
      expect(
        const AdaptiveModalConfig(animationDuration: Duration(milliseconds: 100)),
        isNot(equals(const AdaptiveModalConfig())),
      );
    });

    test('different hapticFeedback are not equal', () {
      expect(
        const AdaptiveModalConfig(),
        isNot(equals(const AdaptiveModalConfig(hapticFeedback: false))),
      );
    });

    test('not equal to non-AdaptiveModalConfig object', () {
      expect(const AdaptiveModalConfig(), isNot(equals('not a config')));
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — hashCode
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig hashCode', () {
    test('equal configs have equal hashCodes', () {
      expect(
        const AdaptiveModalConfig().hashCode,
        equals(const AdaptiveModalConfig().hashCode),
      );
    });

    test('different configs have different hashCodes', () {
      expect(
        const AdaptiveModalConfig(maxWidth: 300).hashCode,
        isNot(equals(const AdaptiveModalConfig().hashCode)),
      );
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalConfig — toString
  // -------------------------------------------------------------------------

  group('AdaptiveModalConfig toString', () {
    test('contains class name', () {
      expect(const AdaptiveModalConfig().toString(), contains('AdaptiveModalConfig'));
    });

    test('contains barrierDismissible value', () {
      expect(const AdaptiveModalConfig().toString(), contains('barrierDismissible: true'));
    });

    test('contains maxWidth value', () {
      expect(const AdaptiveModalConfig(maxWidth: 320).toString(), contains('maxWidth: 320.0'));
    });

    test('contains hapticFeedback value', () {
      expect(const AdaptiveModalConfig(hapticFeedback: false).toString(), contains('hapticFeedback: false'));
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalPosition enum
  // -------------------------------------------------------------------------

  group('AdaptiveModalPosition', () {
    test('has three values', () {
      expect(AdaptiveModalPosition.values.length, 3);
    });

    test('contains above', () {
      expect(AdaptiveModalPosition.values, contains(AdaptiveModalPosition.above));
    });

    test('contains below', () {
      expect(AdaptiveModalPosition.values, contains(AdaptiveModalPosition.below));
    });

    test('contains fullScreen', () {
      expect(AdaptiveModalPosition.values, contains(AdaptiveModalPosition.fullScreen));
    });
  });

  // -------------------------------------------------------------------------
  // AdaptiveModalAnchorRect
  // -------------------------------------------------------------------------

  group('AdaptiveModalAnchorRect', () {
    const rect = AdaptiveModalAnchorRect(
      left: 10,
      top: 20,
      width: 100,
      height: 50,
    );

    test('right equals left + width', () => expect(rect.right, 110.0));
    test('bottom equals top + height', () => expect(rect.bottom, 70.0));
    test('centerX equals left + width/2', () => expect(rect.centerX, 60.0));

    test('toString contains left', () => expect(rect.toString(), contains('left: 10.0')));
    test('toString contains top', () => expect(rect.toString(), contains('top: 20.0')));
    test('toString contains width', () => expect(rect.toString(), contains('width: 100.0')));
    test('toString contains height', () => expect(rect.toString(), contains('height: 50.0')));
  });
}
