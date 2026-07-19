// packages/animated_widgets/test/src/grow_widget/grow_animation_mixin_test.dart
import 'package:animated_widgets/src/grow_widget/grow_animation_mixin.dart'
    show GrowAnimationMixin;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _duration = Duration(milliseconds: 300);

/// Minimal host that exercises [GrowAnimationMixin] in isolation, independent
/// of any production widget that happens to use it.
class _GrowHost extends StatefulWidget {
  const _GrowHost({
    required this.duration,
    required this.curve,
    this.onComplete,
    this.autoStart = false,
  });

  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;
  final bool autoStart;

  @override
  State<_GrowHost> createState() => _GrowHostState();
}

class _GrowHostState extends State<_GrowHost>
    with SingleTickerProviderStateMixin, GrowAnimationMixin {
  /// Surfaces the `@protected` [growController] for assertions; reading it here
  /// is the call that exercises the mixin's accessor.
  AnimationController get controller => growController;

  @override
  void initState() {
    super.initState();
    initAnimation(
      vsync: this,
      duration: widget.duration,
      curve: widget.curve,
      onComplete: widget.onComplete,
    );
    if (widget.autoStart) startAnimation();
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

Future<_GrowHostState> _pumpHost(
  WidgetTester tester, {
  Duration duration = _duration,
  Curve curve = Curves.linear,
  VoidCallback? onComplete,
  bool autoStart = false,
}) async {
  await tester.pumpWidget(
    _GrowHost(
      duration: duration,
      curve: curve,
      onComplete: onComplete,
      autoStart: autoStart,
    ),
  );
  return tester.state<_GrowHostState>(find.byType(_GrowHost));
}

void main() {
  group('GrowAnimationMixin', () {
    testWidgets('initialises a dismissed controller and a curved 0→1 scale', (
      tester,
    ) async {
      final state = await _pumpHost(tester);

      expect(state.controller.duration, _duration);
      expect(state.controller.value, moreOrLessEquals(0, epsilon: 1e-6));
      expect(state.controller.status, AnimationStatus.dismissed);
      expect(state.scaleAnimation.value, moreOrLessEquals(0, epsilon: 1e-6));
    });

    testWidgets('startAnimation runs the controller forward to completion', (
      tester,
    ) async {
      final state = await _pumpHost(tester);

      state.startAnimation();
      // First pump only establishes the ticker's epoch (elapsed == 0);
      // the second pump advances the clock from that epoch.
      await tester.pump();
      await tester.pump(_duration ~/ 4);

      expect(state.controller.status, AnimationStatus.forward);
      expect(state.controller.value, greaterThan(0));
      expect(state.controller.value, lessThan(1));

      await tester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.completed);
      expect(state.controller.value, moreOrLessEquals(1, epsilon: 1e-6));
      expect(state.scaleAnimation.value, moreOrLessEquals(1, epsilon: 1e-6));
    });

    testWidgets('threads the supplied curve into scaleAnimation', (
      tester,
    ) async {
      const curve = Curves.easeOutCubic;
      final state = await _pumpHost(tester, curve: curve);

      state.startAnimation();
      // Epoch tick first, then advance to the true midpoint.
      await tester.pump();
      await tester.pump(_duration ~/ 2);

      // Controller sits at ~0.5; scale must reflect curve.transform(0.5),
      // not the raw controller value — proving the curve is applied.
      final expected = curve.transform(0.5);
      expect(
        state.scaleAnimation.value,
        moreOrLessEquals(expected, epsilon: 1e-3),
      );
      expect((state.scaleAnimation.value - 0.5).abs(), greaterThan(0.05));

      await tester.pumpAndSettle();
    });

    testWidgets('invokes onComplete exactly once on completion', (
      tester,
    ) async {
      var calls = 0;
      final state = await _pumpHost(tester, onComplete: () => calls++);

      state.startAnimation();
      // Epoch tick, then a genuine mid-flight frame: completion must not
      // have fired at the halfway point.
      await tester.pump();
      await tester.pump(_duration ~/ 2);
      expect(calls, 0);

      await tester.pumpAndSettle();
      expect(calls, 1);
    });

    testWidgets('registers no status listener when onComplete is null', (
      tester,
    ) async {
      final state = await _pumpHost(tester, autoStart: true);

      await tester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.completed);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposeAnimation disposes the controller', (tester) async {
      final state = await _pumpHost(tester, autoStart: true);
      await tester.pump(_duration ~/ 2);

      final controller = state.controller;

      // Removing the host triggers State.dispose -> disposeAnimation(); a leaked
      // controller would surface as a ticker-leak exception at teardown.
      await tester.pumpWidget(const SizedBox.shrink());

      expect(find.byType(_GrowHost), findsNothing);
      expect(tester.takeException(), isNull);
      // A disposed controller rejects further driving.
      expect(controller.forward, throwsA(isA<AssertionError>()));
    });
  });
}
