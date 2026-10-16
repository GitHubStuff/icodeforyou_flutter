// packages/datetime_popover_pickers/test/src/time/time_picker_test.dart

import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
    show PickerSize, TimePicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildPicker({
  required void Function(DateTime) onTimeChanged,
  PickerSize size = PickerSize.regular,
  bool showSeconds = true,
  DateTime? initialTime,
  TextStyle? textStyle,
}) {
  return CupertinoApp(
    home: CupertinoPageScaffold(
      child: Center(
        child: TimePicker(
          onTimeChanged: onTimeChanged,
          size: size,
          showSeconds: showSeconds,
          initialTime: initialTime,
          textStyle: textStyle,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimePicker widget', () {
    testWidgets('renders 4 wheels when showSeconds is true', (tester) async {
      await tester.pumpWidget(
        _buildPicker(
          showSeconds: true,
          onTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TimePicker), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNWidgets(4));
      expect(
        find.byType(CupertinoPickerDefaultSelectionOverlay),
        findsOneWidget,
      );
    });

    testWidgets('renders 3 wheels when showSeconds is false', (tester) async {
      await tester.pumpWidget(
        _buildPicker(
          showSeconds: false,
          onTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('initializes correctly with midnight (00:00:00 AM)', (
      tester,
    ) async {
      final initial = DateTime(2024, 1, 1, 0, 0, 0);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final hourPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(0),
      );
      final periodPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(3),
      );

      final hourController =
          hourPicker.scrollController! as FixedExtentScrollController;
      final periodController =
          periodPicker.scrollController! as FixedExtentScrollController;

      // 00:00 is 12 AM -> index 11 (hour 12) and index 0 (AM)
      expect(hourController.selectedItem, 11);
      expect(periodController.selectedItem, 0);
    });

    testWidgets('initializes correctly with noon (12:00:00 PM)', (
      tester,
    ) async {
      final initial = DateTime(2024, 1, 1, 12, 0, 0);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final hourPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(0),
      );
      final periodPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(3),
      );

      final hourController =
          hourPicker.scrollController! as FixedExtentScrollController;
      final periodController =
          periodPicker.scrollController! as FixedExtentScrollController;

      // 12:00 PM -> index 11 (hour 12) and index 1 (PM)
      expect(hourController.selectedItem, 11);
      expect(periodController.selectedItem, 1);
    });

    testWidgets(
      'defaults second to 0 when showSeconds is false even if initial has seconds',
      (
        tester,
      ) async {
        DateTime? emittedTime;
        final initial = DateTime(2024, 1, 1, 15, 30, 45);

        await tester.pumpWidget(
          _buildPicker(
            initialTime: initial,
            showSeconds: false,
            onTimeChanged: (t) => emittedTime = t,
          ),
        );
        await tester.pumpAndSettle();

        // Trigger change on minute wheel (index 1)
        final minutePicker = tester.widget<CupertinoPicker>(
          find.byType(CupertinoPicker).at(1),
        );
        final minuteController =
            minutePicker.scrollController! as FixedExtentScrollController;
        minuteController.jumpToItem(31);
        await tester.pumpAndSettle();

        expect(emittedTime, isNotNull);
        expect(emittedTime!.hour, 15);
        expect(emittedTime!.minute, 31);
        expect(emittedTime!.second, 0);
      },
    );

    testWidgets('changing hour wheel triggers onTimeChanged', (tester) async {
      DateTime? emittedTime;
      final initial = DateTime(2024, 5, 10, 8, 20, 15);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (t) => emittedTime = t,
        ),
      );
      await tester.pumpAndSettle();

      final hourPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(0),
      );
      final hourController =
          hourPicker.scrollController! as FixedExtentScrollController;

      // Change hour to 11 (index 10)
      hourController.jumpToItem(10);
      await tester.pumpAndSettle();

      expect(emittedTime, isNotNull);
      expect(emittedTime!.hour, 11);
      expect(emittedTime!.minute, 20);
      expect(emittedTime!.second, 15);
      expect(emittedTime!.year, 2024);
      expect(emittedTime!.month, 5);
      expect(emittedTime!.day, 10);
    });

    testWidgets('changing minute wheel triggers onTimeChanged', (tester) async {
      DateTime? emittedTime;
      final initial = DateTime(2024, 5, 10, 8, 20, 15);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (t) => emittedTime = t,
        ),
      );
      await tester.pumpAndSettle();

      final minutePicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(1),
      );
      final minuteController =
          minutePicker.scrollController! as FixedExtentScrollController;

      // Change minute to 45 (index 45)
      minuteController.jumpToItem(45);
      await tester.pumpAndSettle();

      expect(emittedTime, isNotNull);
      expect(emittedTime!.hour, 8);
      expect(emittedTime!.minute, 45);
      expect(emittedTime!.second, 15);
    });

    testWidgets('changing second wheel triggers onTimeChanged', (tester) async {
      DateTime? emittedTime;
      final initial = DateTime(2024, 5, 10, 8, 20, 15);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (t) => emittedTime = t,
        ),
      );
      await tester.pumpAndSettle();

      final secondPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(2),
      );
      final secondController =
          secondPicker.scrollController! as FixedExtentScrollController;

      // Change second to 59 (index 59)
      secondController.jumpToItem(59);
      await tester.pumpAndSettle();

      expect(emittedTime, isNotNull);
      expect(emittedTime!.hour, 8);
      expect(emittedTime!.minute, 20);
      expect(emittedTime!.second, 59);
    });

    testWidgets(
      'changing period wheel from AM to PM converts hour accurately',
      (
        tester,
      ) async {
        DateTime? emittedTime;
        // 9:15 AM
        final initial = DateTime(2024, 5, 10, 9, 15, 0);

        await tester.pumpWidget(
          _buildPicker(
            initialTime: initial,
            showSeconds: true,
            onTimeChanged: (t) => emittedTime = t,
          ),
        );
        await tester.pumpAndSettle();

        final periodPicker = tester.widget<CupertinoPicker>(
          find.byType(CupertinoPicker).at(3),
        );
        final periodController =
            periodPicker.scrollController! as FixedExtentScrollController;

        // Switch to PM (index 1)
        periodController.jumpToItem(1);
        await tester.pumpAndSettle();

        expect(emittedTime, isNotNull);
        expect(emittedTime!.hour, 21); // 9 PM -> 21:00
        expect(emittedTime!.minute, 15);
      },
    );

    testWidgets('changing period wheel from PM to AM converts 12 PM to 00 AM', (
      tester,
    ) async {
      DateTime? emittedTime;
      // 12:30 PM (hour 12)
      final initial = DateTime(2024, 5, 10, 12, 30, 0);

      await tester.pumpWidget(
        _buildPicker(
          initialTime: initial,
          showSeconds: true,
          onTimeChanged: (t) => emittedTime = t,
        ),
      );
      await tester.pumpAndSettle();

      final periodPicker = tester.widget<CupertinoPicker>(
        find.byType(CupertinoPicker).at(3),
      );
      final periodController =
          periodPicker.scrollController! as FixedExtentScrollController;

      // Switch to AM (index 0)
      periodController.jumpToItem(0);
      await tester.pumpAndSettle();

      expect(emittedTime, isNotNull);
      expect(emittedTime!.hour, 0); // 12 AM -> 00:00
      expect(emittedTime!.minute, 30);
    });

    testWidgets('applies custom textStyle and size overrides', (tester) async {
      const customStyle = TextStyle(
        fontStyle: FontStyle.italic,
        color: CupertinoColors.systemRed,
      );

      await tester.pumpWidget(
        _buildPicker(
          size: PickerSize.large,
          textStyle: customStyle,
          onTimeChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AM'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
    });
  });
}
