// packages/datetime_popover_pickers/test/src/date/date_picker_test.dart

import 'package:datetime_popover_pickers/src/date/date_picker.dart';
import 'package:datetime_popover_pickers/src/picker_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildPicker({
  required void Function(DateTime) onDateChanged,
  PickerSize size = PickerSize.regular,
  DateTime? initialDate,
  int minimumYear = DatePicker.defaultMinimumYear,
  int maximumYear = DatePicker.defaultMaximumYear,
  TextStyle? textStyle,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: DatePicker(
          onDateChanged: onDateChanged,
          size: size,
          initialDate: initialDate,
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

  group('DatePicker constructor assertion', () {
    test('throws AssertionError if minimumYear > maximumYear', () {
      expect(
        () => DatePicker(
          minimumYear: 2025,
          maximumYear: 2024,
          onDateChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('DatePicker widgets & interaction', () {
    testWidgets('renders properly with default initialDate (DateTime.now())', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildPicker(
          onDateChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DatePicker), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNWidgets(3));
      expect(
        find.byType(CupertinoPickerDefaultSelectionOverlay),
        findsOneWidget,
      );
    });

    testWidgets('renders with custom initialDate, size, and textStyle', (
      tester,
    ) async {
      final initial = DateTime(2023, 5, 15, 10, 30, 45);
      await tester.pumpWidget(
        _buildPicker(
          initialDate: initial,
          size: PickerSize.large,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          onDateChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15'), findsWidgets);
      expect(find.text('May'), findsWidgets);
      expect(find.text('2023'), findsWidgets);
    });

    testWidgets(
      'changing day wheel triggers onDateChanged and preserves time',
      (
        tester,
      ) async {
        DateTime? changedDate;
        final initial = DateTime(2024, 3, 10, 14, 25, 30);

        await tester.pumpWidget(
          _buildPicker(
            initialDate: initial,
            onDateChanged: (d) => changedDate = d,
          ),
        );
        await tester.pumpAndSettle();

        final dayPicker = find.byType(CupertinoPicker).at(0);
        final dayController = tester
            .widget<CupertinoPicker>(dayPicker)
            .scrollController!;

        // Scroll day wheel to index 19 (Day 20)
        dayController.jumpToItem(19);
        await tester.pumpAndSettle();

        expect(changedDate, isNotNull);
        expect(changedDate!.day, 20);
        expect(changedDate!.month, 3);
        expect(changedDate!.year, 2024);
        expect(changedDate!.hour, 14);
        expect(changedDate!.minute, 25);
        expect(changedDate!.second, 30);
      },
    );

    testWidgets('changing month wheel triggers onDateChanged', (tester) async {
      DateTime? changedDate;
      final initial = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        _buildPicker(
          initialDate: initial,
          onDateChanged: (d) => changedDate = d,
        ),
      );
      await tester.pumpAndSettle();

      final monthPicker = find.byType(CupertinoPicker).at(1);
      final monthController = tester
          .widget<CupertinoPicker>(monthPicker)
          .scrollController!;

      // Scroll month wheel to index 6 (July)
      monthController.jumpToItem(6);
      await tester.pumpAndSettle();

      expect(changedDate, isNotNull);
      expect(changedDate!.month, 7);
      expect(changedDate!.day, 15);
    });

    testWidgets('changing year wheel triggers onDateChanged', (tester) async {
      DateTime? changedDate;
      final initial = DateTime(2020, 6, 15);

      await tester.pumpWidget(
        _buildPicker(
          initialDate: initial,
          minimumYear: 2000,
          maximumYear: 2030,
          onDateChanged: (d) => changedDate = d,
        ),
      );
      await tester.pumpAndSettle();

      final yearPicker = find.byType(CupertinoPicker).at(2);
      final yearController = tester
          .widget<CupertinoPicker>(yearPicker)
          .scrollController!;

      // Index 25 corresponds to 2000 + 25 = 2025
      yearController.jumpToItem(25);
      await tester.pumpAndSettle();

      expect(changedDate, isNotNull);
      expect(changedDate!.year, 2025);
      expect(changedDate!.month, 6);
      expect(changedDate!.day, 15);
    });

    testWidgets(
      'changing to a month with fewer days snaps day wheel via post-frame callback',
      (tester) async {
        DateTime? changedDate;
        // Start on March 31
        final initial = DateTime(2024, 3, 31);

        await tester.pumpWidget(
          _buildPicker(
            initialDate: initial,
            onDateChanged: (d) => changedDate = d,
          ),
        );
        await tester.pumpAndSettle();

        final monthPicker = find.byType(CupertinoPicker).at(1);
        final monthController = tester
            .widget<CupertinoPicker>(monthPicker)
            .scrollController!;

        // Switch to February (index 1) in leap year 2024 (29 days)
        monthController.jumpToItem(1);
        await tester.pump();
        // Allow snap animation duration (200ms) to complete
        await tester.pumpAndSettle();

        expect(changedDate, isNotNull);
        expect(changedDate!.month, 2);
        expect(changedDate!.day, 29);

        final dayPicker = find.byType(CupertinoPicker).at(0);
        final dayController =
            tester.widget<CupertinoPicker>(dayPicker).scrollController!
                as FixedExtentScrollController;
        expect(dayController.selectedItem, 28); // 29 - 1
      },
    );

    testWidgets(
      'changing leap year to non-leap year snaps day wheel from 29 to 28',
      (tester) async {
        DateTime? changedDate;
        // Start on Feb 29, 2024 (leap year)
        final initial = DateTime(2024, 2, 29);

        await tester.pumpWidget(
          _buildPicker(
            initialDate: initial,
            minimumYear: 2020,
            maximumYear: 2030,
            onDateChanged: (d) => changedDate = d,
          ),
        );
        await tester.pumpAndSettle();

        final yearPicker = find.byType(CupertinoPicker).at(2);
        final yearController =
            tester.widget<CupertinoPicker>(yearPicker).scrollController!
                as FixedExtentScrollController;

        // Switch to 2023 (index 3), which has only 28 days in Feb
        yearController.jumpToItem(3);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(changedDate, isNotNull);
        expect(changedDate!.year, 2023);
        expect(changedDate!.month, 2);
        expect(changedDate!.day, 28);
      },
    );

    testWidgets(
      'unmounting picker before snap animation frame handles !mounted check',
      (tester) async {
        final initial = DateTime(2024, 3, 31);

        await tester.pumpWidget(
          _buildPicker(
            initialDate: initial,
            onDateChanged: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        final monthPicker = find.byType(CupertinoPicker).at(1);
        final monthController =
            tester.widget<CupertinoPicker>(monthPicker).scrollController!
                as FixedExtentScrollController;

        // Triggers _snapDayIfInvalid which schedules post frame callback
        monthController.jumpToItem(1);

        // Immediately unmount before the scheduled post-frame callback fires
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'invalid day index renders with CupertinoColors.inactiveGray style',
      (
        tester,
      ) async {
        // In February (28 or 29 days), day 31 (index 30) is invalid
        final initial = DateTime(2023, 2, 1);

        await tester.pumpWidget(
          _buildPicker(
            initialDate: initial,
            onDateChanged: (_) {},
          ),
        );
        await tester.pumpAndSettle();

        // Find Text widget for day 31
        final day31TextFinder = find.text('31');
        expect(day31TextFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(day31TextFinder);
        expect(textWidget.style?.color, CupertinoColors.inactiveGray);
      },
    );

    testWidgets('clamps initial year within minimumYear and maximumYear', (
      tester,
    ) async {
      // initialDate year is 2050, but maximumYear is 2030
      final initial = DateTime(2050, 1, 1);

      await tester.pumpWidget(
        _buildPicker(
          initialDate: initial,
          minimumYear: 2000,
          maximumYear: 2030,
          onDateChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final yearPicker = find.byType(CupertinoPicker).at(2);
      final yearController =
          tester.widget<CupertinoPicker>(yearPicker).scrollController!
              as FixedExtentScrollController;

      // Clamped to 2030 -> index 30 (2030 - 2000)
      expect(yearController.selectedItem, 30);
    });
  });

  group('DateLabelFormatter', () {
    test('formats DateTime as d MMM yyyy correctly', () {
      const formatter = DateLabelFormatter();
      final date = DateTime(2024, 12, 21);

      expect(formatter.format(date), '21 Dec 2024');
    });
  });
}
