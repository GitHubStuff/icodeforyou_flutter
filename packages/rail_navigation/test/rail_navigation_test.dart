// packages/rail_navigation/test/rail_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/rail_navigation.dart';

void main() {
  group('rail_navigation barrel', () {
    test('exports the public API surface', () {
      expect(RailButton, isA<Type>());
      expect(MainRailButton, isA<Type>());
      expect(MoreRailButton, isA<Type>());
      expect(SettingsRailButton, isA<Type>());
      expect(RailOverflowButton, isA<Type>());
      expect(showRailPopover, isA<Function>());
      expect(RailPopoverTile, isA<Type>());
      expect(RailShell, isA<Type>());
      expect(RailTransition.values, hasLength(4));
      expect(RailPlacement.values, hasLength(3));
      expect(RailWidget, isA<Type>());
    });

    testWidgets('exported widgets construct through the barrel', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RailWidget(
              children: [
                MainRailButton(onPressed: () {}),
                SettingsRailButton(onPressed: () {}),
                MoreRailButton(onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(RailWidget), findsOneWidget);
      expect(find.byType(RailButton), findsNWidgets(3));
    });
  });
}
