// packages/custom_widgets/test/src/solid_screen_color/sollid_screen_color_test.dart

import 'package:custom_widgets/custom_widgets.dart' show SolidScreenColor;
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rendered [SystemUiOverlayStyle] of the pumped surface.
SystemUiOverlayStyle _styleOf(WidgetTester tester) {
  return tester
      .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      )
      .value;
}

void main() {
  group('SolidScreenColor', () {
    testWidgets('defaults to a black, expanded surface', (tester) async {
      await tester.pumpWidget(const SolidScreenColor());

      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.black);
      expect(
        find.descendant(
          of: find.byType(ColoredBox),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(SolidScreenColor)),
        tester.view.physicalSize / tester.view.devicePixelRatio,
      );
    });

    testWidgets('annotates the system chrome to match the color',
        (tester) async {
      await tester.pumpWidget(const SolidScreenColor(color: Colors.white));

      final style = _styleOf(tester);
      expect(style.statusBarColor, Colors.white);
      expect(style.systemNavigationBarColor, Colors.white);
      expect(style.systemNavigationBarDividerColor, Colors.white);
      expect(style.statusBarBrightness, Brightness.dark);
      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.systemNavigationBarIconBrightness, Brightness.dark);
      expect(style.systemStatusBarContrastEnforced, isFalse);
      expect(style.systemNavigationBarContrastEnforced, isFalse);

      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.white);
    });
  });
}
