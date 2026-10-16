// packages/datetime_popover_pickers/test/src/fat_picker/fat_label_formatter_test.dart

import 'package:datetime_popover_pickers/src/fat_picker/fat_label_formatter.dart'
    show FatLabelFormatter;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FatLabelFormatter', () {
    test('formats DateTime with seconds when showSeconds is true', () {
      const formatter = FatLabelFormatter(showSeconds: true);

      // Verify showSeconds property
      expect(formatter.showSeconds, isTrue);

      // AM test case
      final morning = DateTime(2024, 12, 21, 1, 47, 22);
      expect(formatter.format(morning), '21 Dec 2024 1:47:22 AM');

      // PM test case
      final evening = DateTime(2024, 5, 4, 15, 9, 5);
      expect(formatter.format(evening), '4 May 2024 3:09:05 PM');
    });

    test('formats DateTime without seconds when showSeconds is false', () {
      const formatter = FatLabelFormatter(showSeconds: false);

      // Verify showSeconds property
      expect(formatter.showSeconds, isFalse);

      // AM test case
      final morning = DateTime(2024, 1, 9, 8, 5, 45);
      expect(formatter.format(morning), '9 Jan 2024 8:05 AM');

      // PM test case
      final evening = DateTime(2024, 12, 21, 13, 47, 22);
      expect(formatter.format(evening), '21 Dec 2024 1:47 PM');
    });
  });
}
