// test/src/navigation/startup_router_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startup_package/src/navigation/_startup_router.dart';

void main() {
  group('StartupRouter', () {
    testWidgets(
      'navigateToLanding replaces current route with landing page',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StartupRouter.navigateToLanding(
                  context,
                  const _LandingPage(),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.byType(_LandingPage), findsOneWidget);
      },
    );

    testWidgets(
      'navigateToLanding removes splash from back stack',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StartupRouter.navigateToLanding(
                  context,
                  const _LandingPage(),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.text('Go'), findsNothing);
        expect(find.byType(_LandingPage), findsOneWidget);
      },
    );

    testWidgets(
      'cross-fade transition completes within 3.5 seconds',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => StartupRouter.navigateToLanding(
                  context,
                  const _LandingPage(),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 3500));

        expect(find.byType(_LandingPage), findsOneWidget);
      },
    );
  });
}

class _LandingPage extends StatelessWidget {
  const _LandingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Landing')),
    );
  }
}
