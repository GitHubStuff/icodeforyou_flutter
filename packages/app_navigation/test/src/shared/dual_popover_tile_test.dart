// packages/app_navigation/test/src/shared/dual_popover_tile_test.dart
import 'package:app_navigation/src/shared/dual_popover_tile.dart';
import 'package:extensions/enum/src/haptic_intensity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject<T>({
    required T value,
    required Widget label,
    Widget? icon,
    bool isSelected = false,
    Color? tint,
    HapticIntensity hapticIntensity = HapticIntensity.light,
    ThemeData? theme,
    ValueChanged<T?>? onPopped,
  }) {
    return MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await showDialog<T>(
                    context: context,
                    builder: (_) => Scaffold(
                      body: DualPopoverTile<T>(
                        value: value,
                        label: label,
                        icon: icon,
                        isSelected: isSelected,
                        tint: tint,
                        hapticIntensity: hapticIntensity,
                      ),
                    ),
                  );
                  onPopped?.call(result);
                },
                child: const Text('Open Dialog'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('DualPopoverTile', () {
    testWidgets(
      'renders both icon and label with unselected default configuration',
      (tester) async {
        await tester.pumpWidget(
          buildSubject<String>(
            value: 'settings',
            label: const Text('Settings'),
            icon: const Icon(Icons.settings),
          ),
        );

        // Open dialog containing tile
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(DualPopoverTile<String>), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);

        // Verify Semantics
        final semanticsFinder = find.descendant(
          of: find.byType(DualPopoverTile<String>),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == false,
          ),
        );
        expect(semanticsFinder, findsOneWidget);

        // Verify Ink decoration when not selected (null)
        final ink = tester.widget<Ink>(
          find.descendant(
            of: find.byType(DualPopoverTile<String>),
            matching: find.byType(Ink),
          ),
        );
        expect(ink.decoration, isNull);

        // Verify tile height
        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(DualPopoverTile<String>),
            matching: find.byWidgetPredicate(
              (widget) => widget is SizedBox && widget.height == 48,
            ),
          ),
        );
        expect(sizedBox.height, equals(48));
      },
    );

    testWidgets('renders only label when icon is null', (tester) async {
      await tester.pumpWidget(
        buildSubject<String>(
          value: 'profile',
          label: const Text('Profile'),
          icon: null,
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets(
      'uses custom tint when selected and custom tint is provided',
      (tester) async {
        const customTint = Colors.amber;

        await tester.pumpWidget(
          buildSubject<String>(
            value: 'custom',
            label: const Text('Custom'),
            isSelected: true,
            tint: customTint,
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        final semanticsFinder = find.descendant(
          of: find.byType(DualPopoverTile<String>),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.button == true &&
                widget.properties.selected == true,
          ),
        );
        expect(semanticsFinder, findsOneWidget);

        final ink = tester.widget<Ink>(
          find.descendant(
            of: find.byType(DualPopoverTile<String>),
            matching: find.byType(Ink),
          ),
        );
        final decoration = ink.decoration as BoxDecoration?;
        expect(decoration?.color, equals(customTint));
      },
    );

    testWidgets(
      'falls back to theme secondaryContainer color when selected and tint is null',
      (tester) async {
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(
            secondaryContainer: Colors.indigo,
          ),
        );

        await tester.pumpWidget(
          buildSubject<String>(
            value: 'theme_test',
            label: const Text('Theme Test'),
            isSelected: true,
            theme: theme,
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        final ink = tester.widget<Ink>(
          find.descendant(
            of: find.byType(DualPopoverTile<String>),
            matching: find.byType(Ink),
          ),
        );
        final decoration = ink.decoration as BoxDecoration?;
        expect(decoration?.color, equals(Colors.indigo));
      },
    );

    testWidgets(
      'pops the navigator with the tile value when tapped',
      (tester) async {
        String? poppedResult;

        await tester.pumpWidget(
          buildSubject<String>(
            value: 'selected_destination',
            label: const Text('Tap Me'),
            onPopped: (val) => poppedResult = val,
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DualPopoverTile<String>));
        await tester.pumpAndSettle();

        expect(find.byType(DualPopoverTile<String>), findsNothing);
        expect(poppedResult, equals('selected_destination'));
      },
    );
  });
}
