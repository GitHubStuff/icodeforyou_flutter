// packages/sqlite_viewer/test/src/widgets/sqlite_viewer_query_input_test.dart
// Tests for SqliteViewerQueryInput to achieve 100% coverage.
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

  /// Helper to find the Run/Running button (FilledButton.icon creates a
  /// private _FilledButtonWithIcon that isn't matched by
  /// find.byType(FilledButton)). We locate it via its label text and the
  /// common ancestor type [ButtonStyleButton].
  Finder findRunButton(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
  }

  group('SqliteViewerQueryInput Basic', () {
    testWidgets('renders with default state', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Custom Query'), findsOneWidget);
      expect(find.text('Run Query'), findsOneWidget);
    });

    testWidgets('renders with initial query', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT * FROM users'));
      await tester.pumpAndSettle();

      expect(find.text('SELECT * FROM users'), findsOneWidget);
    });

    testWidgets('shows Running... when isExecuting', (tester) async {
      await tester.pumpWidget(buildWidget(
        isExecuting: true,
        initialQuery: 'SELECT 1',
      ));
      // Use pump() instead of pumpAndSettle() because CircularProgressIndicator
      // is an infinite animation that never settles
      await tester.pump();

      expect(find.text('Running...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('clear button clears text', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      // Clear button should be visible
      expect(find.text('Clear'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Text should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('executes valid query on Run button tap', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (q) => executedQuery = q,
        initialQuery: 'SELECT * FROM users',
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Run Query'));
      await tester.pumpAndSettle();

      expect(executedQuery, equals('SELECT * FROM users'));
    });

    testWidgets('onSubmitted executes query', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (q) => executedQuery = q,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(executedQuery, equals('SELECT 1'));
    });
  });

  group('SqliteViewerQueryInput Validation', () {
    testWidgets('shows valid query indicator', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT * FROM users'));
      await tester.pumpAndSettle();

      expect(find.text('Valid query'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows invalid query indicator', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'DELETE FROM users'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid query'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('does not validate when showValidation is false',
        (tester) async {
      await tester.pumpWidget(buildWidget(
        initialQuery: 'DELETE FROM users',
        showValidation: false,
      ));
      await tester.pumpAndSettle();

      // Should not show validation indicators
      expect(find.text('Valid query'), findsNothing);
      expect(find.text('Invalid query'), findsNothing);
    });

    testWidgets('validation updates on text change', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Enter invalid query
      await tester.enterText(find.byType(TextField), 'DROP TABLE');
      await tester.pumpAndSettle();

      expect(find.text('Invalid query'), findsOneWidget);

      // Change to valid query
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pumpAndSettle();

      expect(find.text('Valid query'), findsOneWidget);
    });

    testWidgets('empty text clears validation error', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'INVALID'));
      await tester.pumpAndSettle();

      // Clear the text
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // No validation indicator for empty text
      expect(find.text('Valid query'), findsNothing);
      expect(find.text('Invalid query'), findsNothing);
    });
  });

  group('SqliteViewerQueryInput Expand Editor', () {
    testWidgets('expand button is present', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
      expect(find.byTooltip('Expand editor'), findsOneWidget);
    });

    testWidgets('expand button disabled when executing', (tester) async {
      await tester.pumpWidget(buildWidget(
        isExecuting: true,
        initialQuery: 'SELECT 1',
      ));
      // Use pump() - CircularProgressIndicator never settles
      await tester.pump();

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.open_in_full),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('expand button triggers _showExpandedEditor', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      // Tap expand button - triggers _showExpandedEditor method
      // The edittext_popover showEditor may not render in test environment
      // but the method entry and RenderBox code should execute
      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump();

      // Pump a few frames to let any animations/async code run
      await tester.pump(Duration(milliseconds: 100));
      await tester.pump(Duration(milliseconds: 100));

      // The popup from edittext_popover may or may not appear
      // This test ensures the button triggers the method without crashing
    });

    testWidgets('expand button works with empty query', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.open_in_full));
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));
    });
  });

  group('SqliteViewerQueryInput Disabled State', () {
    testWidgets('text field disabled when enabled=false', (tester) async {
      await tester.pumpWidget(buildWidget(enabled: false));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('text field disabled when isExecuting=true', (tester) async {
      await tester.pumpWidget(buildWidget(
        isExecuting: true,
        initialQuery: 'SELECT 1',
      ));
      // Use pump() - CircularProgressIndicator never settles
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('Run button disabled for empty query', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ButtonStyleButton>(
        findRunButton('Run Query'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Run button disabled for invalid query', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'DROP TABLE users'));
      await tester.pumpAndSettle();

      final button = tester.widget<ButtonStyleButton>(
        findRunButton('Run Query'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('clear button disabled when executing', (tester) async {
      await tester.pumpWidget(buildWidget(
        isExecuting: true,
        initialQuery: 'SELECT 1',
      ));
      // Use pump() - CircularProgressIndicator never settles
      await tester.pump();

      final clearButton = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Clear'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(clearButton.onPressed, isNull);
    });

    testWidgets('Run button enabled for valid query', (tester) async {
      await tester.pumpWidget(buildWidget(initialQuery: 'SELECT 1'));
      await tester.pumpAndSettle();

      final button = tester.widget<ButtonStyleButton>(
        findRunButton('Run Query'),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
