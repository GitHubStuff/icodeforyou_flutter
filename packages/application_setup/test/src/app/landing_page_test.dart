// test/src/app/landing_page_test.dart

import 'package:application_setup/src/app/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LandingPage', () {
    testWidgets('renders child inside Scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingPage(
            child: Text('landing'),
          ),
        ),
      );
      expect(find.text('landing'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
