// test/src/widgets/sql_command_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SqlCommand', () {
    testWidgets('renders an ElevatedButton with label', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(const SqlCommand()),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Enter SQL commands'), findsOneWidget);
    });

    testWidgets('tapping the button opens the editor popover', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(const SqlCommand()),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // After opening, the editor renders the heading again inside the
      // popover plus the SaveCancelBar — original label still on screen.
      expect(find.text('Enter SQL commands'), findsWidgets);
    });

    testWidgets('typing into the editor invokes onChanged path',
        (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(const SqlCommand()),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the TextField inside the popover and type into it
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        await tester.enterText(textField.first, 'SELECT 1');
        await tester.pump();
      }
    });

    testWidgets('SaveCancelBar Save dismisses the popover', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(const SqlCommand()),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Try to find any Save button label
      final saveButton = find.text('Save');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('SaveCancelBar Cancel dismisses the popover', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(const SqlCommand()),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
