// packages/widget_animation_framework/test/play_on_mount_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart';

const Key _kChildKey = Key('child');
const double _kTolerance = 0.0001;

const Duration _kDuration = Duration(milliseconds: 1000);
const Duration _kHalfDuration = Duration(milliseconds: 500);
const Duration _kLongerDuration = Duration(milliseconds: 2000);

const double _kStart = 0;
const double _kMidpoint = 0.5;
const double _kEnd = 1;

void main() {
  group('PlayOnMount', () {
    testWidgets('starts the timeline at zero on mount', (tester) async {
      late Animation<double> animation;

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          builder: (context, value) {
            animation = value;
            return const SizedBox.shrink(key: _kChildKey);
          },
        ),
      );

      expect(find.byKey(_kChildKey), findsOneWidget);
      expect(animation.value, closeTo(_kStart, _kTolerance));

      await tester.pumpAndSettle();
    });

    testWidgets('advances the timeline over the supplied duration', (
      tester,
    ) async {
      late Animation<double> animation;

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          builder: (context, value) {
            animation = value;
            return const SizedBox.shrink(key: _kChildKey);
          },
        ),
      );

      await tester.pump(_kHalfDuration);
      expect(animation.value, closeTo(_kMidpoint, _kTolerance));

      await tester.pump(_kHalfDuration);
      expect(animation.value, closeTo(_kEnd, _kTolerance));

      await tester.pumpAndSettle();
    });

    testWidgets('applies the supplied curve to the timeline', (tester) async {
      late Animation<double> animation;

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.easeIn,
          builder: (context, value) {
            animation = value;
            return const SizedBox.shrink(key: _kChildKey);
          },
        ),
      );

      await tester.pump(_kHalfDuration);

      expect(
        animation.value,
        closeTo(Curves.easeIn.transform(_kMidpoint), _kTolerance),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('invokes onCompleted exactly once when the timeline ends', (
      tester,
    ) async {
      var completions = 0;

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          onCompleted: () => completions++,
          builder: (context, value) => const SizedBox.shrink(key: _kChildKey),
        ),
      );

      expect(completions, isZero);

      await tester.pump(_kHalfDuration);
      expect(completions, isZero);

      await tester.pumpAndSettle();
      expect(completions, 1);

      await tester.pump(_kDuration);
      expect(completions, 1);
    });

    testWidgets('tolerates a null onCompleted', (tester) async {
      await tester.pumpWidget(
        const PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          builder: _buildChild,
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('invokes the callback supplied by the most recent build', (
      tester,
    ) async {
      var firstCallbackCalls = 0;
      var secondCallbackCalls = 0;

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          onCompleted: () => firstCallbackCalls++,
          builder: (context, value) => const SizedBox.shrink(key: _kChildKey),
        ),
      );

      await tester.pump(_kHalfDuration);

      await tester.pumpWidget(
        PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          onCompleted: () => secondCallbackCalls++,
          builder: (context, value) => const SizedBox.shrink(key: _kChildKey),
        ),
      );

      await tester.pumpAndSettle();

      expect(firstCallbackCalls, isZero);
      expect(secondCallbackCalls, 1);
    });

    testWidgets('rebinds the timeline when the curve changes', (tester) async {
      late Animation<double> animation;

      Widget build(Curve curve) => PlayOnMount(
        duration: _kDuration,
        curve: curve,
        builder: (context, value) {
          animation = value;
          return const SizedBox.shrink(key: _kChildKey);
        },
      );

      await tester.pumpWidget(build(Curves.linear));
      await tester.pump(_kHalfDuration);
      expect(animation.value, closeTo(_kMidpoint, _kTolerance));

      await tester.pumpWidget(build(Curves.easeIn));
      expect(
        animation.value,
        closeTo(Curves.easeIn.transform(_kMidpoint), _kTolerance),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('accepts a duration change without throwing', (tester) async {
      Widget build(Duration duration) => PlayOnMount(
        duration: duration,
        curve: Curves.linear,
        builder: (context, value) => const SizedBox.shrink(key: _kChildKey),
      );

      await tester.pumpWidget(build(_kDuration));
      await tester.pumpWidget(build(_kLongerDuration));

      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('releases the timeline when removed from the tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        const PlayOnMount(
          duration: _kDuration,
          curve: Curves.linear,
          builder: _buildChild,
        ),
      );

      await tester.pump(_kHalfDuration);
      await tester.pumpWidget(const SizedBox.shrink());

      expect(find.byKey(_kChildKey), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildChild(BuildContext context, Animation<double> animation) =>
    const SizedBox.shrink(key: _kChildKey);
