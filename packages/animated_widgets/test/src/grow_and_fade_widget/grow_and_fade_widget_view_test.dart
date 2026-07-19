// animated_widgets/test/src/grow_and_fade_widget/grow_and_fade_widget_view_test.dart
import 'package:animated_widgets/src/grow_and_fade_widget/grow_and_fade_widget_view.dart'
    show GrowAndFadeWidgetView;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _childKey = Key('grow_and_fade_child');
const _duration = Duration(milliseconds: 300);

Widget _child() => const SizedBox(key: _childKey, width: 40, height: 40);

Future<void> _pumpView(
  WidgetTester tester, {
  Duration duration = _duration,
  Curve curve = Curves.easeOut,
  VoidCallback? onComplete,
  bool useDefaultCurve = false,
}) {
  final view = useDefaultCurve
      ? GrowAndFadeWidgetView(
          duration: duration,
          onComplete: onComplete,
          child: _child(),
        )
      : GrowAndFadeWidgetView(
          duration: duration,
          curve: curve,
          onComplete: onComplete,
          child: _child(),
        );
  return tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: view));
}

double _scale(WidgetTester tester) =>
    tester.widget<ScaleTransition>(find.byType(ScaleTransition)).scale.value;

double _opacity(WidgetTester tester) =>
    tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value;

void main() {
  group('GrowAndFadeWidgetView', () {
    testWidgets('nests child inside Center > ScaleTransition > FadeTransition', (
      tester,
    ) async {
      await _pumpView(tester);

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byKey(_childKey), findsOneWidget);

      expect(
        find.ancestor(
          of: find.byType(ScaleTransition),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(FadeTransition),
          matching: find.byType(ScaleTransition),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byKey(_childKey),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );

      // Let the in-flight animation finish so the ticker is disposed cleanly.
      await tester.pumpAndSettle();
    });

    testWidgets('starts fully scaled-down and transparent', (tester) async {
      await _pumpView(tester, curve: Curves.linear);

      expect(_scale(tester), moreOrLessEquals(0, epsilon: 1e-6));
      expect(_opacity(tester), moreOrLessEquals(0, epsilon: 1e-6));

      await tester.pumpAndSettle();
    });

    testWidgets('keeps scale and opacity in lockstep throughout', (
      tester,
    ) async {
      await _pumpView(tester, curve: Curves.easeInOutCubic);

      const quarter = Duration(milliseconds: 75);
      for (var step = 0; step < 4; step++) {
        await tester.pump(quarter);
        expect(_scale(tester), moreOrLessEquals(_opacity(tester)));
      }

      await tester.pumpAndSettle();
    });

    testWidgets('applies the provided curve to both animations', (
      tester,
    ) async {
      await _pumpView(tester, curve: Curves.linear);

      await tester.pump(_duration ~/ 2);

      // Linear curve at the temporal midpoint => exactly 0.5 for both.
      expect(_scale(tester), moreOrLessEquals(0.5, epsilon: 1e-3));
      expect(_opacity(tester), moreOrLessEquals(0.5, epsilon: 1e-3));

      await tester.pumpAndSettle();
    });

    testWidgets('defaults to Curves.easeOut when no curve is supplied', (
      tester,
    ) async {
      await _pumpView(tester, useDefaultCurve: true);

      await tester.pump(_duration ~/ 2);

      final expected = Curves.easeOut.transform(0.5);
      expect(_scale(tester), moreOrLessEquals(expected, epsilon: 1e-3));
      // easeOut is non-linear, so the midpoint must not equal the linear 0.5.
      expect((_scale(tester) - 0.5).abs(), greaterThan(0.05));

      await tester.pumpAndSettle();
    });

    testWidgets('reaches full scale and opacity on completion', (tester) async {
      await _pumpView(tester, curve: Curves.linear);

      await tester.pumpAndSettle();

      expect(_scale(tester), moreOrLessEquals(1, epsilon: 1e-6));
      expect(_opacity(tester), moreOrLessEquals(1, epsilon: 1e-6));
    });

    testWidgets('invokes onComplete exactly once when the animation completes', (
      tester,
    ) async {
      var calls = 0;
      await _pumpView(tester, onComplete: () => calls++);

      expect(calls, 0);

      await tester.pumpAndSettle();

      expect(calls, 1);
    });

    testWidgets('does not require an onComplete callback', (tester) async {
      await _pumpView(tester);

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its controller when removed from the tree', (
      tester,
    ) async {
      await _pumpView(tester);
      await tester.pump(_duration ~/ 2);

      // Replacing the subtree triggers State.dispose -> disposeAnimation().
      // A leaked controller/ticker would surface as an exception here or at
      // teardown.
      await tester.pumpWidget(const SizedBox());

      expect(find.byType(GrowAndFadeWidgetView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
