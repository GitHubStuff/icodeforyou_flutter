// packages/custom_widgets/test/src/solid_screen_color/solid_screen_color_test.dart

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  AnnotatedRegion<SystemUiOverlayStyle> regionOf(WidgetTester tester) {
    return tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(SolidScreenColor),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    );
  }

  ColoredBox boxOf(WidgetTester tester) {
    return tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(SolidScreenColor),
        matching: find.byType(ColoredBox),
      ),
    );
  }

  group('SolidScreenColor', () {
    testWidgets('constructs at runtime and defaults to black '
        '(non-const key forces the constructor line to execute)', (
      tester,
    ) async {
      // UniqueKey() cannot be const, so this is a runtime constructor call.
      await tester.pumpWidget(SolidScreenColor(key: UniqueKey()));

      expect(boxOf(tester).color, Colors.black);
    });

    testWidgets('fills the surface with the supplied color', (tester) async {
      await tester.pumpWidget(
        SolidScreenColor(key: UniqueKey(), color: Colors.white),
      );

      expect(boxOf(tester).color, Colors.white);
    });

    testWidgets('expands the colored box to the full viewport', (tester) async {
      await tester.pumpWidget(SolidScreenColor(key: UniqueKey()));

      expect(
        find.descendant(
          of: find.byType(ColoredBox),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(SolidScreenColor)),
        tester.getSize(find.byType(SizedBox)),
      );
    });

    testWidgets('annotates the region so both system bars match the color with '
        'dark icons and no contrast enforcement', (tester) async {
      const fill = Colors.deepOrange;

      await tester.pumpWidget(
        SolidScreenColor(key: UniqueKey(), color: fill),
      );

      final style = regionOf(tester).value;
      expect(style.statusBarColor, fill);
      expect(style.statusBarBrightness, Brightness.dark);
      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.systemNavigationBarColor, fill);
      expect(style.systemNavigationBarDividerColor, fill);
      expect(style.systemNavigationBarIconBrightness, Brightness.dark);
      expect(style.systemStatusBarContrastEnforced, isFalse);
      expect(style.systemNavigationBarContrastEnforced, isFalse);
    });

    testWidgets('overlay style tracks the default black fill', (tester) async {
      await tester.pumpWidget(SolidScreenColor(key: UniqueKey()));

      final style = regionOf(tester).value;
      expect(style.statusBarColor, Colors.black);
      expect(style.systemNavigationBarColor, Colors.black);
      expect(style.systemNavigationBarDividerColor, Colors.black);
    });
  });
}
