// packages/duration_widget/test/src/ticking_duration_widget_test.dart

import 'package:duration_widget/src/duration_widget.dart';
import 'package:duration_widget/src/ticking_clock_cubit.dart';
import 'package:duration_widget/src/ticking_duration_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('TickingDurationWidget', () {
    final eventTime = DateTime(2026, 1, 1, 12);
    final currentTime = DateTime(2026, 1, 1, 13, 4, 7);
    const textStyle = TextStyle(fontSize: 24);
    const oneSecond = Duration(seconds: 1);

    group('constructor', () {
      test('stores the provided values', () {
        const interval = Duration(milliseconds: 500);
        final widget = TickingDurationWidget(
          eventTime: eventTime,
          currentTime: currentTime,
          textStyle: textStyle,
          alwaysShowDays: true,
          interval: interval,
        );

        expect(widget.eventTime, eventTime);
        expect(widget.currentTime, currentTime);
        expect(widget.textStyle, textStyle);
        expect(widget.alwaysShowDays, isTrue);
        expect(widget.interval, interval);
      });

      test('defaults alwaysShowDays to false and interval to one second', () {
        final widget = TickingDurationWidget(
          eventTime: eventTime,
          currentTime: currentTime,
          textStyle: textStyle,
        );

        expect(widget.alwaysShowDays, isFalse);
        expect(widget.interval, oneSecond);
      });
    });

    group('build', () {
      testWidgets('provides a TickingClockCubit seeded with currentTime', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        expect(find.byType(BlocProvider<TickingClockCubit>), findsOneWidget);
        expect(
          find.byType(BlocBuilder<TickingClockCubit, DateTime>),
          findsOneWidget,
        );

        final cubit = tester
            .element(find.byType(DurationWidget))
            .read<TickingClockCubit>();
        expect(cubit.state, currentTime);
        expect(cubit.interval, oneSecond);
      });

      testWidgets('passes a custom interval to the cubit', (tester) async {
        const interval = Duration(milliseconds: 250);

        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
              interval: interval,
            ),
          ),
        );

        final cubit = tester
            .element(find.byType(DurationWidget))
            .read<TickingClockCubit>();
        expect(cubit.interval, interval);
      });

      testWidgets('renders a DurationWidget with forwarded arguments', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
              alwaysShowDays: true,
            ),
          ),
        );

        final child = tester.widget<DurationWidget>(
          find.byType(DurationWidget),
        );
        expect(child.eventTime, eventTime);
        expect(child.currentTime, currentTime);
        expect(child.textStyle, textStyle);
        expect(child.alwaysShowDays, isTrue);
        expect(find.text('0 01:04:07'), findsOneWidget);
      });

      testWidgets('forwards the default alwaysShowDays to DurationWidget', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        final child = tester.widget<DurationWidget>(
          find.byType(DurationWidget),
        );
        expect(child.alwaysShowDays, isFalse);
        expect(find.text('01:04:07'), findsOneWidget);
      });

      testWidgets('rebuilds DurationWidget with the ticked time', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        DurationWidget child() =>
            tester.widget<DurationWidget>(find.byType(DurationWidget));

        expect(child().currentTime, currentTime);

        await tester.pump(oneSecond);
        expect(child().currentTime, currentTime.add(oneSecond));
        expect(child().eventTime, eventTime);

        await tester.pump(oneSecond);
        expect(child().currentTime, currentTime.add(oneSecond * 2));
        expect(find.text('01:04:09'), findsOneWidget);
      });

      testWidgets('ticks at the custom interval', (tester) async {
        const interval = Duration(milliseconds: 250);

        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
              interval: interval,
            ),
          ),
        );

        DurationWidget child() =>
            tester.widget<DurationWidget>(find.byType(DurationWidget));

        await tester.pump(interval);
        expect(child().currentTime, currentTime.add(interval));

        await tester.pump(interval);
        expect(child().currentTime, currentTime.add(interval * 2));
      });

      testWidgets('closes the cubit when removed from the tree', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            TickingDurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        final cubit = tester
            .element(find.byType(DurationWidget))
            .read<TickingClockCubit>();
        expect(cubit.isClosed, isFalse);

        await tester.pumpWidget(_wrap(const SizedBox.shrink()));

        expect(cubit.isClosed, isTrue);
        expect(find.byType(DurationWidget), findsNothing);

        // A still-running timer would emit on a closed cubit and throw.
        await tester.pump(oneSecond * 5);
        expect(cubit.state, currentTime);
      });
    });
  });
}
