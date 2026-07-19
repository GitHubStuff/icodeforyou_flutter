// animated_widgets/test/src/fade_in_out_view/fade_in_out_view_test.dart

import 'package:animated_widgets/animated_widgets.dart' show FadeInOutView;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const childKey = Key('fade-child');
  const fadeDuration = Duration(milliseconds: 200);

  Future<void> pumpFade(
    WidgetTester tester, {
    Duration duration = fadeDuration,
    double startOpacity = 1.0,
    double endOpacity = 0.0,
    Curve curve = Curves.easeInOut,
    VoidCallback? onComplete,
    Widget child = const SizedBox(key: childKey),
  }) {
    return tester.pumpWidget(
      FadeInOutView(
        duration: duration,
        startOpacity: startOpacity,
        endOpacity: endOpacity,
        curve: curve,
        onComplete: onComplete,
        child: child,
      ),
    );
  }

  double currentOpacity(WidgetTester tester) => tester
      .widget<FadeTransition>(find.byType(FadeTransition))
      .opacity
      .value;

  group('FadeInOutView', () {
    testWidgets('wraps its child in a FadeTransition', (tester) async {
      await pumpFade(tester);

      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byKey(childKey), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets(
      'animates from startOpacity to endOpacity (fade-out default)',
      (tester) async {
        await pumpFade(tester);

        expect(currentOpacity(tester), 1.0);
        await tester.pumpAndSettle();
        expect(currentOpacity(tester), 0.0);
      },
    );

    testWidgets(
      'supports a fade-in with custom opacities and curve',
      (tester) async {
        await pumpFade(
          tester,
          startOpacity: 0.0,
          endOpacity: 1.0,
          curve: Curves.linear,
        );

        expect(currentOpacity(tester), 0.0);
        await tester.pumpAndSettle();
        expect(currentOpacity(tester), 1.0);
      },
    );

    testWidgets('invokes onComplete once when the fade finishes',
        (tester) async {
      var completed = 0;
      await pumpFade(tester, onComplete: () => completed++);

      expect(completed, 0); // not reported until the animation completes
      await tester.pumpAndSettle();
      expect(completed, 1);
    });

    testWidgets('completes without error when onComplete is null',
        (tester) async {
      await pumpFade(tester); // onComplete defaults to null

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its controller when removed mid-animation',
        (tester) async {
      await pumpFade(tester, duration: const Duration(seconds: 1));
      expect(find.byType(FadeInOutView), findsOneWidget);

      await tester.pumpWidget(const SizedBox());

      expect(find.byType(FadeInOutView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    group('opacity-bound asserts', () {
      test('rejects a startOpacity above 1.0', () {
        expect(
          () => FadeInOutView(
            duration: fadeDuration,
            startOpacity: 1.5,
            child: const SizedBox(),
          ),
          throwsAssertionError,
        );
      });

      test('rejects a negative endOpacity', () {
        expect(
          () => FadeInOutView(
            duration: fadeDuration,
            endOpacity: -0.1,
            child: const SizedBox(),
          ),
          throwsAssertionError,
        );
      });
    });
  });
}
