// packages/stacking_widgets/test/src/piled_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Replace with your actual import path
import 'package:stacking_widgets/src/piled_widget.dart';

void main() {
  group('PiledWidget', () {
    test('constructor assigns properties correctly', () {
      const child = SizedBox();
      const offset = Offset(10, 15);
      const key = Key('piled_key');

      const widget = PiledWidget(
        key: key,
        offset: offset,
        child: child,
      );

      expect(widget.child, child);
      expect(widget.offset, offset);
      expect(widget.key, key);
    });

    test('constructor uses Offset.zero by default', () {
      const child = SizedBox();
      const widget = PiledWidget(child: child);

      expect(widget.offset, Offset.zero);
    });

    testWidgets('renders Stack with Clip.none and Transform.translate', (
      WidgetTester tester,
    ) async {
      const childKey = Key('child_key');
      const offset = Offset(20, 30);

      await tester.pumpWidget(
        const MaterialApp(
          home: PiledWidget(
            offset: offset,
            child: SizedBox(key: childKey, width: 50, height: 50),
          ),
        ),
      );

      // Verify the Stack is rendered with Clip.none
      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);
      final stackWidget = tester.widget<Stack>(stackFinder);
      expect(stackWidget.clipBehavior, Clip.none);

      // Verify Transform is applied
      final transformFinder = find.byType(Transform);
      expect(transformFinder, findsOneWidget);
      final transformWidget = tester.widget<Transform>(transformFinder);

      // Verify the translation matrix matches the provided offset
      final expectedMatrix = Matrix4.translationValues(
        offset.dx,
        offset.dy,
        0.0,
      );
      expect(transformWidget.transform, expectedMatrix);

      // Verify the child is rendered
      expect(find.byKey(childKey), findsOneWidget);
    });
  });
}
