// packages/spinners/test/src/platform_spinner/platform_spinner_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:spinners/spinners.dart' show PlatformSpinner, SpinWidget;

void main() {
  Widget buildBoilerplate(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('PlatformSpinner - 100% coverage', () {
    testWidgets('uses fallback OSPlatform.current when osPlatform is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: 40.0,
            osPlatform: null,
          ),
        ),
      );

      expect(find.byType(PlatformSpinner), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets(
      'renders Android CircularProgressIndicator with correct props',
      (tester) async {
        const testSize = 50.0;
        const testColor = Colors.red;

        await tester.pumpWidget(
          buildBoilerplate(
            const PlatformSpinner(
              size: testSize,
              color: testColor,
              osPlatform: OSPlatform.android,
            ),
          ),
        );

        final indicatorFinder = find.byType(CircularProgressIndicator);
        expect(indicatorFinder, findsOneWidget);

        final indicator = tester.widget<CircularProgressIndicator>(
          indicatorFinder,
        );
        expect(indicator.color, testColor);
        expect(indicator.strokeWidth, testSize * 0.07);
      },
    );

    testWidgets('renders iOS CupertinoActivityIndicator with correct radius', (
      tester,
    ) async {
      const testSize = 60.0;
      const testColor = Colors.blue;

      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: testSize,
            color: testColor,
            osPlatform: OSPlatform.iOS,
          ),
        ),
      );

      final indicatorFinder = find.byType(CupertinoActivityIndicator);
      expect(indicatorFinder, findsOneWidget);

      final indicator = tester.widget<CupertinoActivityIndicator>(
        indicatorFinder,
      );
      expect(indicator.radius, testSize / 2);
      expect(indicator.color, testColor);
      expect(indicator.animating, isTrue);
    });

    testWidgets('renders macOS CupertinoActivityIndicator', (
      tester,
    ) async {
      const testSize = 30.0;

      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: testSize,
            osPlatform: OSPlatform.macOS,
          ),
        ),
      );

      final indicatorFinder = find.byType(CupertinoActivityIndicator);
      expect(indicatorFinder, findsOneWidget);

      final indicator = tester.widget<CupertinoActivityIndicator>(
        indicatorFinder,
      );
      expect(indicator.radius, testSize / 2);
      expect(indicator.color, isNull);
    });

    testWidgets('renders Fuchsia SpinWidget with ClipOval', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: 40.0,
            osPlatform: OSPlatform.fuchsia,
          ),
        ),
      );

      expect(find.byType(SpinWidget), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('renders Linux SpinWidget with Tux image', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: 45.0,
            osPlatform: OSPlatform.linux,
          ),
        ),
      );

      expect(find.byType(SpinWidget), findsOneWidget);
    });

    testWidgets('renders Web SpinWidget with Web asset', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: 55.0,
            osPlatform: OSPlatform.web,
          ),
        ),
      );

      expect(find.byType(SpinWidget), findsOneWidget);
    });

    testWidgets('renders Windows SpinWidget with glyph extension', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildBoilerplate(
          const PlatformSpinner(
            size: 48.0,
            osPlatform: OSPlatform.windows,
          ),
        ),
      );

      expect(find.byType(SpinWidget), findsOneWidget);
    });
  });
}
