// packages/animated_widgets/test/src/fader_widget/src/fader_widget_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real cubit behaviour plus call counts, so the widget's reporting contract
/// (fadeStarted on a new string, fadeComplete when the fade settles) can be
/// verified without stubbing the cubit's stream.
class _SpyFaderCubit extends FaderCubit {
  int fadeStartedCalls = 0;
  int fadeCompleteCalls = 0;

  @override
  void fadeStarted() {
    fadeStartedCalls++;
    super.fadeStarted();
  }

  @override
  void fadeComplete() {
    fadeCompleteCalls++;
    super.fadeComplete();
  }
}

void main() {
  Widget host(FaderCubit cubit, {Duration? duration, TextStyle? style}) {
    return MaterialApp(
      home: Scaffold(
        body: FaderWidget(
          cubit: cubit,
          duration: duration ?? const Duration(milliseconds: 200),
          curve: Curves.linear,
          style: style,
        ),
      ),
    );
  }

  group('FaderWidget', () {
    testWidgets('shows an empty string and reports nothing before any push',
        (tester) async {
      final cubit = _SpyFaderCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(host(cubit));

      // state.current is null on the seed state: covers the `?? ''` fallback.
      expect(find.text(''), findsOneWidget);
      expect(cubit.fadeStartedCalls, 0);
      expect(cubit.fadeCompleteCalls, 0);

      await tester.pumpAndSettle();
    });

    testWidgets('fades in a pushed string and reports the fade lifecycle',
        (tester) async {
      final cubit = _SpyFaderCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(host(cubit));

      cubit.push('hello');
      await tester.pump(); // deliver the new string, fire listener, start fade

      // The widget reported the fade start exactly once; the follow-up
      // isAnimating emission leaves `current` unchanged, so listenWhen/buildWhen
      // return false and neither re-fires.
      expect(cubit.fadeStartedCalls, 1);
      expect(cubit.state.isAnimating, isTrue);

      await tester.pumpAndSettle(); // let the crossfade complete

      expect(find.text('hello'), findsOneWidget);
      expect(find.text(''), findsNothing);
      // Only the incoming child reaches AnimationStatus.completed, so completion
      // is reported once; the outgoing child animates in reverse and is ignored.
      expect(cubit.fadeCompleteCalls, 1);
      expect(cubit.state.isAnimating, isFalse);
    });

    testWidgets('applies the provided style and keys the Text on its content',
        (tester) async {
      final cubit = FaderCubit()..push('styled');
      addTearDown(cubit.close);
      const style = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

      await tester.pumpWidget(host(cubit, style: style));
      await tester.pump();

      final text = tester.widget<Text>(find.text('styled'));
      expect(text.style, style);
      expect(text.key, const ValueKey<String>('styled'));

      await tester.pumpAndSettle();
    });

    testWidgets('removes its status listener when unmounted mid-fade',
        (tester) async {
      final cubit = FaderCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(host(cubit, duration: const Duration(seconds: 1)));
      cubit.push('in-flight');
      await tester.pump(); // fade is now running, not yet complete

      await tester.pumpWidget(const SizedBox()); // unmount -> dispose reporters

      expect(find.byType(FaderWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
