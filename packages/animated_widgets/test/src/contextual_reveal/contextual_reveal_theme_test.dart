// animated_widgets/test/src/contextual_reveal/contextual_reveal_theme_test.dart

// ignore_for_file: unnecessary_cast

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextualRevealTheme — factories', () {
    test('light() returns a ContextualRevealTheme', () {
      expect(ContextualRevealTheme.light(), isA<ContextualRevealTheme>());
    });

    test('dark() returns a ContextualRevealTheme', () {
      expect(ContextualRevealTheme.dark(), isA<ContextualRevealTheme>());
    });

    test('light() returns ContextualRevealLight runtime type', () {
      expect(ContextualRevealTheme.light(), isA<ContextualRevealLight>());
    });

    test('dark() returns ContextualRevealDark runtime type', () {
      expect(ContextualRevealTheme.dark(), isA<ContextualRevealDark>());
    });
  });

  group('ContextualRevealLight — default getters', () {
    late ContextualRevealLight theme;
    setUp(() => theme = const ContextualRevealLight());

    test('backButton is null by default', () {
      expect(theme.backButton, isNull);
    });

    test('barrierColor is the light default', () {
      expect(theme.barrierColor, const Color.fromARGB(175, 255, 255, 255));
    });

    test('popoverBackgroundShade is the light default', () {
      expect(theme.popoverBackgroundShade, const Color(0x00000000));
    });

    test('popoverGap is 8.0', () {
      expect(theme.popoverGap, 8.0);
    });

    test('fadeInDuration is 200ms', () {
      expect(theme.fadeInDuration, const Duration(milliseconds: 200));
    });

    test('fadeOutDuration is 250ms', () {
      expect(theme.fadeOutDuration, const Duration(milliseconds: 250));
    });

    test('showDuration is 750ms', () {
      expect(theme.showDuration, const Duration(milliseconds: 750));
    });
  });

  group('ContextualRevealDark — default getters', () {
    late ContextualRevealDark theme;
    setUp(() => theme = const ContextualRevealDark());

    test('backButton is null by default', () {
      expect(theme.backButton, isNull);
    });

    test('barrierColor is the dark default', () {
      expect(theme.barrierColor, const Color.fromARGB(175, 0, 0, 0));
    });

    test('popoverBackgroundShade is the dark default', () {
      expect(theme.popoverBackgroundShade, const Color(0x00000000));
    });

    test('popoverGap is 8.0', () {
      expect(theme.popoverGap, 8.0);
    });

    test('fadeInDuration is 200ms', () {
      expect(theme.fadeInDuration, const Duration(milliseconds: 200));
    });

    test('fadeOutDuration is 250ms', () {
      expect(theme.fadeOutDuration, const Duration(milliseconds: 250));
    });

    test('showDuration is 750ms', () {
      expect(theme.showDuration, const Duration(milliseconds: 750));
    });
  });

  group('ContextualRevealLight — copyWith', () {
    test('no-args returns equivalent values via the copy class', () {
      const original = ContextualRevealLight();
      final copy = original.copyWith();
      expect(copy.barrierColor, original.barrierColor);
      expect(copy.popoverBackgroundShade, original.popoverBackgroundShade);
      expect(copy.popoverGap, original.popoverGap);
      expect(copy.fadeInDuration, original.fadeInDuration);
      expect(copy.fadeOutDuration, original.fadeOutDuration);
      expect(copy.showDuration, original.showDuration);
      expect(copy.backButton, original.backButton);
    });

    test('overrides barrierColor', () {
      final copy = const ContextualRevealLight()
          .copyWith(barrierColor: const Color(0xFFFF0000));
      expect(copy.barrierColor, const Color(0xFFFF0000));
    });

    test('overrides popoverBackgroundShade', () {
      final copy = const ContextualRevealLight()
          .copyWith(popoverBackgroundShade: const Color(0xFF00FF00));
      expect(copy.popoverBackgroundShade, const Color(0xFF00FF00));
    });

    test('overrides popoverGap', () {
      final copy = const ContextualRevealLight().copyWith(popoverGap: 16);
      expect(copy.popoverGap, 16);
    });

    test('overrides fadeInDuration', () {
      final copy = const ContextualRevealLight()
          .copyWith(fadeInDuration: const Duration(milliseconds: 99));
      expect(copy.fadeInDuration, const Duration(milliseconds: 99));
    });

    test('overrides fadeOutDuration', () {
      final copy = const ContextualRevealLight()
          .copyWith(fadeOutDuration: const Duration(milliseconds: 88));
      expect(copy.fadeOutDuration, const Duration(milliseconds: 88));
    });

    test('overrides showDuration', () {
      final copy = const ContextualRevealLight()
          .copyWith(showDuration: const Duration(milliseconds: 1234));
      expect(copy.showDuration, const Duration(milliseconds: 1234));
    });

    test('overrides backButton', () {
      const button = Icon(Icons.arrow_back);
      final copy = const ContextualRevealLight().copyWith(backButton: button);
      expect(copy.backButton, button);
    });
  });

  group('ContextualRevealDark — copyWith', () {
    test('no-args returns equivalent values via the copy class', () {
      const original = ContextualRevealDark();
      final copy = original.copyWith();
      expect(copy.barrierColor, original.barrierColor);
      expect(copy.popoverBackgroundShade, original.popoverBackgroundShade);
      expect(copy.popoverGap, original.popoverGap);
      expect(copy.fadeInDuration, original.fadeInDuration);
      expect(copy.fadeOutDuration, original.fadeOutDuration);
      expect(copy.showDuration, original.showDuration);
      expect(copy.backButton, original.backButton);
    });

    test('overrides barrierColor', () {
      final copy = const ContextualRevealDark()
          .copyWith(barrierColor: const Color(0xFFFF0000));
      expect(copy.barrierColor, const Color(0xFFFF0000));
    });

    test('overrides popoverBackgroundShade', () {
      final copy = const ContextualRevealDark()
          .copyWith(popoverBackgroundShade: const Color(0xFF00FF00));
      expect(copy.popoverBackgroundShade, const Color(0xFF00FF00));
    });

    test('overrides popoverGap', () {
      final copy = const ContextualRevealDark().copyWith(popoverGap: 16);
      expect(copy.popoverGap, 16);
    });

    test('overrides fadeInDuration', () {
      final copy = const ContextualRevealDark()
          .copyWith(fadeInDuration: const Duration(milliseconds: 99));
      expect(copy.fadeInDuration, const Duration(milliseconds: 99));
    });

    test('overrides fadeOutDuration', () {
      final copy = const ContextualRevealDark()
          .copyWith(fadeOutDuration: const Duration(milliseconds: 88));
      expect(copy.fadeOutDuration, const Duration(milliseconds: 88));
    });

    test('overrides showDuration', () {
      final copy = const ContextualRevealDark()
          .copyWith(showDuration: const Duration(milliseconds: 1234));
      expect(copy.showDuration, const Duration(milliseconds: 1234));
    });

    test('overrides backButton', () {
      const button = Icon(Icons.arrow_back);
      final copy = const ContextualRevealDark().copyWith(backButton: button);
      expect(copy.backButton, button);
    });
  });

  group('ContextualRevealLight — lerp', () {
    test('returns self when other is null', () {
      const a = ContextualRevealLight();
      final result = a.lerp(null, 0.5) as ContextualRevealTheme;
      expect(result.barrierColor, a.barrierColor);
    });

    test('at t=0 returns starting values', () {
      const a = ContextualRevealLight();
      const b = ContextualRevealDark();
      final result = a.lerp(b, 0) as ContextualRevealTheme;
      expect(result.fadeInDuration, a.fadeInDuration);
      expect(result.fadeOutDuration, a.fadeOutDuration);
      expect(result.showDuration, a.showDuration);
      expect(result.backButton, a.backButton);
    });

    test('at t=1 returns ending values', () {
      const a = ContextualRevealLight();
      final b = const ContextualRevealDark()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 1) as ContextualRevealTheme;
      expect(result.fadeInDuration, const Duration(milliseconds: 999));
    });

    test('at t<0.5 keeps starting durations', () {
      const a = ContextualRevealLight();
      final b = const ContextualRevealDark()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 0.25) as ContextualRevealTheme;
      expect(result.fadeInDuration, a.fadeInDuration);
    });

    test('at t>=0.5 switches to ending durations', () {
      const a = ContextualRevealLight();
      final b = const ContextualRevealDark()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 0.75) as ContextualRevealTheme;
      expect(result.fadeInDuration, const Duration(milliseconds: 999));
    });

    test('interpolates popoverGap linearly', () {
      final a = const ContextualRevealLight().copyWith(popoverGap: 0);
      final b = const ContextualRevealLight().copyWith(popoverGap: 10);
      final result = a.lerp(b, 0.5) as ContextualRevealTheme;
      expect(result.popoverGap, 5);
    });
  });

  group('ContextualRevealDark — lerp', () {
    test('returns self when other is null', () {
      const a = ContextualRevealDark();
      final result = a.lerp(null, 0.5) as ContextualRevealTheme;
      expect(result.barrierColor, a.barrierColor);
    });

    test('at t=0 returns starting values', () {
      const a = ContextualRevealDark();
      const b = ContextualRevealLight();
      final result = a.lerp(b, 0) as ContextualRevealTheme;
      expect(result.fadeInDuration, a.fadeInDuration);
      expect(result.fadeOutDuration, a.fadeOutDuration);
      expect(result.showDuration, a.showDuration);
      expect(result.backButton, a.backButton);
    });

    test('at t=1 returns ending values', () {
      const a = ContextualRevealDark();
      final b = const ContextualRevealLight()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 1) as ContextualRevealTheme;
      expect(result.fadeInDuration, const Duration(milliseconds: 999));
    });

    test('at t<0.5 keeps starting durations', () {
      const a = ContextualRevealDark();
      final b = const ContextualRevealLight()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 0.25) as ContextualRevealTheme;
      expect(result.fadeInDuration, a.fadeInDuration);
    });

    test('at t>=0.5 switches to ending durations', () {
      const a = ContextualRevealDark();
      final b = const ContextualRevealLight()
          .copyWith(fadeInDuration: const Duration(milliseconds: 999));
      final result = a.lerp(b, 0.75) as ContextualRevealTheme;
      expect(result.fadeInDuration, const Duration(milliseconds: 999));
    });

    test('interpolates popoverGap linearly', () {
      final a = const ContextualRevealDark().copyWith(popoverGap: 0);
      final b = const ContextualRevealDark().copyWith(popoverGap: 10);
      final result = a.lerp(b, 0.5) as ContextualRevealTheme;
      expect(result.popoverGap, 5);
    });
  });

  group('ContextualRevealTheme.of', () {
    testWidgets('returns registered extension when present', (tester) async {
      late ContextualRevealTheme resolved;
      final custom = const ContextualRevealLight()
          .copyWith(popoverGap: 42);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(extensions: [custom]),
          home: Builder(
            builder: (context) {
              resolved = ContextualRevealTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.popoverGap, 42);
    });

    testWidgets('falls back to ContextualRevealLight on light brightness',
        (tester) async {
      late ContextualRevealTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              resolved = ContextualRevealTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, isA<ContextualRevealLight>());
    });

    testWidgets('falls back to ContextualRevealDark on dark brightness',
        (tester) async {
      late ContextualRevealTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              resolved = ContextualRevealTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, isA<ContextualRevealDark>());
    });
  });
}
