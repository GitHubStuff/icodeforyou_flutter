// packages/extensions/test/color/color_pair_test.dart
import 'package:extensions/color/color_pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dark = Color(0xFF111111);
  const light = Color(0xFFEEEEEE);

  /// Pumps [child] inside a [MaterialApp] whose theme has [brightness], and
  /// hands the resulting [BuildContext] to [body].
  Future<void> pumpWithBrightness(
    WidgetTester tester,
    Brightness brightness,
    void Function(BuildContext context) body,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(
          builder: (context) {
            body(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  group('ColorPair', () {
    group('constructor', () {
      test('stores dark and light', () {
        const pair = ColorPair(dark: dark, light: light);

        expect(pair.dark, dark);
        expect(pair.light, light);
      });

      test('executes at runtime when constructed non-const', () {
        // A const invocation is folded at compile time and never hits the
        // constructor line in LCOV; a non-const invocation does.
        // ignore: prefer_const_constructors
        final pair = ColorPair(dark: dark, light: light);

        expect(pair.dark, dark);
        expect(pair.light, light);
      });
    });

    group('isDark', () {
      testWidgets('returns true under a dark theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late bool result;

        await pumpWithBrightness(
          tester,
          Brightness.dark,
          (context) => result = pair.isDark(context),
        );

        expect(result, isTrue);
      });

      testWidgets('returns false under a light theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late bool result;

        await pumpWithBrightness(
          tester,
          Brightness.light,
          (context) => result = pair.isDark(context),
        );

        expect(result, isFalse);
      });
    });

    group('isLight', () {
      testWidgets('returns true under a light theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late bool result;

        await pumpWithBrightness(
          tester,
          Brightness.light,
          (context) => result = pair.isLight(context),
        );

        expect(result, isTrue);
      });

      testWidgets('returns false under a dark theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late bool result;

        await pumpWithBrightness(
          tester,
          Brightness.dark,
          (context) => result = pair.isLight(context),
        );

        expect(result, isFalse);
      });
    });

    group('current', () {
      testWidgets('returns dark under a dark theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late Color result;

        await pumpWithBrightness(
          tester,
          Brightness.dark,
          (context) => result = pair.current(context),
        );

        expect(result, dark);
      });

      testWidgets('returns light under a light theme', (tester) async {
        const pair = ColorPair(dark: dark, light: light);
        late Color result;

        await pumpWithBrightness(
          tester,
          Brightness.light,
          (context) => result = pair.current(context),
        );

        expect(result, light);
      });
    });
  });
}
