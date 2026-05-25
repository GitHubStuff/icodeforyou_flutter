// animated_widgets/test/src/fade_in_out_view/fade_in_out_view_test.dart
import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FadeInOutView', () {
    const duration = Duration(milliseconds: 300);
    const childKey = Key('child');
    const child = SizedBox(key: childKey, width: 10, height: 10);

    Future<void> pumpView(
      WidgetTester tester, {
      double startOpacity = 1.0,
      double endOpacity = 0.0,
      Curve curve = Curves.easeInOut,
      VoidCallback? onComplete,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FadeInOutView(
            duration: duration,
            startOpacity: startOpacity,
            endOpacity: endOpacity,
            curve: curve,
            onComplete: onComplete,
            child: child,
          ),
        ),
      );
    }

    FadeTransition findFadeTransition(WidgetTester tester) =>
        tester.widget<FadeTransition>(find.byType(FadeTransition));

    testWidgets('renders child inside a FadeTransition', (tester) async {
      await pumpView(tester);

      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byKey(childKey), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('fades from 1.0 to 0.0 by default over duration',
        (tester) async {
      await pumpView(tester);

      expect(findFadeTransition(tester).opacity.value, 1.0);

      await tester.pumpAndSettle();
      expect(findFadeTransition(tester).opacity.value, 0.0);
    });

    testWidgets('fades from 0.0 to 1.0 when configured as fade-in',
        (tester) async {
      await pumpView(tester, startOpacity: 0.0, endOpacity: 1.0);

      expect(findFadeTransition(tester).opacity.value, 0.0);

      await tester.pumpAndSettle();
      expect(findFadeTransition(tester).opacity.value, 1.0);
    });

    testWidgets('respects a custom curve', (tester) async {
      await pumpView(tester, curve: Curves.linear);

      await tester.pump(duration ~/ 2);
      expect(
        findFadeTransition(tester).opacity.value,
        moreOrLessEquals(0.5, epsilon: 0.01),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('invokes onComplete when the animation completes',
        (tester) async {
      var calls = 0;
      await pumpView(tester, onComplete: () => calls++);

      expect(calls, 0);

      await tester.pumpAndSettle();
      expect(calls, 1);
    });

    testWidgets('does not throw when onComplete is null', (tester) async {
      await pumpView(tester);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its AnimationController without leaks',
        (tester) async {
      await pumpView(tester);

      // Replace the widget tree to trigger dispose() on the State.
      await tester.pumpWidget(const SizedBox.shrink());

      expect(find.byType(FadeInOutView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    group('asserts', () {
      test('throws when startOpacity is below 0.0', () {
        expect(
          () => FadeInOutView(
            duration: duration,
            startOpacity: -0.1,
            child: child,
          ),
          throwsAssertionError,
        );
      });

      test('throws when startOpacity is above 1.0', () {
        expect(
          () => FadeInOutView(
            duration: duration,
            startOpacity: 1.1,
            child: child,
          ),
          throwsAssertionError,
        );
      });

      test('throws when endOpacity is below 0.0', () {
        expect(
          () => FadeInOutView(
            duration: duration,
            endOpacity: -0.1,
            child: child,
          ),
          throwsAssertionError,
        );
      });

      test('throws when endOpacity is above 1.0', () {
        expect(
          () => FadeInOutView(
            duration: duration,
            endOpacity: 1.1,
            child: child,
          ),
          throwsAssertionError,
        );
      });
    });
  });
}
