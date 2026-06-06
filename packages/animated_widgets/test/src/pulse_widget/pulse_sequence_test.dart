// animated_widgets/test/src/pulse_widget/src/pulse_sequence_test.dart
import 'package:animated_widgets/animated_widgets.dart'
    show AnimationTween, CombinationAnimationStep;
import 'package:animated_widgets/src/combination_animation/widgets/combination_animation_sequenced.dart'
    show CombinationAnimationSequenced;
import 'package:animated_widgets/src/pulse_widget/src/pulse_sequence.dart'
    show PulseSequence;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _childKey = Key('pulse_child');

Widget _subject({required Widget child}) => Directionality(
      textDirection: TextDirection.ltr,
      child: PulseSequence(child: child),
    );

CombinationAnimationSequenced _sequenced(WidgetTester tester) =>
    tester.widget<CombinationAnimationSequenced>(
      find.byType(CombinationAnimationSequenced),
    );

void main() {
  group('PulseSequence', () {
    testWidgets('runs the full pulse sequence and tears down cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _subject(
          child: const SizedBox(key: _childKey, width: 80, height: 80),
        ),
      );

      expect(find.byKey(_childKey), findsOneWidget);

      // The sequence is finite, so it settles rather than looping.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Removal disposes the underlying animation controller cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });

    testWidgets('threads its config into a hold -> grow -> shrink sequence', (
      tester,
    ) async {
      await tester.pumpWidget(_subject(child: const SizedBox()));

      final config = tester.widget<PulseSequence>(find.byType(PulseSequence)).config;

      final expected = <CombinationAnimationStep>[
        // Hold at rest.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulseStartScale,
            finish: config.pulseRestScale,
          ),
          duration: config.holdDuration,
        ),
        // Grow to peak.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulseRestScale,
            finish: config.pulsePeakScale,
          ),
          duration: config.growDuration,
          curve: config.growCurve,
        ),
        // Return to rest.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulsePeakScale,
            finish: config.pulseRestScale,
          ),
          duration: config.shrinkDuration,
          curve: config.shrinkCurve,
        ),
      ];

      expect(_sequenced(tester).steps, expected);

      await tester.pumpAndSettle();
    });

    testWidgets('keeps a stable animation identity across rebuilds', (
      tester,
    ) async {
      await tester.pumpWidget(
        _subject(child: const SizedBox(width: 10, height: 10)),
      );
      final firstKey = _sequenced(tester).key;

      // Rebuild the same (unkeyed) PulseSequence with a different child. The
      // State persists, so the key created once in initState must not change.
      await tester.pumpWidget(
        _subject(child: const SizedBox(width: 20, height: 20)),
      );
      final secondKey = _sequenced(tester).key;

      expect(firstKey, isNotNull);
      expect(secondKey, same(firstKey));

      await tester.pumpAndSettle();
    });
  });
}
