// packages/custom_widgets/test/src/crash_screen/crash_screen_test.dart

import 'package:custom_widgets/custom_widgets.dart' show CrashScreen;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart' show GoRoute, GoRouter;

/// Marker rendered by the resume destination route.
const String _kHomeMarker = 'home-marker';

/// Pumps [screen] as the initial location of a two-route [GoRouter].
Future<void> _pump(WidgetTester tester, CrashScreen screen) {
  final router = GoRouter(
    initialLocation: '/crash',
    routes: [
      GoRoute(path: '/crash', builder: (context, state) => screen),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text(_kHomeMarker)),
      ),
    ],
  );
  return tester.pumpWidget(MaterialApp.router(routerConfig: router));
}

void main() {
  group('CrashScreen', () {
    testWidgets('shows the headline and the error text', (tester) async {
      await _pump(tester, const CrashScreen(error: 'boom'));

      expect(find.text('Something went wrong'), findsOneWidget);
      final selectable = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectable.data, 'boom');
    });

    testWidgets('appends the stack trace when provided', (tester) async {
      final trace = StackTrace.fromString('trace-line');
      await _pump(tester, CrashScreen(error: 'boom', stackTrace: trace));

      final selectable = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectable.data, 'boom\n\ntrace-line');
    });

    testWidgets('hides both buttons when resumePath and onReport are null',
        (tester) async {
      await _pump(tester, const CrashScreen(error: 'boom'));

      expect(find.text('Report'), findsNothing);
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets('blocks system back via PopScope', (tester) async {
      await _pump(tester, const CrashScreen(error: 'boom'));

      expect(
        find.byWidgetPredicate((w) => w is PopScope && !w.canPop),
        findsOneWidget,
      );
    });

    testWidgets('report button fires onReport', (tester) async {
      var reported = 0;
      await _pump(
        tester,
        CrashScreen(error: 'boom', onReport: () => reported++),
      );

      await tester.tap(find.text('Report'));
      await tester.pump();

      expect(reported, 1);
    });

    testWidgets('resume button routes to resumePath', (tester) async {
      await _pump(
        tester,
        const CrashScreen(error: 'boom', resumePath: '/home'),
      );

      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      expect(find.text(_kHomeMarker), findsOneWidget);
    });
  });
}
