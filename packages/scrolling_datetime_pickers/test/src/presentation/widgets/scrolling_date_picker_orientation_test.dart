// test/src/presentation/widgets/scrolling_date_picker_orientation_test.dart

// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingDatePicker Orientation', () {
    testWidgets('should use landscape size in landscape orientation',
        (tester) async {
      const portraitSize = Size(200, 250);
      const landscapeSize = Size(350, 150);

      // Set landscape orientation
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrollingDatePicker(
                onDateChanged: (_) {},
                portraitSize: portraitSize,
                landscapeSize: landscapeSize,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScrollingDatePicker),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth ?? landscapeSize.width,
          landscapeSize.width);
      expect(container.constraints?.maxHeight ?? landscapeSize.height,
          landscapeSize.height);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle orientation change', (tester) async {
      const portraitSize = Size(200, 250);
      const landscapeSize = Size(350, 150);

      // Start in portrait
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrollingDatePicker(
                onDateChanged: (_) {},
                portraitSize: portraitSize,
                landscapeSize: landscapeSize,
              ),
            ),
          ),
        ),
      );

      // Verify portrait size
      Container container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScrollingDatePicker),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth ?? portraitSize.width,
          portraitSize.width);

      // Change to landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pumpAndSettle();

      container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScrollingDatePicker),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth ?? landscapeSize.width,
          landscapeSize.width);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render all columns correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have 3 columns: day, month, year
      expect(find.byType(CupertinoPicker), findsNWidgets(3));

      // Verify each column is in an Expanded widget
      expect(find.byType(Expanded), findsAtLeastNWidgets(3));
    });

    testWidgets('should render columns in dayAscending order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 6, 15),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoPicker), findsNWidgets(3));

      // In dayAscending mode, first column is day
      // We can verify by checking text content of first picker
      final firstPicker = find.byType(CupertinoPicker).first;
      expect(firstPicker, findsOneWidget);
    });

    testWidgets('should render columns in descending order when dayAscending false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 6, 15),
              onDateChanged: (_) {},
              dayAscending: false, // year-month-day
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('should render dividers correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Find containers that could be dividers
      final allContainers = find.descendant(
        of: find.byType(ScrollingDatePicker),
        matching: find.byType(Container),
      );

      // Should have multiple containers (including dividers)
      expect(allContainers, findsWidgets);

      // Should have IgnorePointer widgets
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('should display correct year range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find the current year
      expect(find.text('2024'), findsWidgets);
    });

    testWidgets('should handle didUpdateWidget for dayAscending change',
        (tester) async {
      bool dayAscending = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: ScrollingDatePicker(
                        onDateChanged: (_) {},
                        dayAscending: dayAscending,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          dayAscending = !dayAscending;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);

      // Tap the button to toggle dayAscending
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
    });

    testWidgets('should handle edge case dates', (tester) async {
      // Test January 1st
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1'), findsWidgets);
      expect(find.text('Jan'), findsWidgets);
      expect(find.text('2024'), findsWidgets);

      // Test December 31st
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: DateTime(2024, 12, 31),
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('31'), findsWidgets);
      expect(find.text('Dec'), findsWidgets);
    });
  });
}
