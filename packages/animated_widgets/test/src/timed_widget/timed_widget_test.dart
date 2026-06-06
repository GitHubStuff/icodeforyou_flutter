// animated_widgets/test/src/timed_widget/timed_widget_test.dart
import 'package:animated_widgets/src/timed_widget/timed_widget.dart'
    show TimedWidget;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _childKey = Key('timed_child');

Widget _subject({
  required Duration duration,
  required VoidCallback onFinish,
  Key childKey = _childKey,
}) {
  return TimedWidget(
    duration: duration,
    onFinish: onFinish,
    child: SizedBox(key: childKey),
  );
}

void main() {
  group('TimedWidget', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        _subject(duration: const Duration(seconds: 1), onFinish: () {}),
      );

      expect(find.byKey(_childKey), findsOneWidget);

      // Cancel the pending timer before the test ends.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('invokes onFinish once after the duration elapses', (
      tester,
    ) async {
      var finished = 0;

      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 1),
          onFinish: () => finished++,
        ),
      );
      expect(finished, 0);

      await tester.pump(const Duration(seconds: 1));
      expect(finished, 1);
    });

    testWidgets('does not invoke onFinish before the duration elapses', (
      tester,
    ) async {
      var finished = 0;

      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 1),
          onFinish: () => finished++,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(finished, 0);

      // Removing the widget disposes the state and cancels the pending timer.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(finished, 0);
    });

    testWidgets('resets the timer when the duration changes', (tester) async {
      var finished = 0;

      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 1),
          onFinish: () => finished++,
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(finished, 0);

      // Change the duration -> didUpdateWidget cancels and restarts the timer.
      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 2),
          onFinish: () => finished++,
        ),
      );

      // Past the ORIGINAL 1s deadline; the cancelled timer must not fire.
      await tester.pump(const Duration(milliseconds: 500));
      expect(finished, 0);

      // The fresh 2s timer fires on its own schedule.
      await tester.pump(const Duration(seconds: 2));
      expect(finished, 1);
    });

    testWidgets('keeps the original timer when the duration is unchanged', (
      tester,
    ) async {
      var finished = 0;

      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 1),
          onFinish: () => finished++,
          childKey: const Key('a'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Rebuild with the SAME duration but a new child -> didUpdateWidget runs
      // but must not reset the timer.
      await tester.pumpWidget(
        _subject(
          duration: const Duration(seconds: 1),
          onFinish: () => finished++,
          childKey: const Key('b'),
        ),
      );
      expect(find.byKey(const Key('b')), findsOneWidget);

      // The original timer keeps its schedule and fires at 1.0s.
      await tester.pump(const Duration(milliseconds: 500));
      expect(finished, 1);
    });

    testWidgets('uses the default duration when none is provided', (
      tester,
    ) async {
      var finished = 0;

      await tester.pumpWidget(
        TimedWidget(
          onFinish: () => finished++,
          child: const SizedBox(key: _childKey),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1250));
      expect(finished, 1);
    });
  });
}
