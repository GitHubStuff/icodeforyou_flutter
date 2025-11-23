// test/src/presentation/widgets/scrolling_time_picker_effects_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('ScrollingTimePicker Effects', () {
    testWidgets('should apply BoxShadow to dividers with glow', (tester) async {
      final glowConfig = DividerConfiguration.withGlow(
        color: Colors.purple,
        thickness: 3.0,
        transparency: 0.8,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              dividerConfiguration: glowConfig,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the last IgnorePointer which should contain our dividers
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
        color: Colors.orange,
        thickness: 2.5,
        transparency: 0.6,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
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
  });
}
