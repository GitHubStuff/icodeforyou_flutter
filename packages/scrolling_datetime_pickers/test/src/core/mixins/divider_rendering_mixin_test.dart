// test/src/core/mixins/divider_rendering_mixin_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/divider_rendering_mixin.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';

// Test class to use the mixin
class TestDividerRenderer with DividerRenderingMixin {}

void main() {
  group('DividerRenderingMixin', () {
    late TestDividerRenderer renderer;

    setUp(() {
      renderer = TestDividerRenderer();
    });

    testWidgets('buildDivider creates container with config', (tester) async {
      final config = DividerConfiguration(
        color: Colors.red,
        thickness: 2.0,
        indent: 10.0,
        endIndent: 15.0,
        transparency: 0.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: renderer.buildDivider(config),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, EdgeInsets.only(left: 10.0, right: 15.0));

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, config.effectiveColor);
      expect(decoration.boxShadow, isNull); // No effect
    });

    testWidgets('buildDivider with effects adds shadow', (tester) async {
      final config = DividerConfiguration.withGlow();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: renderer.buildDivider(config),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);

      final shadow = decoration.boxShadow!.first;
      expect(shadow.blurRadius, config.blurRadius);
      expect(shadow.spreadRadius, config.spreadRadius);
      expect(shadow.blurStyle, config.blurStyle ?? BlurStyle.normal);
    });

    testWidgets('buildDividerPair creates two dividers', (tester) async {
      final config = DividerConfiguration();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: renderer.buildDividerPair(config: config),
          ),
        ),
      );

      // Find the IgnorePointer created by buildDividerPair (not Scaffold's)
      final dividerPair = find.descendant(
        of: find.byType(Center),
        matching: find.byType(Column),
      );

      expect(dividerPair, findsOneWidget);

      // Find containers within the divider pair
      final containers = find.descendant(
        of: dividerPair,
        matching: find.byType(Container),
      );

      expect(containers, findsNWidgets(2));

      // Should have one spacer SizedBox
      final sizedBoxes = find.descendant(
        of: dividerPair,
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxes, findsAtLeastNWidgets(1));
    });

    testWidgets('buildDividerPair with custom width', (tester) async {
      final config = DividerConfiguration();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: renderer.buildDividerPair(
              config: config,
              width: 200.0,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(Center),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, 200.0);
    });

    testWidgets('buildDividerPair with custom itemExtent', (tester) async {
      final config = DividerConfiguration();
      const customExtent = 60.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: renderer.buildDividerPair(
              config: config,
              itemExtent: customExtent,
            ),
          ),
        ),
      );

      // Find the spacer SizedBox
      final spacer = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(Column),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(spacer.height, customExtent);
    });

    testWidgets('buildPositionedDividers creates positioned stack',
        (tester) async {
      final config = DividerConfiguration();

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              renderer.buildPositionedDividers(
                config: config,
                top: 50.0,
                bottom: 150.0,
                left: 10.0,
                right: 20.0,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(Stack), findsNWidgets(2)); // Parent + created
      expect(find.byType(Positioned), findsNWidgets(2));

      final positions = tester.widgetList<Positioned>(find.byType(Positioned));
      final topPos = positions.first;
      final bottomPos = positions.last;

      expect(topPos.top, 50.0);
      expect(topPos.left, 10.0);
      expect(topPos.right, 20.0);

      expect(bottomPos.top, 150.0);
      expect(bottomPos.left, 10.0);
      expect(bottomPos.right, 20.0);
    });

    test('calculateDividerPositions computes correct positions', () {
      final positions = renderer.calculateDividerPositions(
        viewportHeight: 200.0,
        itemExtent: 40.0,
      );

      expect(positions.topDivider, 80.0); // 100 - 20
      expect(positions.bottomDivider, 120.0); // 100 + 20
      expect(positions.spacing, 40.0);
    });

    test('calculateDividerPositions with custom itemExtent', () {
      final positions = renderer.calculateDividerPositions(
        viewportHeight: 300.0,
        itemExtent: 60.0,
      );

      expect(positions.topDivider, 120.0); // 150 - 30
      expect(positions.bottomDivider, 180.0); // 150 + 30
      expect(positions.spacing, 60.0);
    });

    testWidgets('buildAnimatedDividers creates animated container',
        (tester) async {
      final config = DividerConfiguration();

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              renderer.buildAnimatedDividers(
                config: config,
                viewportHeight: 200.0,
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.bounceIn,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);

      final animated = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(animated.duration, const Duration(milliseconds: 300));
      expect(animated.curve, Curves.bounceIn);
    });

    test('DividerPositions spacing calculation', () {
      const positions = DividerPositions(
        topDivider: 50.0,
        bottomDivider: 90.0,
      );

      expect(positions.spacing, 40.0);
    });
  });
}
