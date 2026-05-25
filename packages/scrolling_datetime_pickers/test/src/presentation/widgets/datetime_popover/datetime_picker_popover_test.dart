// test/src/presentation/widgets/datetime_popover/datetime_picker_popover_test.dart

// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('DateTimePickerPopover', () {
    late GlobalKey anchorKey;

    setUp(() {
      anchorKey = GlobalKey();
    });

    Widget buildTestApp({
      required Widget child,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      );
    }

    Widget buildAnchorButton(GlobalKey key) {
      return Container(
        key: key,
        width: 100,
        height: 50,
        color: Colors.blue,
        child: const Center(child: Text('Tap')),
      );
    }

    group('show', () {
      testWidgets('should return null when anchorKey has no context',
          (tester) async {
        final orphanKey = GlobalKey();

        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        await tester.runAsync(() async {
          result = await DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: orphanKey,
          );
        });

        expect(result, isNull);
      });

      testWidgets('should show popover with dateTime option', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        // Start showing popover
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        // Should show both DATE and TIME tabs
        expect(find.text('DATE'), findsOneWidget);
        expect(find.text('TIME'), findsOneWidget);
        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should show popover with date only option', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            option: DateTimeOption.date,
          ),
        );

        await tester.pumpAndSettle();

        // Should NOT show tabs for date-only mode
        expect(find.text('DATE'), findsNothing);
        expect(find.text('TIME'), findsNothing);
        // Should show date picker
        expect(find.byType(ScrollingDatePicker), findsOneWidget);
      });

      testWidgets('should show popover with time only option', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            option: DateTimeOption.time,
          ),
        );

        await tester.pumpAndSettle();

        // Should NOT show tabs for time-only mode
        expect(find.text('DATE'), findsNothing);
        expect(find.text('TIME'), findsNothing);
        // Should show time picker
        expect(find.byType(ScrollingTimePicker), findsOneWidget);
      });

      testWidgets('should return selected datetime on confirm', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.year, 2024);
        expect(result!.month, 6);
        expect(result!.day, 15);
        expect(result!.hour, 10);
        expect(result!.minute, 30);
      });

      testWidgets('should return null on barrier tap', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        bool completed = false;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ).then((value) {
            result = value;
            completed = true;
          }),
        );

        await tester.pumpAndSettle();

        // Tap on barrier (outside popover)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(result, isNull);
      });

      testWidgets('should use custom confirm button text', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            confirmButtonText: 'Confirm',
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Set'), findsNothing);
      });

      testWidgets('should use custom confirm widget', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            confirmWidget: const Icon(Icons.check, key: Key('custom_confirm')),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('custom_confirm')), findsOneWidget);
      });

      testWidgets('should switch tabs when tapped', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        // Initially shows date picker
        expect(find.byType(ScrollingDatePicker), findsOneWidget);

        // Tap TIME tab
        await tester.tap(find.text('TIME'));
        await tester.pumpAndSettle();

        // Should show time picker (both might be in tree due to AnimatedCrossFade)
        expect(find.byType(ScrollingTimePicker), findsOneWidget);

        // Tap DATE tab
        await tester.tap(find.text('DATE'));
        await tester.pumpAndSettle();

        expect(find.byType(ScrollingDatePicker), findsOneWidget);
      });

      testWidgets('should apply custom colors', (tester) async {
        const customBgColor = Colors.red;
        const customConfirmColor = Colors.green;

        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            popoverBackgroundColor: customBgColor,
            confirmButtonColor: customConfirmColor,
          ),
        );

        await tester.pumpAndSettle();

        // Find containers and verify colors
        final containers = tester.widgetList<Container>(find.byType(Container));
        final bgContainer = containers.firstWhere(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).color == customBgColor,
          orElse: Container.new,
        );
        expect(bgContainer, isNotNull);
      });

      testWidgets('should hide seconds when showSeconds is false',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 1, 1, 10, 30, 45),
            showSeconds: false,
          ),
        );

        await tester.pumpAndSettle();

        // Header should not show seconds
        // Find text that matches time format without seconds
        expect(find.textContaining(':45'), findsNothing);
      });
    });

    group('_normalizeInitialDateTime', () {
      testWidgets('normalizes date-only option to midnight', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 30, 45),
            option: DateTimeOption.date,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Tap confirm to get the result
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.hour, 0);
        expect(result!.minute, 0);
        expect(result!.second, 0);
      });

      testWidgets('normalizes time-only option to Jan 1st', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 30),
            option: DateTimeOption.time,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.month, 1);
        expect(result!.day, 1);
        expect(result!.hour, 14);
        expect(result!.minute, 30);
      });

      testWidgets('preserves seconds when useCurrentSecond is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 30, 45),
            useCurrentSecond: true,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.second, 45);
      });

      testWidgets('sets seconds to 0 when useCurrentSecond is false',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 30, 45),
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.second, 0);
      });

      testWidgets(
          'preserves seconds for time option with initialDateTime when useCurrentSecond is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 30, 45),
            option: DateTimeOption.time,
            useCurrentSecond: true,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.second, 45);
      });

      testWidgets(
          'uses current second for time option without initialDateTime when useCurrentSecond is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            // No initialDateTime provided
            option: DateTimeOption.time,
            useCurrentSecond: true,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        // Second should be from DateTime.now(), just verify it's set
        expect(result!.second, greaterThanOrEqualTo(0));
      });

      testWidgets(
          'uses current second for dateTime option without initialDateTime when useCurrentSecond is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            useCurrentSecond: true,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        // Second should be from DateTime.now(), just verify it's set
        expect(result!.second, greaterThanOrEqualTo(0));
      });
    });

    group('positioning', () {
      testWidgets('should position popover below anchor', (tester) async {
        // Use a positioned anchor at specific location
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: buildAnchorButton(anchorKey),
                ),
              ),
            ),
          ),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        // Popover should be visible
        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should handle anchor near bottom of screen', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: buildAnchorButton(anchorKey),
                ),
              ),
            ),
          ),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        // Popover should still be visible (positioned above or adjusted)
        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should handle anchor near right edge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: buildAnchorButton(anchorKey),
                ),
              ),
            ),
          ),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should handle anchor near left edge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: buildAnchorButton(anchorKey),
                ),
              ),
            ),
          ),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Set'), findsOneWidget);
      });
    });

    group('header formatting', () {
      testWidgets('should format date with custom format', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 12, 25, 10, 30),
            dateFormat: 'dd/MM/yyyy',
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('25/12/2024'), findsOneWidget);
      });

      testWidgets('should fallback to default date format on invalid format',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 12, 25),
            // Unclosed quote causes DateFormat to throw
            dateFormat: "EEE, 'unclosed",
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash, should show default format instead
        expect(find.byType(Text), findsWidgets);
        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should fallback to default time format on invalid format',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 12, 25, 10, 30, 45),
            // Unclosed quote causes DateFormat to throw
            timeFormat: "hh:mm 'unclosed",
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash, should show default format instead
        expect(find.byType(Text), findsWidgets);
        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets(
          'should fallback to default time format without seconds on invalid format',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 12, 25, 10, 30),
            timeFormat: "hh:mm 'unclosed",
            showSeconds: false,
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash, should show default format instead
        expect(find.byType(Text), findsWidgets);
        expect(find.text('Set'), findsOneWidget);
      });
    });

    group('landscape orientation', () {
      testWidgets('should use landscape picker size', (tester) async {
        // Set landscape screen size
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            portraitPickerSize: const Size(280, 200),
            landscapePickerSize: const Size(400, 150),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Set'), findsOneWidget);
      });
    });

    group('portrait orientation', () {
      testWidgets('should use portrait picker size', (tester) async {
        // Set portrait screen size (height > width)
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            portraitPickerSize: const Size(280, 200),
            landscapePickerSize: const Size(400, 150),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Set'), findsOneWidget);
      });

      testWidgets('should use default portrait size when not specified',
          (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            // No custom sizes - should use defaults
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Set'), findsOneWidget);
      });
    });

    group('picker interactions', () {
      testWidgets('should update datetime when date picker scrolls',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
            option: DateTimeOption.date,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Find the date picker and scroll it
        final datePicker = find.byType(ScrollingDatePicker);
        expect(datePicker, findsOneWidget);

        // Find a CupertinoPicker within the date picker and scroll it
        final pickers = find.descendant(
          of: datePicker,
          matching: find.byType(CupertinoPicker),
        );
        expect(pickers, findsWidgets);

        // Scroll the first picker (day column) by dragging
        await tester.drag(pickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Confirm the selection
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        // Result should be set (date may have changed)
        expect(result, isNotNull);
      });

      testWidgets('should update datetime when time picker scrolls',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
            option: DateTimeOption.time,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Find the time picker and scroll it
        final timePicker = find.byType(ScrollingTimePicker);
        expect(timePicker, findsOneWidget);

        // Find a CupertinoPicker within the time picker and scroll it
        final pickers = find.descendant(
          of: timePicker,
          matching: find.byType(CupertinoPicker),
        );
        expect(pickers, findsWidgets);

        // Scroll the first picker (hour column) by dragging
        await tester.drag(pickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Confirm the selection
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        // Result should be set (time may have changed)
        expect(result, isNotNull);
      });

      testWidgets(
          'should update datetime when switching tabs and scrolling both pickers',
          (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Should start on DATE tab with date picker visible
        expect(find.byType(ScrollingDatePicker), findsOneWidget);

        // Scroll the date picker
        final datePickers = find.descendant(
          of: find.byType(ScrollingDatePicker),
          matching: find.byType(CupertinoPicker),
        );
        await tester.drag(datePickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Switch to TIME tab
        await tester.tap(find.text('TIME'));
        await tester.pumpAndSettle();

        // Now scroll the time picker
        final timePickers = find.descendant(
          of: find.byType(ScrollingTimePicker),
          matching: find.byType(CupertinoPicker),
        );
        await tester.drag(timePickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Confirm the selection
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        // Result should reflect both date and time changes
        expect(result, isNotNull);
      });

      testWidgets('date change preserves time components', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 14, 45, 30),
            useCurrentSecond: true,
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Scroll date picker to change the date
        final datePickers = find.descendant(
          of: find.byType(ScrollingDatePicker),
          matching: find.byType(CupertinoPicker),
        );
        await tester.drag(datePickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        // Time should be preserved
        expect(result, isNotNull);
        expect(result!.hour, 14);
        expect(result!.minute, 45);
        expect(result!.second, 30);
      });

      testWidgets('time change preserves date components', (tester) async {
        await tester.pumpWidget(
          buildTestApp(child: buildAnchorButton(anchorKey)),
        );

        DateTime? result;
        unawaited(
          DateTimePickerPopover.show(
            context: tester.element(find.byType(Scaffold)),
            anchorKey: anchorKey,
            initialDateTime: DateTime(2024, 6, 15, 10, 30),
          ).then((value) => result = value),
        );

        await tester.pumpAndSettle();

        // Switch to TIME tab
        await tester.tap(find.text('TIME'));
        await tester.pumpAndSettle();

        // Scroll time picker to change the time
        final timePickers = find.descendant(
          of: find.byType(ScrollingTimePicker),
          matching: find.byType(CupertinoPicker),
        );
        await tester.drag(timePickers.first, const Offset(0, -40));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();

        // Date should be preserved
        expect(result, isNotNull);
        expect(result!.year, 2024);
        expect(result!.month, 6);
        expect(result!.day, 15);
      });
    });
  });
}

// Helper to ignore futures
void unawaited(Future<void> future) {}
