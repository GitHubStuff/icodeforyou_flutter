// animated_rail_menu/test/src/theme/animated_rail_menu_theme_test.dart

import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_dark.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedRailMenuTheme', () {
    group('factory constructors', () {
      test('light() returns a AnimatedRailMenuTheme', () {
        expect(AnimatedRailMenuTheme.light(), isA<AnimatedRailMenuTheme>());
      });

      test('dark() returns a AnimatedRailMenuTheme', () {
        expect(AnimatedRailMenuTheme.dark(), isA<AnimatedRailMenuTheme>());
      });
    });

    group('light theme defaults', () {
      late AnimatedRailMenuTheme theme;
      setUp(() => theme = AnimatedRailMenuTheme.light());

      test('backgroundColor is white', () {
        expect(theme.backgroundColor, Colors.white);
      });

      test('activeColor is M3 primary', () {
        expect(theme.activeColor, const Color(0xFF6750A4));
      });

      test('inactiveColor is M3 on-surface', () {
        expect(theme.inactiveColor, const Color(0xFF49454F));
      });

      test('elevation is 2', () {
        expect(theme.elevation, 2);
      });

      test('labelStyle has fontSize 10', () {
        expect(theme.labelStyle.fontSize, 10);
      });
    });

    group('dark theme defaults', () {
      late AnimatedRailMenuTheme theme;
      setUp(() => theme = AnimatedRailMenuTheme.dark());

      test('backgroundColor is M3 dark surface', () {
        expect(theme.backgroundColor, const Color(0xFF1C1B1F));
      });

      test('activeColor is M3 dark primary', () {
        expect(theme.activeColor, const Color(0xFFD0BCFF));
      });

      test('inactiveColor is M3 dark on-surface', () {
        expect(theme.inactiveColor, const Color(0xFFCAC4D0));
      });

      test('elevation is 2', () {
        expect(theme.elevation, 2);
      });

      test('labelStyle has fontSize 10', () {
        expect(theme.labelStyle.fontSize, 10);
      });
    });

    group('copyWith', () {
      test('light theme copyWith overrides activeColor', () {
        final copy = (AnimatedRailMenuTheme.light() as AnimatedRailMenuThemeLight)
            .copyWith(activeColor: const Color(0xFFFF0000));
        expect(copy.activeColor, const Color(0xFFFF0000));
        expect(copy.backgroundColor, Colors.white);
      });

      test('dark theme copyWith overrides backgroundColor', () {
        final copy = (AnimatedRailMenuTheme.dark() as AnimatedRailMenuThemeDark)
            .copyWith(backgroundColor: const Color(0xFF000000));
        expect(copy.backgroundColor, const Color(0xFF000000));
        expect(copy.activeColor, const Color(0xFFD0BCFF));
      });

      test('light copyWith with no args returns same values', () {
        final original = AnimatedRailMenuTheme.light() as AnimatedRailMenuThemeLight;
        final copy = original.copyWith() as AnimatedRailMenuThemeLight;
        expect(copy.backgroundColor, original.backgroundColor);
        expect(copy.activeColor, original.activeColor);
        expect(copy.inactiveColor, original.inactiveColor);
        expect(copy.elevation, original.elevation);
        expect(copy.labelStyle.fontSize, 10);
      });

      test('dark copyWith with no args returns same values', () {
        final original = AnimatedRailMenuTheme.dark() as AnimatedRailMenuThemeDark;
        final copy = original.copyWith() as AnimatedRailMenuThemeDark;
        expect(copy.backgroundColor, original.backgroundColor);
        expect(copy.activeColor, original.activeColor);
        expect(copy.inactiveColor, original.inactiveColor);
        expect(copy.elevation, original.elevation);
        expect(copy.labelStyle.fontSize, 10);
      });
    });

    group('lerp', () {
      test('light lerp at t=0 returns original values', () {
        final a = AnimatedRailMenuTheme.light();
        final b = AnimatedRailMenuTheme.dark();
        final result = a.lerp(b, 0) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('light lerp at t=1 returns other values', () {
        final a = AnimatedRailMenuTheme.light();
        final b = AnimatedRailMenuTheme.dark();
        final result = a.lerp(b, 1) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, b.backgroundColor);
      });

      test('dark lerp at t=0 returns original values', () {
        final a = AnimatedRailMenuTheme.dark();
        final b = AnimatedRailMenuTheme.light();
        final result = a.lerp(b, 0) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('dark lerp at t=1 returns other values', () {
        final a = AnimatedRailMenuTheme.dark();
        final b = AnimatedRailMenuTheme.light();
        final result = a.lerp(b, 1) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, b.backgroundColor);
      });

      test('light lerp with null returns self', () {
        final a = AnimatedRailMenuTheme.light();
        final result = a.lerp(null, 0.5) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('dark lerp with null returns self', () {
        final a = AnimatedRailMenuTheme.dark();
        final result = a.lerp(null, 0.5) as AnimatedRailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });
    });

    group('of', () {
      testWidgets('returns registered extension when present', (tester) async {
        late AnimatedRailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light().copyWith(
              extensions: [AnimatedRailMenuTheme.light()],
            ),
            home: Builder(
              builder: (context) {
                resolved = AnimatedRailMenuTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(resolved, isA<AnimatedRailMenuTheme>());
        expect(resolved.backgroundColor, Colors.white);
      });

      testWidgets('falls back to light theme on light brightness',
          (tester) async {
        late AnimatedRailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                resolved = AnimatedRailMenuTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(resolved.backgroundColor, Colors.white);
      });

      testWidgets('falls back to dark theme on dark brightness',
          (tester) async {
        late AnimatedRailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                resolved = AnimatedRailMenuTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(resolved.backgroundColor, const Color(0xFF1C1B1F));
      });
    });
  });
}
