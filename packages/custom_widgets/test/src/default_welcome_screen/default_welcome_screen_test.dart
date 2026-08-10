// packages/custom_widgets/test/src/default_welcome_screen/default_welcome_screen_test.dart

import 'package:analog_clock_widget/analog_clock_widget.dart' show AnalogClock;
import 'package:custom_widgets/custom_widgets.dart' show DefaultWelcomeScreen;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:three_d_sphere/three_d_sphere.dart' show ThreeDSphere;

void main() {
  setUpAll(() {
    // The Archivo Black face is not bundled with the test binary; forbid the
    // runtime fetch so the widget resolves without touching the network.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DefaultWelcomeScreen', () {
    testWidgets('composes clock, welcome label, and sphere on deep purple',
        (tester) async {
      // Swallow the google_fonts asset-miss report; layout is unaffected.
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('google_fonts')) return;
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(
        const MaterialApp(home: DefaultWelcomeScreen()),
      );
      await tester.pump();

      expect(find.byType(AnalogClock), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.byType(ThreeDSphere), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == Colors.deepPurple,
        ),
        findsOneWidget,
      );
    });
  });
}
