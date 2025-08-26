// clock_style_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:analog_clock_widget/src/clock_style.dart';
import 'package:analog_clock_widget/src/analog_clock.dart'
    show ClockFaceStyle, HandStyle;

void main() {
  group('ClockStyle.copyWith', () {
    test('returns an equal instance when no arguments are provided', () {
      final original = ClockStyle(
        faceColor: const Color(0xFF112233),
        borderColor: const Color(0xFF445566),
        hourHandColor: const Color(0xFF778899),
        minuteHandColor: const Color(0xFFAABBCC),
        secondHandColor: const Color(0xFFDDEEFF),
        showNumbers: true,
        showSecondHand: true,
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      final copy = original.copyWith();

      // Same values…
      expect(copy, equals(original));
      // …but not the same reference.
      expect(identical(copy, original), isFalse);
    });

    test('overrides provided fields and preserves the rest', () {
      final original = ClockStyle(
        faceColor: const Color(0xFF010101),
        borderColor: const Color(0xFF020202),
        hourHandColor: const Color(0xFF030303),
        minuteHandColor: const Color(0xFF040404),
        secondHandColor: const Color(0xFF050505),
        showNumbers: true,
        showSecondHand: true,
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      final updated = original.copyWith(
        faceColor: const Color(0xFF111111),
        borderColor: const Color(0xFF222222),
        hourHandColor: const Color(0xFF333333),
        minuteHandColor: const Color(0xFF444444),
        secondHandColor: const Color(0xFF555555),
        showNumbers: false,
        showSecondHand: false,
        // Explicitly provide enums (even if same) to exercise non-null branch.
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      expect(updated.faceColor, const Color(0xFF111111));
      expect(updated.borderColor, const Color(0xFF222222));
      expect(updated.hourHandColor, const Color(0xFF333333));
      expect(updated.minuteHandColor, const Color(0xFF444444));
      expect(updated.secondHandColor, const Color(0xFF555555));
      expect(updated.showNumbers, isFalse);
      expect(updated.showSecondHand, isFalse);
      expect(updated.faceStyle, ClockFaceStyle.classic);
      expect(updated.handStyle, HandStyle.traditional);

      // Only the intended fields changed; equality with original should fail.
      expect(updated == original, isFalse);
    });
  });

  group('ClockStyle.== (equality)', () {
    test('identical reference returns true (fast path)', () {
      const base = ClockStyle();
      expect(base == base, isTrue);
    });

    test('value equality across distinct instances returns true', () {
      final a = ClockStyle(
        faceColor: const Color(0xFFABCDEF),
        borderColor: const Color(0xFF123456),
        hourHandColor: const Color(0xFF0F0F0F),
        minuteHandColor: const Color(0xFF1F1F1F),
        secondHandColor: const Color(0xFF2F2F2F),
        showNumbers: false,
        showSecondHand: true,
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      final b = ClockStyle(
        faceColor: const Color(0xFFABCDEF),
        borderColor: const Color(0xFF123456),
        hourHandColor: const Color(0xFF0F0F0F),
        minuteHandColor: const Color(0xFF1F1F1F),
        secondHandColor: const Color(0xFF2F2F2F),
        showNumbers: false,
        showSecondHand: true,
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      expect(a == b, isTrue);
    });

    test('comparison with non-ClockStyle returns false', () {
      const base = ClockStyle();
      // ignore: unrelated_type_equality_checks
      expect(base == 42, isFalse);
    });

    test('inequality when any single field differs', () {
      final base = ClockStyle(
        faceColor: const Color(0xFFAAAAAA),
        borderColor: const Color(0xFFBBBBBB),
        hourHandColor: const Color(0xFFCCCCCC),
        minuteHandColor: const Color(0xFFDDDDDD),
        secondHandColor: const Color(0xFFEEEEEE),
        showNumbers: true,
        showSecondHand: true,
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
      );

      expect(
        base == base.copyWith(faceColor: const Color(0xFF999999)),
        isFalse,
      );
      expect(
        base == base.copyWith(borderColor: const Color(0xFF999998)),
        isFalse,
      );
      expect(
        base == base.copyWith(hourHandColor: const Color(0xFF999997)),
        isFalse,
      );
      expect(
        base == base.copyWith(minuteHandColor: const Color(0xFF999996)),
        isFalse,
      );
      expect(
        base == base.copyWith(secondHandColor: const Color(0xFF999995)),
        isFalse,
      );
      expect(base == base.copyWith(showNumbers: false), isFalse);
      expect(base == base.copyWith(showSecondHand: false), isFalse);

      // Also exercise enum fields explicitly (using same values still hits the branch).
      // Change via copyWith but keep same enum values -> remains equal.
      expect(
        base ==
            base.copyWith(
              faceStyle: ClockFaceStyle.classic,
              handStyle: HandStyle.traditional,
            ),
        isTrue,
      );
    });
  });
  
}
