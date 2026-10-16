// packages/duration_widget/test/src/event_reporting_test.dart

import 'package:duration_widget/src/event_reporting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventReporting', () {
    final currentTime = DateTime(2026, 1, 1, 12);
    const offset = Duration(hours: 1, minutes: 5, seconds: 9);
    final pastEvent = currentTime.subtract(offset);
    final futureEvent = currentTime.add(offset);

    group('constructor', () {
      test('stores eventTime and currentTime', () {
        final reporting = EventReporting(
          eventTime: pastEvent,
          currentTime: currentTime,
        );

        expect(reporting.eventTime, pastEvent);
        expect(reporting.currentTime, currentTime);
      });
    });

    group('durationString', () {
      test('formats the elapsed duration for a past event', () {
        final reporting = EventReporting(
          eventTime: pastEvent,
          currentTime: currentTime,
        );

        expect(reporting.durationString(alwaysShowDays: false), '01:05:09');
      });

      test('formats the remaining duration for a future event', () {
        final reporting = EventReporting(
          eventTime: futureEvent,
          currentTime: currentTime,
        );

        expect(reporting.durationString(alwaysShowDays: false), '01:05:09');
      });

      test('uses the absolute difference regardless of direction', () {
        final past = EventReporting(
          eventTime: pastEvent,
          currentTime: currentTime,
        );
        final future = EventReporting(
          eventTime: futureEvent,
          currentTime: currentTime,
        );

        expect(past.durationString(alwaysShowDays: true), '0 01:05:09');
        expect(
          future.durationString(alwaysShowDays: true),
          past.durationString(alwaysShowDays: true),
        );
      });

      test('formats a zero duration when times are identical', () {
        final reporting = EventReporting(
          eventTime: currentTime,
          currentTime: currentTime,
        );

        expect(reporting.durationString(alwaysShowDays: false), '0');
        expect(reporting.durationString(alwaysShowDays: true), '0 00:00:00');
      });

      test('forwards alwaysShowDays to the formatter', () {
        final reporting = EventReporting(
          eventTime: pastEvent,
          currentTime: currentTime,
        );

        expect(reporting.durationString(alwaysShowDays: true), '0 01:05:09');
        expect(reporting.durationString(alwaysShowDays: false), '01:05:09');
      });
    });

    group('eventDirection', () {
      test('returns "Since" when the event is in the past', () {
        final reporting = EventReporting(
          eventTime: pastEvent,
          currentTime: currentTime,
        );

        expect(reporting.eventDirection(), 'Since');
      });

      test('returns "Until" when the event is in the future', () {
        final reporting = EventReporting(
          eventTime: futureEvent,
          currentTime: currentTime,
        );

        expect(reporting.eventDirection(), 'Until');
      });

      test('returns an empty string when the event is now', () {
        final reporting = EventReporting(
          eventTime: currentTime,
          currentTime: currentTime,
        );

        expect(reporting.eventDirection(), isEmpty);
      });
    });
  });
}
