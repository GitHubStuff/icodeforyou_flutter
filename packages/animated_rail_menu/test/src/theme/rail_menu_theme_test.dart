// test/src/theme/rail_menu_theme_test.dart

import 'package:animated_rail_menu/src/theme/_rail_menu_theme_dark.dart';
import 'package:animated_rail_menu/src/theme/_rail_menu_theme_light.dart';
import 'package:animated_rail_menu/src/theme/rail_menu_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RailMenuTheme', () {
    group('factory constructors', () {
      test('light() returns a RailMenuTheme', () {
        expect(RailMenuTheme.light(), isA<RailMenuTheme>());
      });

      test('dark() returns a RailMenuTheme', () {
        expect(RailMenuTheme.dark(), isA<RailMenuTheme>());
      });
    });

    group('light theme defaults', () {
      late RailMenuTheme theme;
      setUp(() => theme = RailMenuTheme.light());

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
      late RailMenuTheme theme;
      setUp(() => theme = RailMenuTheme.dark());

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
        final copy = (RailMenuTheme.light() as RailMenuThemeLight)
            .copyWith(activeColor: const Color(0xFFFF0000));
        expect(copy.activeColor, const Color(0xFFFF0000));
        expect(copy.backgroundColor, Colors.white);
      });

      test('dark theme copyWith overrides backgroundColor', () {
        final copy = (RailMenuTheme.dark() as RailMenuThemeDark)
            .copyWith(backgroundColor: const Color(0xFF000000));
        expect(copy.backgroundColor, const Color(0xFF000000));
        expect(copy.activeColor, const Color(0xFFD0BCFF));
      });

      test('light copyWith with no args returns same values', () {
        final original = RailMenuTheme.light() as RailMenuThemeLight;
        final copy = original.copyWith() as RailMenuThemeLight;
        expect(copy.backgroundColor, original.backgroundColor);
        expect(copy.activeColor, original.activeColor);
        expect(copy.inactiveColor, original.inactiveColor);
        expect(copy.elevation, original.elevation);
        expect(copy.labelStyle.fontSize, 10);
      });

      test('dark copyWith with no args returns same values', () {
        final original = RailMenuTheme.dark() as RailMenuThemeDark;
        final copy = original.copyWith() as RailMenuThemeDark;
        expect(copy.backgroundColor, original.backgroundColor);
        expect(copy.activeColor, original.activeColor);
        expect(copy.inactiveColor, original.inactiveColor);
        expect(copy.elevation, original.elevation);
        expect(copy.labelStyle.fontSize, 10);
      });
    });

    group('lerp', () {
      test('light lerp at t=0 returns original values', () {
        final a = RailMenuTheme.light();
        final b = RailMenuTheme.dark();
        final result = a.lerp(b, 0) as RailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('light lerp at t=1 returns other values', () {
        final a = RailMenuTheme.light();
        final b = RailMenuTheme.dark();
        final result = a.lerp(b, 1) as RailMenuTheme;
        expect(result.backgroundColor, b.backgroundColor);
      });

      test('dark lerp at t=0 returns original values', () {
        final a = RailMenuTheme.dark();
        final b = RailMenuTheme.light();
        final result = a.lerp(b, 0) as RailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('dark lerp at t=1 returns other values', () {
        final a = RailMenuTheme.dark();
        final b = RailMenuTheme.light();
        final result = a.lerp(b, 1) as RailMenuTheme;
        expect(result.backgroundColor, b.backgroundColor);
      });

      test('light lerp with null returns self', () {
        final a = RailMenuTheme.light();
        final result = a.lerp(null, 0.5) as RailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });

      test('dark lerp with null returns self', () {
        final a = RailMenuTheme.dark();
        final result = a.lerp(null, 0.5) as RailMenuTheme;
        expect(result.backgroundColor, a.backgroundColor);
      });
    });

    group('of', () {
      testWidgets('returns registered extension when present', (tester) async {
        late RailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light().copyWith(
              extensions: [RailMenuTheme.light()],
            ),
            home: Builder(
              builder: (context) {
                resolved = RailMenuTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(resolved, isA<RailMenuTheme>());
        expect(resolved.backgroundColor, Colors.white);
      });

      testWidgets('falls back to light theme on light brightness',
          (tester) async {
        late RailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                resolved = RailMenuTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(resolved.backgroundColor, Colors.white);
      });

      testWidgets('falls back to dark theme on dark brightness',
          (tester) async {
        late RailMenuTheme resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Builder(
              builder: (context) {
                resolved = RailMenuTheme.of(context);
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
