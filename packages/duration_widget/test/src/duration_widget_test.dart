// packages/duration_widget/test/src/duration_widget_test.dart

import 'package:duration_widget/src/duration_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('DurationWidget', () {
    final eventTime = DateTime(2026, 1, 1, 12);
    final currentTime = DateTime(2026, 1, 1, 13, 4, 7);
    const textStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

    group('constructor', () {
      test('stores the provided values', () {
        final widget = DurationWidget(
          eventTime: eventTime,
          currentTime: currentTime,
          textStyle: textStyle,
          alwaysShowDays: true,
        );

        expect(widget.eventTime, eventTime);
        expect(widget.currentTime, currentTime);
        expect(widget.textStyle, textStyle);
        expect(widget.alwaysShowDays, isTrue);
      });

      test('defaults alwaysShowDays to false', () {
        final widget = DurationWidget(
          eventTime: eventTime,
          currentTime: currentTime,
          textStyle: textStyle,
        );

        expect(widget.alwaysShowDays, isFalse);
      });
    });

    group('build', () {
      testWidgets('renders the adaptive duration by default', (tester) async {
        await tester.pumpWidget(
          _wrap(
            DurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        final text = tester.widget<Text>(find.byType(Text));
        expect(text.data, '01:04:07');
        expect(find.text('01:04:07'), findsOneWidget);
      });

      testWidgets('renders the full form when alwaysShowDays is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            DurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
              alwaysShowDays: true,
            ),
          ),
        );

        final text = tester.widget<Text>(find.byType(Text));
        expect(text.data, '0 01:04:07');
      });

      testWidgets('renders the same text for past and future events', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            DurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );
        final pastText = tester.widget<Text>(find.byType(Text)).data;

        await tester.pumpWidget(
          _wrap(
            DurationWidget(
              eventTime: currentTime,
              currentTime: eventTime,
              textStyle: textStyle,
            ),
          ),
        );
        final futureText = tester.widget<Text>(find.byType(Text)).data;

        expect(pastText, '01:04:07');
        expect(futureText, pastText);
      });

      testWidgets('applies textStyle and layout properties to Text', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            DurationWidget(
              eventTime: eventTime,
              currentTime: currentTime,
              textStyle: textStyle,
            ),
          ),
        );

        final text = tester.widget<Text>(find.byType(Text));
        expect(text.style, textStyle);
        expect(text.maxLines, 2);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.textAlign, TextAlign.center);
      });
    });
  });
}
