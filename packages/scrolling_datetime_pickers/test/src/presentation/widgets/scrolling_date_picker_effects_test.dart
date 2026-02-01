// test/src/presentation/widgets/scrolling_date_picker_effects_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingDatePicker Effects', () {
    testWidgets('should apply BoxShadow to dividers with glow', (tester) async {
      final glowConfig = DividerConfiguration.withGlow(
        color: Colors.blue,
        thickness: 2.5,
        transparency: 0.9,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: glowConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the IgnorePointer widgets
      final ignorePointers = find.byType(IgnorePointer);
      expect(ignorePointers, findsWidgets);

      // Look for containers with BoxDecoration
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      int shadowCount = 0;
      for (final container in containers) {
        if (container.decoration != null &&
            container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.boxShadow != null) {
            shadowCount++;
            expect(decoration.boxShadow!.isNotEmpty, true);
            final shadow = decoration.boxShadow!.first;
            expect(shadow.color, glowConfig.effectiveColor);
            expect(shadow.blurRadius, glowConfig.blurRadius);
            expect(shadow.spreadRadius, glowConfig.spreadRadius);
            expect(shadow.blurStyle, BlurStyle.outer);
          }
        }
      }

      // Should have found at least 2 dividers with shadows
      expect(shadowCount, greaterThanOrEqualTo(2));
    });

    testWidgets('should apply BoxShadow to dividers with blur', (tester) async {
      final blurConfig = DividerConfiguration.withBlur(
        color: Colors.green,
        thickness: 2.0,
        transparency: 0.7,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: blurConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for containers with BoxDecoration
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      int shadowCount = 0;
      for (final container in containers) {
        if (container.decoration != null &&
            container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty) {
            shadowCount++;
            final shadow = decoration.boxShadow!.first;
            expect(shadow.blurRadius, blurConfig.blurRadius);
            expect(shadow.blurStyle, BlurStyle.normal);
          }
        }
      }

      // Should have found dividers with blur effect
      expect(shadowCount, greaterThan(0));
    });

    testWidgets('should not apply BoxShadow with default config',
        (tester) async {
      const defaultConfig = DividerConfiguration();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: defaultConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for containers with BoxDecoration
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      int shadowCount = 0;
      for (final container in containers) {
        if (container.decoration != null &&
            container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty) {
            shadowCount++;
          }
        }
      }

      // Default config should have no shadows (hasEffect is false)
      expect(shadowCount, 0);
    });

    testWidgets('should apply divider indents', (tester) async {
      const indentConfig = DividerConfiguration(
        indent: 20.0,
        endIndent: 30.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: indentConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for containers with margin
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      bool foundIndentedContainer = false;
      for (final container in containers) {
        if (container.margin is EdgeInsets) {
          final margin = container.margin as EdgeInsets;
          if (margin.left == indentConfig.indent &&
              margin.right == indentConfig.endIndent) {
            foundIndentedContainer = true;
            break;
          }
        }
      }

      expect(foundIndentedContainer, isTrue);
    });

    testWidgets('should apply divider thickness', (tester) async {
      const thickConfig = DividerConfiguration(
        thickness: 3.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: thickConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for containers with the specified height
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      bool foundThickDivider = false;
      for (final container in containers) {
        if (container.constraints?.maxHeight == thickConfig.thickness) {
          foundThickDivider = true;
          break;
        }
      }

      expect(foundThickDivider, isTrue);
    });
  });
}
