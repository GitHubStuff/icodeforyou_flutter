// animated_widgets/test/src/fader_widget/fader_widget_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FaderWidget', () {
    late FaderCubit cubit;

    setUp(() => cubit = FaderCubit());
    tearDown(() => cubit.close());

    Widget wrap({
      Duration duration = const Duration(milliseconds: 100),
      TextStyle? style = const TextStyle(fontSize: 18),
    }) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: FaderWidget(
            cubit: cubit,
            duration: duration,
            style: style,
          ),
        ),
      ),
    );

    testWidgets('renders an empty string before the first push',
        (tester) async {
      await tester.pumpWidget(wrap());

      // state.current is null → builder falls back to ''.
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, '');
    });

    testWidgets('renders the pushed string', (tester) async {
      await tester.pumpWidget(wrap());

      cubit.push('hello');
      await tester.pump(); // rebuild with the new string
      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('forwards the supplied text style', (tester) async {
      const style = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      await tester.pumpWidget(wrap(style: style));

      cubit.push('styled');
      await tester.pump();
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('styled'));
      expect(text.style, style);
    });

    testWidgets('wraps content in an AnimatedSwitcher with a Stack layout',
        (tester) async {
      await tester.pumpWidget(wrap());
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      // layoutBuilder uses a Stack to overlap crossfading children.
      expect(
        find.descendant(
          of: find.byType(AnimatedSwitcher),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reports fadeStarted to the cubit when a string appears',
        (tester) async {
      await tester.pumpWidget(wrap());

      cubit.push('first');
      await tester.pump(); // listener fires → cubit.fadeStarted()

      expect(cubit.state.isAnimating, isTrue);
    });

    testWidgets('reports fadeComplete and drains the FIFO queue end to end',
        (tester) async {
      await tester.pumpWidget(wrap());

      // Show 'first', then queue 'second' while the first fade is in flight.
      cubit.push('first');
      await tester.pump();
      expect(cubit.state.isAnimating, isTrue);

      cubit.push('second');
      await tester.pump();
      expect(cubit.state.queue, ['second']);

      // Settle the first fade — _FadeReporter.onFadeIn → cubit.fadeComplete()
      // pulls 'second' off the queue and shows it.
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(cubit.state.current, 'second');
      expect(cubit.state.queue, isEmpty);
    });

    testWidgets('does not rebuild when the displayed string is unchanged',
        (tester) async {
      await tester.pumpWidget(wrap());

      cubit.push('same');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('same'), findsOneWidget);

      // fadeStarted flips isAnimating, producing a genuinely new state whose
      // `current` is unchanged. buildWhen / listenWhen key on current only, so
      // they must short-circuit: the text stays put and no exception fires.
      cubit.fadeStarted();
      await tester.pump();
      expect(find.text('same'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the default duration, curve and style when omitted',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FaderWidget(cubit: cubit)),
          ),
        ),
      );

      cubit.push('defaults');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('defaults'), findsOneWidget);
    });

    testWidgets('disposes cleanly mid-fade without leaking listeners',
        (tester) async {
      await tester.pumpWidget(wrap(duration: const Duration(seconds: 1)));

      cubit.push('fading');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tear down the widget while the fade is still running so
      // _FadeReporter.dispose removes its status listener.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fades across three sequential pushes', (tester) async {
      await tester.pumpWidget(wrap());

      cubit.push('one');
      await tester.pump();
      cubit
        ..push('two')
        ..push('three');
      await tester.pump();
      expect(cubit.state.queue, ['two', 'three']);

      await tester.pumpAndSettle();
      expect(cubit.state.current, 'three');
      expect(cubit.state.queue, isEmpty);
      expect(find.text('three'), findsOneWidget);
    });
  });
}
