// packages/rail_navigation/test/src/widgets/rail_popover_tile_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_popover_tile.dart';

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Material(
        child: Center(child: SizedBox(width: 240, child: child)),
      ),
    ),
  );
}

void main() {
  group('RailPopoverTile', () {
    testWidgets('displays the label without an icon by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('displays a leading icon before the label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
            icon: Icon(Icons.star),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);

      final iconCenter = tester.getCenter(find.byIcon(Icons.star));
      final labelCenter = tester.getCenter(find.text('Alpha'));
      expect(iconCenter.dx, lessThan(labelCenter.dx));
    });

    testWidgets('has the fixed 48dp tile height', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(RailPopoverTile<String>)).height,
        48,
      );
    });

    testWidgets('highlights in the provided tint when selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
            isSelected: true,
            tint: Colors.amber,
          ),
        ),
      );

      final ink = tester.widget<Ink>(
        find.descendant(
          of: find.byType(RailPopoverTile<String>),
          matching: find.byType(Ink),
        ),
      );
      expect(ink.decoration, const BoxDecoration(color: Colors.amber));
    });

    testWidgets('falls back to secondaryContainer when selected without tint', (
      tester,
    ) async {
      final theme = ThemeData();
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
            isSelected: true,
          ),
          theme: theme,
        ),
      );

      final ink = tester.widget<Ink>(
        find.descendant(
          of: find.byType(RailPopoverTile<String>),
          matching: find.byType(Ink),
        ),
      );
      expect(
        ink.decoration,
        BoxDecoration(color: theme.colorScheme.secondaryContainer),
      );
    });

    testWidgets('shows no highlight when not selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
          ),
        ),
      );

      final ink = tester.widget<Ink>(
        find.descendant(
          of: find.byType(RailPopoverTile<String>),
          matching: find.byType(Ink),
        ),
      );
      expect(ink.decoration, isNull);
    });

    testWidgets('pops the enclosing route with its value when tapped', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      final future = navigatorKey.currentState!.push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const Material(
            child: Center(
              child: SizedBox(
                width: 240,
                child: RailPopoverTile<String>(
                  value: 'picked',
                  label: Text('Alpha'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RailPopoverTile<String>));
      await tester.pumpAndSettle();

      expect(await future, 'picked');
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('pops with its value when haptics are disabled', (
      tester,
    ) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      final future = navigatorKey.currentState!.push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const Material(
            child: Center(
              child: SizedBox(
                width: 240,
                child: RailPopoverTile<String>(
                  value: 'silent',
                  label: Text('Alpha'),
                  hapticIntensity: HapticIntensity.none,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RailPopoverTile<String>));
      await tester.pumpAndSettle();

      expect(await future, 'silent');
    });

    testWidgets('exposes button and selection semantics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const RailPopoverTile<String>(
            value: 'a',
            label: Text('Alpha'),
            isSelected: true,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(RailPopoverTile<String>)),
        isSemantics(isButton: true, isSelected: true),
      );
    });
  });
}
