// test/cross_fade_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_themes/widget_themes.dart';

void main() {
  group('CrossFadeTheme constructor', () {
    test('applies the built-in defaults (1250ms / 48)', () {
      const theme = CrossFadeTheme();
      expect(theme.crossFadeDuration, const Duration(milliseconds: 1250));
      expect(theme.buttonSize, 48);
    });

    test('accepts explicit values', () {
      const theme = CrossFadeTheme(
        crossFadeDuration: Duration(milliseconds: 300),
        buttonSize: 64,
      );
      expect(theme.crossFadeDuration, const Duration(milliseconds: 300));
      expect(theme.buttonSize, 64);
    });
  });

  group('CrossFadeTheme.of', () {
    testWidgets('returns the registered extension when present',
        (tester) async {
      const registered = CrossFadeTheme(
        crossFadeDuration: Duration(milliseconds: 200),
        buttonSize: 30,
      );

      late CrossFadeTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [registered]),
          home: Builder(
            builder: (context) {
              resolved = CrossFadeTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, same(registered));
    });

    testWidgets('falls back to defaults when no extension is registered',
        (tester) async {
      late CrossFadeTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          // No CrossFadeTheme extension installed.
          home: Builder(
            builder: (context) {
              resolved = CrossFadeTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved, const CrossFadeTheme());
      expect(resolved.crossFadeDuration, const Duration(milliseconds: 1250));
      expect(resolved.buttonSize, 48);
    });
  });

  group('CrossFadeTheme.copyWith', () {
    const base = CrossFadeTheme(
      crossFadeDuration: Duration(milliseconds: 100),
      buttonSize: 20,
    );

    test('returns an equal copy when no arguments are given', () {
      // Both ?? arms fall through to `this`.
      expect(base.copyWith(), base);
    });

    test('overrides only the duration', () {
      final copy = base.copyWith(crossFadeDuration: const Duration(seconds: 1));
      expect(copy.crossFadeDuration, const Duration(seconds: 1));
      expect(copy.buttonSize, 20); // unchanged
    });

    test('overrides only the buttonSize', () {
      final copy = base.copyWith(buttonSize: 99);
      expect(copy.buttonSize, 99);
      expect(copy.crossFadeDuration, const Duration(milliseconds: 100));
    });

    test('overrides both fields', () {
      final copy = base.copyWith(
        crossFadeDuration: const Duration(seconds: 2),
        buttonSize: 12,
      );
      expect(copy.crossFadeDuration, const Duration(seconds: 2));
      expect(copy.buttonSize, 12);
    });
  });

  group('CrossFadeTheme.lerp', () {
    const a = CrossFadeTheme(
      crossFadeDuration: Duration(milliseconds: 0),
      buttonSize: 0,
    );
    const b = CrossFadeTheme(
      crossFadeDuration: Duration(milliseconds: 1000),
      buttonSize: 100,
    );

    test('returns this unchanged when other is null', () {
      expect(a.lerp(null, 0.5), same(a));
    });

    test('interpolates both fields at the midpoint', () {
      final mid = a.lerp(b, 0.5);
      expect(mid.crossFadeDuration, const Duration(milliseconds: 500));
      expect(mid.buttonSize, 50);
    });

    test('returns endpoint values at t = 0 and t = 1', () {
      final atZero = a.lerp(b, 0);
      expect(atZero.crossFadeDuration, const Duration(milliseconds: 0));
      expect(atZero.buttonSize, 0);

      final atOne = a.lerp(b, 1);
      expect(atOne.crossFadeDuration, const Duration(milliseconds: 1000));
      expect(atOne.buttonSize, 100);
    });
  });

  group('CrossFadeTheme equality (props)', () {
    test('two instances with the same fields are equal', () {
      const x = CrossFadeTheme(
        crossFadeDuration: Duration(milliseconds: 400),
        buttonSize: 42,
      );
      const y = CrossFadeTheme(
        crossFadeDuration: Duration(milliseconds: 400),
        buttonSize: 42,
      );
      expect(x, y);
      expect(x.hashCode, y.hashCode);
      expect(x.props, [const Duration(milliseconds: 400), 42.0]);
    });

    test('instances differing in any field are unequal', () {
      const x = CrossFadeTheme(buttonSize: 10);
      const y = CrossFadeTheme(buttonSize: 11);
      const z = CrossFadeTheme(
        crossFadeDuration: Duration(milliseconds: 1),
      );
      expect(x, isNot(y));
      expect(x, isNot(z));
    });
  });
}
