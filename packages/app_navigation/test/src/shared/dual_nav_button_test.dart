// packages/app_navigation/test/src/shared/dual_nav_button_test.dart
import 'package:app_navigation/src/shared/dual_nav_button.dart';
import 'package:extensions/enum/src/haptic_intensity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required VoidCallback onPressed,
    Widget? icon,
    Widget? caption,
    Size size = const Size(48, 48),
    bool isSelected = false,
    Color? tint,
    HapticIntensity hapticIntensity = HapticIntensity.light,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: DualNavButton(
            onPressed: onPressed,
            icon: icon,
            caption: caption,
            size: size,
            isSelected: isSelected,
            tint: tint,
            hapticIntensity: hapticIntensity,
          ),
        ),
      ),
    );
  }

  group('DualNavButton', () {
    testWidgets(
      'renders both icon and caption with default parameters',
      (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          buildSubject(
            onPressed: () => pressed = true,
            icon: const Icon(Icons.home),
            caption: const Text('Home'),
          ),
        );

        expect(find.byType(DualNavButton), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);

        // Verify Semantics
        final semanticsFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == false,
          ),
        );
        expect(semanticsFinder, findsOneWidget);

        // Verify root SizedBox size
        final sizedBoxFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 48 && widget.height == 48,
          ),
        );
        expect(sizedBoxFinder, findsOneWidget);

        // Verify root stadium Material
        final stadiumMaterialFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.shape == const StadiumBorder() &&
                widget.color == Colors.transparent,
          ),
        );
        expect(stadiumMaterialFinder, findsOneWidget);

        // Verify tap triggers onPressed
        await tester.tap(find.byType(DualNavButton));
        await tester.pump();
        expect(pressed, isTrue);
      },
    );

    testWidgets(
      'renders only icon when caption is null',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            onPressed: () {},
            icon: const Icon(Icons.star),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      },
    );

    testWidgets(
      'renders only caption when icon is null',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            onPressed: () {},
            caption: const Text('Profile'),
          ),
        );

        expect(find.text('Profile'), findsOneWidget);
        expect(find.byType(Icon), findsNothing);
      },
    );

    testWidgets(
      'uses custom tint when selected and custom tint is provided',
      (tester) async {
        const customTint = Colors.deepOrange;

        await tester.pumpWidget(
          buildSubject(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            isSelected: true,
            tint: customTint,
            size: const Size(64, 64),
          ),
        );

        final semanticsFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == true,
          ),
        );
        expect(semanticsFinder, findsOneWidget);

        final stadiumMaterialFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.shape == const StadiumBorder() &&
                widget.color == customTint,
          ),
        );
        expect(stadiumMaterialFinder, findsOneWidget);

        final sizedBoxFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 64 && widget.height == 64,
          ),
        );
        expect(sizedBoxFinder, findsOneWidget);
      },
    );

    testWidgets(
      'falls back to theme secondaryContainer color when selected and tint is null',
      (tester) async {
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(
            secondaryContainer: Colors.purple,
          ),
        );

        await tester.pumpWidget(
          buildSubject(
            onPressed: () {},
            icon: const Icon(Icons.person),
            isSelected: true,
            theme: theme,
          ),
        );

        final stadiumMaterialFinder = find.descendant(
          of: find.byType(DualNavButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.shape == const StadiumBorder() &&
                widget.color == Colors.purple,
          ),
        );
        expect(stadiumMaterialFinder, findsOneWidget);
      },
    );

    group('Assertions', () {
      test(
        'throws AssertionError when both icon and caption are null',
        () {
          expect(
            () => DualNavButton(
              onPressed: () {},
              icon: null,
              caption: null,
            ),
            throwsAssertionError,
          );
        },
      );
    });
  });
}
