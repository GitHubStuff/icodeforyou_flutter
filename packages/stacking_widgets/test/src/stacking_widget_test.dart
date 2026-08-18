// packages/stacking_widgets/test/src/stacking_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacking_widgets/stacking_widgets.dart'
    show PiledWidget, StackingWidgets;

void main() {
  group('StackingWidgets', () {
    const baseKey = Key('base_key');
    const baseWidget = SizedBox(key: baseKey);
    const validSize = Size(200, 300);

    test('constructor assigns properties correctly', () {
      const key = Key('stacking_key');
      const piledWidgets = <PiledWidget>[];

      const widget = StackingWidgets(
        key: key,
        base: baseWidget,
        size: validSize,
        piledWidgets: piledWidgets,
      );

      expect(widget.key, key);
      expect(widget.base, baseWidget);
      expect(widget.size, validSize);
      expect(widget.piledWidgets, piledWidgets);
    });

    testWidgets('throws AssertionError when size.width <= 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: StackingWidgets(
            base: baseWidget,
            size: Size(0, 100),
            piledWidgets: [],
          ),
        ),
      );

      final dynamic exception = tester.takeException();
      expect(exception, isA<AssertionError>());
      expect(
        (exception as AssertionError).message,
        'size.width must be greater than zero',
      );
    });

    testWidgets('throws AssertionError when size.height <= 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: StackingWidgets(
            base: baseWidget,
            size: Size(100, -5),
            piledWidgets: [],
          ),
        ),
      );

      final dynamic exception = tester.takeException();
      expect(exception, isA<AssertionError>());
      expect(
        (exception as AssertionError).message,
        'size.height must be greater than zero',
      );
    });

    testWidgets('renders base widget and piled widgets correctly', (
      WidgetTester tester,
    ) async {
      const child1Key = Key('child1_key');
      const child2Key = Key('child2_key');
      const offset1 = Offset(10, 20);
      const offset2 = Offset(-15, 30);

      final piledWidgets = [
        const PiledWidget(
          offset: offset1,
          child: SizedBox(key: child1Key),
        ),
        const PiledWidget(
          offset: offset2,
          child: SizedBox(key: child2Key),
        ),
      ];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StackingWidgets(
            base: baseWidget,
            size: validSize,
            piledWidgets: piledWidgets,
          ),
        ),
      );

      // Verify outer SizedBox dimensions
      final sizedBoxFinder = find
          .ancestor(
            of: find.byType(Stack),
            matching: find.byType(SizedBox),
          )
          .first;
      final sizedBoxWidget = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBoxWidget.width, validSize.width);
      expect(sizedBoxWidget.height, validSize.height);

      // Verify Stack configuration
      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);
      final stackWidget = tester.widget<Stack>(stackFinder);
      expect(stackWidget.clipBehavior, Clip.none);
      expect(stackWidget.alignment, Alignment.center);

      // Verify the base is rendered inside an Align
      final baseAlignFinder = find.ancestor(
        of: find.byKey(baseKey),
        matching: find.byType(Align),
      );
      expect(
        baseAlignFinder,
        findsWidgets,
      ); // Contains multiple elements due to tree depth
      final baseAlign = tester.widget<Align>(baseAlignFinder.first);
      expect(baseAlign.alignment, Alignment.center);

      // Verify PiledWidgets are destructured and rendered
      expect(find.byKey(child1Key), findsOneWidget);
      expect(find.byKey(child2Key), findsOneWidget);

      // Verify first PiledWidget transforms
      final transform1Finder = find
          .ancestor(
            of: find.byKey(child1Key),
            matching: find.byType(Transform),
          )
          .first;
      final transform1 = tester.widget<Transform>(transform1Finder);
      expect(
        transform1.transform,
        Matrix4.translationValues(offset1.dx, offset1.dy, 0.0),
      );

      // Verify second PiledWidget transforms
      final transform2Finder = find
          .ancestor(
            of: find.byKey(child2Key),
            matching: find.byType(Transform),
          )
          .first;
      final transform2 = tester.widget<Transform>(transform2Finder);
      expect(
        transform2.transform,
        Matrix4.translationValues(offset2.dx, offset2.dy, 0.0),
      );
    });
  });
}
