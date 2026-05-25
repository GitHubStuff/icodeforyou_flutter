// test/src/_settings_dismiss_button_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/_settings_dismiss_button.dart';

void main() {
  group('SettingsDismissButton', () {
    testWidgets('renders close icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDismissButton(onDismiss: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('fires onDismiss when tapped', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDismissButton(onDismiss: () => dismissed = true),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('aligns to top right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsDismissButton(onDismiss: () {}),
          ),
        ),
      );

      // The outermost Align is the direct child of SettingsDismissButton's
      // build — find it by key proximity using the widget tree order.
      final aligns = tester
          .widgetList<Align>(
            find.descendant(
              of: find.byType(SettingsDismissButton),
              matching: find.byType(Align),
            ),
          )
          .toList();

      expect(aligns.first.alignment, Alignment.topRight);
    });
  });
}
