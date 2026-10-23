// packages/datetime_pickers/test/src/fat_picker/fat_picker_test.dart

import 'package:datetime_pickers/datetime_pickers.dart'
    show DatePicker, FatPicker, PickerSize, TimePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildPicker({
  required void Function(DateTime) onDateTimeChanged,
  PickerSize size = PickerSize.small,
  bool showSeconds = true,
  DateTime? initialDateTime,
  int? minimumYear,
  int? maximumYear,
  TextStyle? textStyle,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: FatPicker(
          onDateTimeChanged: onDateTimeChanged,
          size: size,
          showSeconds: showSeconds,
          initialDateTime: initialDateTime,
          minimumYear: minimumYear,
          maximumYear: maximumYear,
          textStyle: textStyle,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FatPicker widget', () {
    testWidgets(
      'renders DatePicker and TimePicker with default initialDateTime and year bounds',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          _buildPicker(
            onDateTimeChanged: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final datePickerFinder = find.byType(DatePicker);
        final timePickerFinder = find.byType(TimePicker);

        expect(datePickerFinder, findsOneWidget);
        expect(timePickerFinder, findsOneWidget);

        final datePickerWidget = tester.widget<DatePicker>(datePickerFinder);
        expect(datePickerWidget.minimumYear, DatePicker.defaultMinimumYear);
        expect(datePickerWidget.maximumYear, DatePicker.defaultMaximumYear);
      },
    );

    testWidgets(
      'passes explicit minimumYear, maximumYear, size, and textStyle',
      (
        tester,
      ) async {
        const customStyle = TextStyle(color: CupertinoColors.activeBlue);
        final initial = DateTime(2025, 4, 12, 10, 15, 30);

        await tester.pumpWidget(
          _buildPicker(
            initialDateTime: initial,
            size: PickerSize.large,
            showSeconds: true,
            minimumYear: 2020,
            maximumYear: 2030,
            textStyle: customStyle,
            onDateTimeChanged: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final datePickerWidget = tester.widget<DatePicker>(
          find.byType(DatePicker),
        );
        final timePickerWidget = tester.widget<TimePicker>(
          find.byType(TimePicker),
        );

        expect(datePickerWidget.minimumYear, 2020);
        expect(datePickerWidget.maximumYear, 2030);
        expect(datePickerWidget.size, PickerSize.large);
        expect(datePickerWidget.textStyle, customStyle);

        expect(timePickerWidget.size, PickerSize.large);
        expect(timePickerWidget.textStyle, customStyle);
        expect(timePickerWidget.showSeconds, isTrue);
      },
    );

    testWidgets('normalizes initial second to 0 when showSeconds is false', (
      tester,
    ) async {
      final initial = DateTime(2024, 6, 15, 14, 30, 45);

      await tester.pumpWidget(
        _buildPicker(
          initialDateTime: initial,
          showSeconds: false,
          onDateTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final timePickerWidget = tester.widget<TimePicker>(
        find.byType(TimePicker),
      );
      expect(timePickerWidget.initialTime?.second, 0);
      expect(timePickerWidget.initialTime?.minute, 30);
      expect(timePickerWidget.initialTime?.hour, 14);
    });

    testWidgets('merges date changes with the current time part', (
      tester,
    ) async {
      DateTime? emittedDateTime;
      final initial = DateTime(2024, 3, 10, 8, 45, 20);

      await tester.pumpWidget(
        _buildPicker(
          initialDateTime: initial,
          showSeconds: true,
          onDateTimeChanged: (dt) => emittedDateTime = dt,
        ),
      );
      await tester.pumpAndSettle();

      final datePickerWidget = tester.widget<DatePicker>(
        find.byType(DatePicker),
      );
      // Simulate DatePicker triggering onDateChanged
      datePickerWidget.onDateChanged(DateTime(2024, 11, 25, 0, 0, 0));
      await tester.pumpAndSettle();

      expect(emittedDateTime, isNotNull);
      expect(emittedDateTime!.year, 2024);
      expect(emittedDateTime!.month, 11);
      expect(emittedDateTime!.day, 25);
      expect(emittedDateTime!.hour, 8);
      expect(emittedDateTime!.minute, 45);
      expect(emittedDateTime!.second, 20);
    });

    testWidgets('merges time changes with the current date part', (
      tester,
    ) async {
      DateTime? emittedDateTime;
      final initial = DateTime(2024, 3, 10, 8, 45, 20);

      await tester.pumpWidget(
        _buildPicker(
          initialDateTime: initial,
          showSeconds: true,
          onDateTimeChanged: (dt) => emittedDateTime = dt,
        ),
      );
      await tester.pumpAndSettle();

      final timePickerWidget = tester.widget<TimePicker>(
        find.byType(TimePicker),
      );
      // Simulate TimePicker triggering onTimeChanged
      timePickerWidget.onTimeChanged(DateTime(2000, 1, 1, 16, 20, 15));
      await tester.pumpAndSettle();

      expect(emittedDateTime, isNotNull);
      expect(emittedDateTime!.year, 2024);
      expect(emittedDateTime!.month, 3);
      expect(emittedDateTime!.day, 10);
      expect(emittedDateTime!.hour, 16);
      expect(emittedDateTime!.minute, 20);
      expect(emittedDateTime!.second, 15);
    });
  });
}
