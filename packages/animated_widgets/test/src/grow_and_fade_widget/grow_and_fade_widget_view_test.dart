// test/grow_and_fade_widget_view_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GrowAndFadeWidgetView', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: Duration(milliseconds: 300),
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      expect(find.byType(GrowAndFadeWidgetView), findsOneWidget);
    });

    testWidgets('completes animation and calls onComplete', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: const Duration(milliseconds: 100),
            onComplete: () => completed = true,
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      expect(completed, false);
      await tester.pumpAndSettle();
      expect(completed, true);
    });

    testWidgets('works without onComplete callback', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: Duration(milliseconds: 100),
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GrowAndFadeWidgetView), findsOneWidget);
    });

    testWidgets('uses custom curve', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GrowAndFadeWidgetView), findsOneWidget);
    });

    testWidgets('handles zero duration', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: Duration.zero,
            onComplete: () => completed = true,
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(completed, true);
    });

    testWidgets('can be disposed mid-animation', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: GrowAndFadeWidgetView(
            duration: Duration(milliseconds: 500),
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(find.byType(GrowAndFadeWidgetView), findsNothing);
    });
  });
}
