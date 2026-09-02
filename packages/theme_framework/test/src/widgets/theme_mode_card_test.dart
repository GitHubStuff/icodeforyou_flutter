// packages/theme_framework/test/src/widgets/theme_mode_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_framework/theme_framework.dart' show ThemeModeCard;

void main() {
  group('ThemeModeCard', () {
    testWidgets('renders header, all options, and highlights Light mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeModeCard(
              value: ThemeMode.light,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify header text
      expect(find.text('Appearance'), findsOneWidget);

      // Verify the labels for the modes
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Verify the leading icons
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

      // Verify the correct tile is selected (should only have 1 checkmark)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Verify the underlying ListTile selected property
      final listTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      expect(listTiles.length, 3);
      expect(listTiles[0].selected, isTrue); // Light
      expect(listTiles[1].selected, isFalse); // Dark
      expect(listTiles[2].selected, isFalse); // System
    });

    testWidgets('highlights Dark mode when value is ThemeMode.dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeModeCard(
              value: ThemeMode.dark,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final listTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      expect(listTiles[0].selected, isFalse); // Light
      expect(listTiles[1].selected, isTrue); // Dark
      expect(listTiles[2].selected, isFalse); // System
    });

    testWidgets('highlights System mode when value is ThemeMode.system', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeModeCard(
              value: ThemeMode.system,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final listTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      expect(listTiles[0].selected, isFalse); // Light
      expect(listTiles[1].selected, isFalse); // Dark
      expect(listTiles[2].selected, isTrue); // System
    });

    testWidgets(
      'calls onChanged with the correct ThemeMode when tiles are tapped',
      (tester) async {
        ThemeMode? tappedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ThemeModeCard(
                value: ThemeMode.system, // Start with system
                onChanged: (mode) => tappedValue = mode,
              ),
            ),
          ),
        );

        // Tap Light
        await tester.tap(find.text('Light'));
        await tester.pump();
        expect(tappedValue, ThemeMode.light);

        // Tap Dark
        await tester.tap(find.text('Dark'));
        await tester.pump();
        expect(tappedValue, ThemeMode.dark);

        // Tap System
        await tester.tap(find.text('System'));
        await tester.pump();
        expect(tappedValue, ThemeMode.system);
      },
    );
  });
}
