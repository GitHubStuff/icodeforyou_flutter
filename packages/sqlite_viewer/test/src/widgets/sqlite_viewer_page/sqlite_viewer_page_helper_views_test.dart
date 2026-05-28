// test/src/widgets/sqlite_viewer_page/sqlite_viewer_page_helper_views_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Widget wrap(Widget child) {
    return testableWidgetWithScaffold(
      SizedBox(width: 800, height: 600, child: child),
    );
  }

  group('DisconnectedView', () {
    testWidgets('renders link_off icon and "Not connected"', (tester) async {
      await tester.pumpWidget(wrap(buildDisconnectedViewForTesting()));
      expect(find.byIcon(Icons.link_off), findsOneWidget);
      expect(find.text('Not connected'), findsOneWidget);
    });
  });

  group('LoadingView', () {
    testWidgets('renders progress indicator and message', (tester) async {
      await tester.pumpWidget(
        wrap(buildLoadingViewForTesting(message: 'Loading users...')),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading users...'), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('renders error icon and message without retry', (tester) async {
      await tester.pumpWidget(
        wrap(buildErrorViewForTesting(message: 'Boom')),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Boom'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('renders Retry button when onRetry provided', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        wrap(
          buildErrorViewForTesting(
            message: 'Boom',
            onRetry: () => retried++,
          ),
        ),
      );
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, 1);
    });
  });

  group('EmptyDataView', () {
    testWidgets('renders touch_app icon and prompt', (tester) async {
      await tester.pumpWidget(wrap(buildEmptyDataViewForTesting()));
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
      expect(find.text('Select a table to view data'), findsOneWidget);
    });
  });

  group('SelectTablePrompt', () {
    testWidgets('renders arrow_back icon and both prompt strings',
        (tester) async {
      await tester.pumpWidget(wrap(buildSelectTablePromptForTesting()));
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Select a table from the sidebar'), findsOneWidget);
      expect(find.text('or enter a custom query below'), findsOneWidget);
    });
  });

  group('QueryResultView', () {
    testWidgets('shows "no results" when rows empty', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildQueryResultViewForTesting(
            query: 'SELECT * FROM users',
            columns: const [],
            rows: const [],
          ),
        ),
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Query returned no results'), findsOneWidget);
    });

    testWidgets('renders query header with row count when rows present',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildQueryResultViewForTesting(
            query: 'SELECT * FROM users',
            columns: const ['id', 'name'],
            rows: const [
              {'id': 1, 'name': 'Alice'},
              {'id': 2, 'name': 'Bob'},
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.text('SELECT * FROM users'), findsOneWidget);
      expect(find.text('2 rows'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('passes through showRowNumbers, nullValueDisplay, textHandling',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildQueryResultViewForTesting(
            query: 'SELECT * FROM users',
            columns: const ['id', 'name'],
            rows: const [
              {'id': 1, 'name': null},
            ],
            showRowNumbers: true,
            nullValueDisplay: '<null>',
            textHandling: TextHandling.wrap,
          ),
        ),
      );
      expect(find.text('#'), findsOneWidget);
      expect(find.text('<null>'), findsOneWidget);
    });
  });
}
