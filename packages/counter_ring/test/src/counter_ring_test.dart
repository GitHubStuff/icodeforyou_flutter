// packages/counter_ring/test/src/counter_ring_test.dart
import 'package:counter_ring/counter_ring.dart' show CounterRing, CounterRingCubit, RangeProgressRing;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const interval = Duration(milliseconds: 100);

  CounterRingCubit buildCubit({
    double start = 0,
    double finish = 100,
    double step = 50,
  }) => CounterRingCubit(
    start: start,
    finish: finish,
    step: step,
    interval: interval,
  );

  Future<void> pumpRing(
    WidgetTester tester,
    CounterRing ring,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ring)));
  }

  RangeProgressRing findRing(WidgetTester tester) =>
      tester.widget<RangeProgressRing>(find.byType(RangeProgressRing));

  group('CounterRing', () {
    group('rendering', () {
      testWidgets('forwards state and styling to RangeProgressRing', (
        tester,
      ) async {
        final cubit = buildCubit(start: 10, finish: 90);

        await pumpRing(
          tester,
          CounterRing(
            ringCubit: cubit,
            size: 200,
            strokeWidth: 12,
            color: Colors.red,
            backgroundColor: Colors.blue,
          ),
        );

        final ring = findRing(tester);
        expect(ring.startValue, 10);
        expect(ring.finishValue, 90);
        expect(ring.currentValue, 10);
        expect(ring.size, 200);
        expect(ring.strokeWidth, 12);
        expect(ring.color, Colors.red);
        expect(ring.backgroundColor, Colors.blue);

        await cubit.close();
      });

      testWidgets('applies default size, stroke, and null colours', (
        tester,
      ) async {
        final cubit = buildCubit();

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        final ring = findRing(tester);
        expect(ring.size, 120);
        expect(ring.strokeWidth, 8);
        expect(ring.color, isNull);
        expect(ring.backgroundColor, isNull);

        await cubit.close();
      });

      testWidgets('rebuilds the ring as the cubit ticks', (tester) async {
        final cubit = buildCubit();

        await pumpRing(tester, CounterRing(ringCubit: cubit));
        expect(findRing(tester).currentValue, 0);

        cubit.start();
        await tester.pump(interval);
        expect(findRing(tester).currentValue, 50);

        await tester.pump(interval);
        expect(findRing(tester).currentValue, 100);

        await cubit.close();
      });

      testWidgets('provides the cubit to the subtree', (tester) async {
        final cubit = buildCubit();
        CounterRingCubit? provided;

        await pumpRing(
          tester,
          CounterRing(
            ringCubit: cubit,
            centerBuilder: (context, state) {
              provided = BlocProvider.of<CounterRingCubit>(context);
              return const SizedBox.shrink();
            },
          ),
        );

        expect(provided, same(cubit));

        await cubit.close();
      });
    });

    group('centerBuilder', () {
      testWidgets('uses the custom builder when provided', (tester) async {
        final cubit = buildCubit(start: 7);

        await pumpRing(
          tester,
          CounterRing(
            ringCubit: cubit,
            centerBuilder: (context, state) =>
                Text('custom ${state.currentValue}'),
          ),
        );

        expect(find.text('custom 7.0'), findsOneWidget);

        await cubit.close();
      });

      testWidgets('receives updated state on each tick', (tester) async {
        final cubit = buildCubit();
        final seen = <double>[];

        await pumpRing(
          tester,
          CounterRing(
            ringCubit: cubit,
            centerBuilder: (context, state) {
              seen.add(state.currentValue);
              return const SizedBox.shrink();
            },
          ),
        );

        cubit.start();
        await tester.pump(interval);
        await tester.pump(interval);

        expect(seen, containsAllInOrder(<double>[0, 50, 100]));

        await cubit.close();
      });
    });

    group('default centre', () {
      testWidgets('renders whole numbers without a decimal point', (
        tester,
      ) async {
        final cubit = buildCubit(start: 40);

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        expect(find.text('40'), findsOneWidget);
        expect(find.text('40.0'), findsNothing);

        await cubit.close();
      });

      testWidgets('renders fractional values to one decimal place', (
        tester,
      ) async {
        final cubit = buildCubit(start: 12.25);

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        expect(find.text('12.3'), findsOneWidget);

        await cubit.close();
      });

      testWidgets('uses headlineMedium from the theme', (tester) async {
        final cubit = buildCubit(start: 5);

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        final context = tester.element(find.text('5'));
        final text = tester.widget<Text>(find.text('5'));
        expect(text.style, Theme.of(context).textTheme.headlineMedium);

        await cubit.close();
      });
    });

    group('onValueChanged', () {
      testWidgets('fires on status-only changes and on every tick', (
        tester,
      ) async {
        final cubit = buildCubit();
        final values = <double>[];

        await pumpRing(
          tester,
          CounterRing(ringCubit: cubit, onValueChanged: values.add),
        );
        expect(values, isEmpty);

        cubit.start(); // status idle -> running, value unchanged
        await tester.pump();
        expect(values, [0]);

        await tester.pump(interval);
        expect(values, [0, 50]);

        await tester.pump(interval); // reaches finish
        expect(values, [0, 50, 100]);

        await cubit.close();
      });

      testWidgets('fires when stopped and resumed', (tester) async {
        final cubit = buildCubit(step: 10);
        final values = <double>[];

        await pumpRing(
          tester,
          CounterRing(ringCubit: cubit, onValueChanged: values.add),
        );

        cubit.start();
        await tester.pump(interval);
        cubit.stop();
        await tester.pump();
        cubit.start();
        await tester.pump();

        expect(values, [0, 10, 10, 10]);

        await cubit.close();
      });

      testWidgets('is optional', (tester) async {
        final cubit = buildCubit();

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        cubit.start();
        await tester.pump(interval);
        await tester.pump(interval);

        expect(findRing(tester).currentValue, 100);

        await cubit.close();
      });
    });

    group('onFinish', () {
      testWidgets('fires once with the finish value', (tester) async {
        final cubit = buildCubit(start: 0, finish: 100, step: 50);
        final finishes = <double>[];

        await pumpRing(
          tester,
          CounterRing(ringCubit: cubit, onFinish: finishes.add),
        );

        cubit.start();
        await tester.pump(interval);
        expect(finishes, isEmpty);

        await tester.pump(interval);
        expect(finishes, [100]);

        await tester.pump(interval * 3);
        expect(finishes, [100]);

        await cubit.close();
      });

      testWidgets('fires with the finish value when counting down', (
        tester,
      ) async {
        final cubit = buildCubit(start: 100, finish: 0, step: 50);
        final finishes = <double>[];

        await pumpRing(
          tester,
          CounterRing(ringCubit: cubit, onFinish: finishes.add),
        );

        cubit.start();
        await tester.pump(interval * 2);

        expect(finishes, [0]);

        await cubit.close();
      });

      testWidgets('is optional', (tester) async {
        final cubit = buildCubit();

        await pumpRing(tester, CounterRing(ringCubit: cubit));

        cubit.start();
        await tester.pump(interval * 2);

        expect(cubit.state.isFinished, isTrue);

        await cubit.close();
      });
    });

    group('ownership', () {
      testWidgets('does not close the cubit when disposed', (tester) async {
        final cubit = buildCubit();

        await pumpRing(tester, CounterRing(ringCubit: cubit));
        await tester.pumpWidget(const SizedBox.shrink());

        expect(cubit.isClosed, isFalse);

        await cubit.close();
      });
    });
  });
}
