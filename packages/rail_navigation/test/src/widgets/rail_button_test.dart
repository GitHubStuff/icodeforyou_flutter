// packages/rail_navigation/test/src/widgets/rail_button_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Material _buttonMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(
      of: find.byType(RailButton),
      matching: find.byType(Material),
    ),
  );
}

void main() {
  group('RailButton', () {
    test('asserts when neither icon nor caption is provided', () {
      expect(
        () => RailButton(onPressed: () {}),
        throwsAssertionError,
      );
    });

    testWidgets('builds with an icon only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('builds with a caption only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            caption: const Text('Home'),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('builds with both icon and caption stacked vertically', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
            caption: const Text('Home'),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      final iconCenter = tester.getCenter(find.byIcon(Icons.home));
      final captionCenter = tester.getCenter(find.text('Home'));
      expect(iconCenter.dy, lessThan(captionCenter.dy));
    });

    testWidgets('occupies the default 48x48 footprint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
          ),
        ),
      );

      expect(tester.getSize(find.byType(RailButton)), const Size(48, 48));
    });

    testWidgets('occupies a custom size when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
            caption: const Text('Home'),
            size: const Size(64, 64),
          ),
        ),
      );

      expect(tester.getSize(find.byType(RailButton)), const Size(64, 64));
    });

    testWidgets('paints a transparent surface when not selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
          ),
        ),
      );

      expect(_buttonMaterial(tester).color, Colors.transparent);
    });

    testWidgets('paints the provided tint when selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
            isSelected: true,
            tint: Colors.amber,
          ),
        ),
      );

      expect(_buttonMaterial(tester).color, Colors.amber);
    });

    testWidgets('falls back to secondaryContainer when selected without tint', (
      tester,
    ) async {
      final theme = ThemeData();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: RailButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
                isSelected: true,
              ),
            ),
          ),
        ),
      );

      expect(
        _buttonMaterial(tester).color,
        theme.colorScheme.secondaryContainer,
      );
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () => pressed++,
            icon: const Icon(Icons.home),
          ),
        ),
      );

      await tester.tap(find.byType(RailButton));
      expect(pressed, 1);
    });

    testWidgets('invokes onPressed when haptics are disabled', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () => pressed++,
            icon: const Icon(Icons.home),
            hapticIntensity: HapticIntensity.none,
          ),
        ),
      );

      await tester.tap(find.byType(RailButton));
      expect(pressed, 1);
    });

    testWidgets('exposes button and selection semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RailButton(
            onPressed: () {},
            icon: const Icon(Icons.home),
            isSelected: true,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(RailButton)),
        isSemantics(isButton: true, isSelected: true),
      );
    });
  });
}
