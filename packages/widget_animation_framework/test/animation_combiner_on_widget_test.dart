// packages/widget_motion/test/src/animation_combiner_on_widget_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget;

const Key _kChildKey = Key('child');
const double _kTolerance = 0.0001;

const double _kScaleBegin = 0.8;
const double _kScaleEnd = 1.2;
const double _kOpacityBegin = 0;
const double _kOpacityEnd = 1;
const double _kTurnsBegin = 40 / 360;
const double _kTurnsEnd = 2;

const double _kStart = 0;
const double _kMidpoint = 0.5;
const double _kEnd = 1;

Future<void> _pumpCombiner(
  WidgetTester tester, {
  required double at,
  Tween<double>? scale,
  Tween<double>? opacity,
  Tween<double>? turns,
}) {
  return tester.pumpWidget(
    AnimationCombinerOnWidget(
      animation: AlwaysStoppedAnimation<double>(at),
      scale: scale,
      opacity: opacity,
      turns: turns,
      child: const SizedBox.shrink(key: _kChildKey),
    ),
  );
}

Tween<double> _scaleTween() =>
    Tween<double>(begin: _kScaleBegin, end: _kScaleEnd);

Tween<double> _opacityTween() =>
    Tween<double>(begin: _kOpacityBegin, end: _kOpacityEnd);

Tween<double> _turnsTween() =>
    Tween<double>(begin: _kTurnsBegin, end: _kTurnsEnd);

void main() {
  group('AnimationCombinerOnWidget', () {
    testWidgets('renders the child when no tween is supplied', (tester) async {
      await _pumpCombiner(tester, at: _kStart);

      expect(find.byKey(_kChildKey), findsOneWidget);
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(ScaleTransition), findsNothing);
      expect(find.byType(RotationTransition), findsNothing);
    });

    testWidgets('adds only the transitions whose tweens are supplied', (
      tester,
    ) async {
      await _pumpCombiner(tester, at: _kStart, opacity: _opacityTween());

      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsNothing);
      expect(find.byType(RotationTransition), findsNothing);
    });

    testWidgets('composes all three transitions when all are supplied', (
      tester,
    ) async {
      await _pumpCombiner(
        tester,
        at: _kStart,
        scale: _scaleTween(),
        opacity: _opacityTween(),
        turns: _turnsTween(),
      );

      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.byKey(_kChildKey), findsOneWidget);
    });

    testWidgets('nests rotation outside scale outside fade', (tester) async {
      await _pumpCombiner(
        tester,
        at: _kStart,
        scale: _scaleTween(),
        opacity: _opacityTween(),
        turns: _turnsTween(),
      );

      expect(
        find.ancestor(
          of: find.byType(ScaleTransition),
          matching: find.byType(RotationTransition),
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
    });

    testWidgets('evaluates every tween at the begin value', (tester) async {
      await _pumpCombiner(
        tester,
        at: _kStart,
        scale: _scaleTween(),
        opacity: _opacityTween(),
        turns: _turnsTween(),
      );

      expect(
        tester
            .widget<ScaleTransition>(find.byType(ScaleTransition))
            .scale
            .value,
        closeTo(_kScaleBegin, _kTolerance),
      );
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(_kOpacityBegin, _kTolerance),
      );
      expect(
        tester
            .widget<RotationTransition>(find.byType(RotationTransition))
            .turns
            .value,
        closeTo(_kTurnsBegin, _kTolerance),
      );
    });

    testWidgets('evaluates every tween at the midpoint value', (tester) async {
      await _pumpCombiner(
        tester,
        at: _kMidpoint,
        scale: _scaleTween(),
        opacity: _opacityTween(),
        turns: _turnsTween(),
      );

      expect(
        tester
            .widget<ScaleTransition>(find.byType(ScaleTransition))
            .scale
            .value,
        closeTo((_kScaleBegin + _kScaleEnd) / 2, _kTolerance),
      );
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo((_kOpacityBegin + _kOpacityEnd) / 2, _kTolerance),
      );
      expect(
        tester
            .widget<RotationTransition>(find.byType(RotationTransition))
            .turns
            .value,
        closeTo((_kTurnsBegin + _kTurnsEnd) / 2, _kTolerance),
      );
    });

    testWidgets('evaluates every tween at the end value', (tester) async {
      await _pumpCombiner(
        tester,
        at: _kEnd,
        scale: _scaleTween(),
        opacity: _opacityTween(),
        turns: _turnsTween(),
      );

      expect(
        tester
            .widget<ScaleTransition>(find.byType(ScaleTransition))
            .scale
            .value,
        closeTo(_kScaleEnd, _kTolerance),
      );
      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(_kOpacityEnd, _kTolerance),
      );
      expect(
        tester
            .widget<RotationTransition>(find.byType(RotationTransition))
            .turns
            .value,
        closeTo(_kTurnsEnd, _kTolerance),
      );
    });

    testWidgets('tracks a driving animation without an intervening pump', (
      tester,
    ) async {
      final driver = ValueNotifier<double>(_kStart);
      addTearDown(driver.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<double>(
          valueListenable: driver,
          builder: (context, value, child) => AnimationCombinerOnWidget(
            animation: AlwaysStoppedAnimation<double>(value),
            opacity: _opacityTween(),
            child: const SizedBox.shrink(key: _kChildKey),
          ),
        ),
      );

      driver.value = _kEnd;
      await tester.pump();

      expect(
        tester
            .widget<FadeTransition>(find.byType(FadeTransition))
            .opacity
            .value,
        closeTo(_kOpacityEnd, _kTolerance),
      );
    });
  });
}
