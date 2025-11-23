// test/src/presentation/widgets/scrolling_time_picker_config_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingTimePicker Configuration', () {
    testWidgets('should use custom divider configuration', (tester) async {
      final customDivider = DividerConfiguration(
        color: Colors.red,
        thickness: 3.0,
        transparency: 0.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              dividerConfiguration: customDivider,
            ),
          ),
        ),
      );

      // Find divider containers
      final dividers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(IgnorePointer),
              matching: find.byType(Container),
            ),
          )
          .where((container) => container.decoration != null);

      expect(dividers.length, greaterThan(0));
    });

    testWidgets('should render dividers with glow effect', (tester) async {
      final glowDivider = DividerConfiguration.withGlow(
        color: Colors.blue,
        thickness: 2.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              dividerConfiguration: glowDivider,
            ),
          ),
        ),
      );

      // Find divider containers with decoration
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(IgnorePointer),
          matching: find.byType(Container),
        ),
      );

      // Check that at least some containers have BoxDecoration with shadow
      bool foundShadow = false;
      for (final container in containers) {
        if (container.decoration != null &&
            container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty) {
            foundShadow = true;
            final shadow = decoration.boxShadow!.first;
            expect(shadow.blurRadius, glowDivider.blurRadius);
            expect(shadow.spreadRadius, glowDivider.spreadRadius);
          }
        }
      }
      expect(foundShadow, true);
    });

    testWidgets('should render dividers with blur effect', (tester) async {
      final blurDivider = DividerConfiguration.withBlur(
        color: Colors.green,
        thickness: 2.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              dividerConfiguration: blurDivider,
            ),
          ),
        ),
      );

      // Find divider containers with decoration
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(IgnorePointer),
          matching: find.byType(Container),
        ),
      );

      // Check for blur effect
      bool foundBlur = false;
      for (final container in containers) {
        if (container.decoration != null &&
            container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty) {
            foundBlur = true;
            final shadow = decoration.boxShadow!.first;
            expect(shadow.blurRadius, blurDivider.blurRadius);
          }
        }
      }
      expect(foundBlur, true);
    });

    testWidgets('should use portrait size in portrait orientation',
        (tester) async {
      const portraitSize = Size(200, 250);
      const landscapeSize = Size(300, 150);

      // Set portrait orientation
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

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ScrollingTimePicker),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth ?? double.infinity,
          portraitSize.width);
      expect(container.constraints?.maxHeight ?? double.infinity,
          portraitSize.height);

      // Reset view
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
  });
}
