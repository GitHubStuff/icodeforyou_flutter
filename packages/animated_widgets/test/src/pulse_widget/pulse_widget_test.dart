// packages/animated_widgets/test/src/pulse_widget/pulse_widget_test.dart

import 'package:animated_widgets/src/pulse_widget/pulse_widget.dart'
    show PulseWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PulseWidget', () {
    testWidgets('pulses the child through its build chain', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PulseWidget(
            rate: const Duration(milliseconds: 10),
            onComplete: () {},
            child: const SizedBox(width: 10, height: 10, key: Key('child')),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('renders with default rate, peakScale and no onComplete', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PulseWidget(
            child: SizedBox(width: 10, height: 10, key: Key('child')),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
