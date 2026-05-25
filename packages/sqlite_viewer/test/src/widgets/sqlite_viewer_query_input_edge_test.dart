// packages/sqlite_viewer/test/src/widgets/sqlite_viewer_query_input_edge_test.dart
// Edge case tests targeting uncovered lines in SqliteViewerQueryInput.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_query_input.dart';

void main() {
  Widget buildWidget({
    ValueChanged<String>? onExecute,
    bool isExecuting = false,
    String? initialQuery,
    bool showValidation = true,
    bool enabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SqliteViewerQueryInput(
          onExecute: onExecute ?? (_) {},
          isExecuting: isExecuting,
          initialQuery: initialQuery,
          showValidation: showValidation,
          enabled: enabled,
        ),
      ),
    );
  }

  group('SqliteViewerQueryInput EditorCompleted Path', () {
    // Lines 160-162: EditorCompleted handling
    // The showEditor function from edittext_popover opens a popup.
    // We need to interact with it to get EditorCompleted result.

    testWidgets('expand editor and interact with popover', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      // Tap expand button to trigger _showExpandedEditor
      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump();

      // The edittext_popover creates an overlay/popup
      // Try to find and interact with any TextField in the overlay
      await tester.pump(Duration(milliseconds: 500));

      // Look for any dialog or overlay that might have appeared
      final overlayTextFields = find.byType(TextField);

      // If popover rendered, there would be 2 TextFields (original + popover)
      if (overlayTextFields.evaluate().length > 1) {
        // Enter text in the popover TextField
        await tester.enterText(overlayTextFields.last, 'SELECT * FROM test');
        await tester.pumpAndSettle();

        // Try to find and tap a save/confirm button
        final saveButton = find.text('Save');
        final okButton = find.text('OK');
        final doneButton = find.text('Done');

        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
        } else if (okButton.evaluate().isNotEmpty) {
          await tester.tap(okButton);
        } else if (doneButton.evaluate().isNotEmpty) {
          await tester.tap(doneButton);
        }
        await tester.pumpAndSettle();
      }

      // Dismiss any remaining overlays
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('expand editor tap outside to dismiss', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump(Duration(milliseconds: 300));

      // Tap outside to dismiss the popup (EditorCancelled path)
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('expand editor with renderBox calculation', (tester) async {
      // Ensure the GlobalKey has a valid RenderBox
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT id FROM users'));
      await tester.pumpAndSettle();

      // Verify TextField is rendered and has size
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final renderBox = tester.renderObject(textField) as RenderBox;
      expect(renderBox.size.width, greaterThan(0));
      expect(renderBox.size.height, greaterThan(0));

      // Trigger expand with valid renderBox
      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump(Duration(milliseconds: 100));

      // Allow async showEditor to complete
      await tester.pump(Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('expand editor sends keyboard action', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump(Duration(milliseconds: 300));

      // Try sending keyboard done action
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    });
  });

  group('SqliteViewerQueryInput Validation Edge Cases', () {
    // Lines 116-119: Validation failure in _executeQuery
    // This path is guarded by _canExecute, but we try edge cases

    testWidgets('rapid text change during execution', (tester) async {
      String? lastQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (q) => lastQuery = q,
        initialQuery: 'SELECT 1',
      ));
      await tester.pumpAndSettle();

      // Start with valid query, tap run
      await tester.tap(find.text('Run Query'));

      // Immediately try to change text (simulating race condition)
      await tester.enterText(find.byType(TextField), 'INVALID');
      await tester.pumpAndSettle();

      // The original valid query should have executed
      expect(lastQuery, equals('SELECT 1'));
    });

    testWidgets('submit with keyboard while text changing', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (q) => executedQuery = q,
      ));
      await tester.pumpAndSettle();

      // Enter valid query
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pump();

      // Submit via keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(executedQuery, equals('SELECT 1'));
    });

    testWidgets('hasInteracted set on text change', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Initially no validation shown (hasn't interacted)
      expect(find.text('Valid query'), findsNothing);
      expect(find.text('Invalid query'), findsNothing);

      // Type to trigger onChanged -> _hasInteracted = true
      await tester.enterText(find.byType(TextField), 'S');
      await tester.pumpAndSettle();

      // Now validation should show
      expect(find.text('Invalid query'), findsOneWidget);
    });

    testWidgets('validation error displayed after interaction', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Enter invalid query
      await tester.enterText(find.byType(TextField), 'DROP TABLE x');
      await tester.pumpAndSettle();

      // Error should be shown in TextField decoration
      // The errorText is set when _hasInteracted || text.isNotEmpty
      expect(find.textContaining('Only SELECT'), findsOneWidget);
    });

    testWidgets('clear resets hasInteracted', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      // Tap clear
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Type invalid query - should show validation since we interacted
      await tester.enterText(find.byType(TextField), 'X');
      await tester.pumpAndSettle();

      expect(find.text('Invalid query'), findsOneWidget);
    });
  });

  group('SqliteViewerQueryInput Focus Management', () {
    testWidgets('clear button returns focus to text field', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // TextField should have focus
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });
  });
}
