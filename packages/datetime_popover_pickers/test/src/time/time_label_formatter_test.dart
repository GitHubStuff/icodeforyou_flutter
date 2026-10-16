// packages/datetime_popover_pickers/test/src/time/time_label_formatter_test.dart

import 'package:datetime_popover_pickers/src/time/time_label_formatter.dart'
    show TimeLabelFormatter;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeLabelFormatter', () {
    test('formats time with seconds when showSeconds is true', () {
      const formatter = TimeLabelFormatter(showSeconds: true);

      expect(formatter.showSeconds, isTrue);

      // Morning (AM) test case
      final morning = DateTime(2024, 1, 1, 1, 47, 22);
      expect(formatter.format(morning), '1:47:22 AM');

      // Afternoon/Evening (PM) test case
      final evening = DateTime(2024, 1, 1, 13, 5, 9);
      expect(formatter.format(evening), '1:05:09 PM');
    });

    test('formats time without seconds when showSeconds is false', () {
      const formatter = TimeLabelFormatter(showSeconds: false);

      expect(formatter.showSeconds, isFalse);

      // Morning (AM) test case
      final morning = DateTime(2024, 1, 1, 1, 47, 22);
      expect(formatter.format(morning), '1:47 AM');

      // Noon (12 PM) test case
      final noon = DateTime(2024, 1, 1, 12, 0, 0);
      expect(formatter.format(noon), '12:00 PM');
    });
  });
}
