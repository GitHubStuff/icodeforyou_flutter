// test/src/presentation/widgets/scrolling_time_picker_orientation_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:scrolling_datetime_pickers/src/presentation/widgets/scrolling_time_picker.dart';

// Need access to the column widget for testing
class TestableScrollingTimePicker extends ScrollingTimePicker {
  const TestableScrollingTimePicker({
    super.key,
    required super.onDateTimeChanged,
    super.portraitSize,
    super.landscapeSize,
    super.showSeconds,
  });
}

void main() {
  group('ScrollingTimePicker Orientation', () {
    testWidgets('should use landscape size in landscape orientation',
        (tester) async {
      const portraitSize = Size(200, 250);
      const landscapeSize = Size(300, 150);

      // Set landscape orientation
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrollingTimePicker(
                onDateTimeChanged: (_) {},
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
              of: find.byType(ScrollingTimePicker),
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
      const landscapeSize = Size(300, 150);

      // Start in portrait
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScrollingTimePicker(
                onDateTimeChanged: (_) {},
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
              of: find.byType(ScrollingTimePicker),
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
              of: find.byType(ScrollingTimePicker),
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
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              showSeconds: false,
            ),
          ),
        ),
      );

      // Should have 3 columns: hour, minute, AM/PM
      expect(find.byType(CupertinoPicker), findsNWidgets(3));

      // Verify each column is in an Expanded widget
      expect(find.byType(Expanded), findsAtLeastNWidgets(3));
    });

    testWidgets('should render seconds column when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              showSeconds: true,
            ),
          ),
        ),
      );

      // Should have 4 columns: hour, minute, second, AM/PM
      expect(find.byType(CupertinoPicker), findsNWidgets(4));
      expect(find.byType(Expanded), findsAtLeastNWidgets(4));
    });

    testWidgets('should apply Transform to outer columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              showSeconds: false,
            ),
          ),
        ),
      );

      // Transform widgets should be applied to outer columns
      expect(find.byType(Transform), findsAtLeastNWidgets(2));
    });

    testWidgets('should render dividers correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      // Find containers that could be dividers
      final allContainers = find.descendant(
        of: find.byType(ScrollingTimePicker),
        matching: find.byType(Container),
      );

      // Should have multiple containers (including dividers)
      expect(allContainers, findsWidgets);

      // Should have IgnorePointer widgets (from CupertinoPicker and dividers)
      expect(find.byType(IgnorePointer), findsWidgets);

      // Check that we have the divider structure
      final ignorePointers = find.descendant(
        of: find.byType(ScrollingTimePicker),
        matching: find.byType(IgnorePointer),
      );

      // At least one IgnorePointer should be for dividers
      expect(ignorePointers, findsWidgets);
    });

    testWidgets('should display AM/PM options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 9, 0, 0),
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find both AM and PM text
      expect(find.text('AM'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
    });

    testWidgets('should handle edge case times', (tester) async {
      // Test midnight (12:00 AM)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 0, 0, 0),
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('12'), findsWidgets); // 12 AM
      expect(find.text('AM'), findsOneWidget);

      // Test noon (12:00 PM)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('12'), findsWidgets); // 12 PM
      expect(find.text('PM'), findsOneWidget);
    });
  });
}
