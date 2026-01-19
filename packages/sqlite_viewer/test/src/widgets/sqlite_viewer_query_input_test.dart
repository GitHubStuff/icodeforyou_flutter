// test/src/widgets/sqlite_viewer_query_input_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SqliteViewerQueryInput', () {
    Widget buildWidget({
      required ValueChanged<String> onExecute,
      bool isExecuting = false,
      String? initialQuery,
      String hintText = 'SELECT * FROM table_name',
      int maxLines = 5,
      int minLines = 3,
      bool showValidation = true,
      bool enabled = true,
    }) {
      return testableWidgetWithScaffold(
        SqliteViewerQueryInput(
          onExecute: onExecute,
          isExecuting: isExecuting,
          initialQuery: initialQuery,
          hintText: hintText,
          maxLines: maxLines,
          minLines: minLines,
          showValidation: showValidation,
          enabled: enabled,
        ),
      );
    }

    testWidgets('displays Custom Query header', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.text('Custom Query'), findsOneWidget);
    });

    testWidgets('displays code icon', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('displays hint text when empty', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.text('SELECT * FROM table_name'), findsOneWidget);
    });

    testWidgets('displays custom hint text', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        hintText: 'Custom hint',
      ));
      
      expect(find.text('Custom hint'), findsOneWidget);
    });

    testWidgets('displays initial query', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        initialQuery: 'SELECT * FROM users',
      ));
      
      expect(find.text('SELECT * FROM users'), findsOneWidget);
    });

    testWidgets('displays Run Query button', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.text('Run Query'), findsOneWidget);
    });

    testWidgets('displays Running... when executing', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        isExecuting: true,
      ));
      
      expect(find.text('Running...'), findsOneWidget);
    });

    testWidgets('shows loading indicator when executing', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        isExecuting: true,
      ));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onExecute with query when Run button pressed',
        (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (query) => executedQuery = query,
        initialQuery: 'SELECT * FROM users',
      ));
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executedQuery, 'SELECT * FROM users');
    });

    testWidgets('does not call onExecute for invalid query', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (query) => executedQuery = query,
      ));
      
      // Enter invalid query
      await tester.enterText(find.byType(TextField), 'DROP TABLE users');
      await tester.pump();
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executedQuery, isNull);
    });

    testWidgets('does not call onExecute for empty query', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (query) => executedQuery = query,
      ));
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executedQuery, isNull);
    });

    testWidgets('shows validation feedback for valid query', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      await tester.enterText(find.byType(TextField), 'SELECT * FROM users');
      await tester.pump();
      
      expect(find.text('Valid query'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows validation feedback for invalid query', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      await tester.enterText(find.byType(TextField), 'DROP TABLE users');
      await tester.pump();
      
      expect(find.text('Invalid query'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('hides validation when showValidation is false', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        showValidation: false,
      ));
      
      await tester.enterText(find.byType(TextField), 'SELECT * FROM users');
      await tester.pump();
      
      expect(find.text('Valid query'), findsNothing);
    });

    testWidgets('shows Clear button when text entered', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.text('Clear'), findsNothing);
      
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pump();
      
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('clears text when Clear button pressed', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        initialQuery: 'SELECT * FROM users',
      ));
      
      expect(find.text('SELECT * FROM users'), findsOneWidget);
      
      await tester.tap(find.text('Clear'));
      await tester.pump();
      
      expect(find.text('SELECT * FROM users'), findsNothing);
    });

    testWidgets('shows expand button', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
    });

    testWidgets('disables input when not enabled', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        enabled: false,
      ));
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('disables input when executing', (tester) async {
      await tester.pumpWidget(buildWidget(
        onExecute: (_) {},
        isExecuting: true,
      ));
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows error text for invalid query after interaction',
        (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      await tester.enterText(find.byType(TextField), 'DROP TABLE users');
      await tester.pump();
      
      // Error text should appear in TextField decoration
      expect(
        find.text('Only SELECT and WITH statements are allowed'),
        findsOneWidget,
      );
    });

    testWidgets('Run button does not execute for empty text', (tester) async {
      String? executed;
      await tester.pumpWidget(buildWidget(onExecute: (q) => executed = q));
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executed, isNull);
    });

    testWidgets('Run button does not execute for invalid text', (tester) async {
      String? executed;
      await tester.pumpWidget(buildWidget(onExecute: (q) => executed = q));
      
      await tester.enterText(find.byType(TextField), 'DROP TABLE');
      await tester.pump();
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executed, isNull);
    });

    testWidgets('Run button executes for valid text', (tester) async {
      String? executed;
      await tester.pumpWidget(buildWidget(onExecute: (q) => executed = q));
      
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pump();
      
      await tester.tap(find.text('Run Query'));
      await tester.pump();
      
      expect(executed, 'SELECT 1');
    });

    testWidgets('submitting text field executes query', (tester) async {
      String? executedQuery;
      await tester.pumpWidget(buildWidget(
        onExecute: (query) => executedQuery = query,
      ));
      
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      
      expect(executedQuery, 'SELECT 1');
    });

    testWidgets('updating text sets hasInteracted', (tester) async {
      await tester.pumpWidget(buildWidget(onExecute: (_) {}));
      
      // Initially no validation shown
      expect(find.text('Valid query'), findsNothing);
      expect(find.text('Invalid query'), findsNothing);
      
      // After typing, validation appears
      await tester.enterText(find.byType(TextField), 'SELECT 1');
      await tester.pump();
      
      expect(find.text('Valid query'), findsOneWidget);
    });
  });
}