// test/src/core/mixins/picker_transform_mixin_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/picker_transform_mixin.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';

// Test class to use the mixin
class TestTransform with PickerTransformMixin {}

void main() {
  group('PickerTransformMixin', () {
    late TestTransform testTransform;

    setUp(() {
      testTransform = TestTransform();
    });

    group('calculateColumnTransform', () {
      test('should apply transforms correctly', () {
        // First column - should apply left tilt
        final matrix1 = testTransform.calculateColumnTransform(
          0,
          3,
          DimensionConstants.perspectiveValue,
        );
        expect(matrix1.entry(3, 2),
            closeTo(DimensionConstants.perspectiveValue, 0.001));
        expect(matrix1, isNot(equals(Matrix4.identity())));

        // Middle column - no transform
        final matrix2 = testTransform.calculateColumnTransform(
          1,
          3,
          DimensionConstants.perspectiveValue,
        );
        expect(matrix2, equals(Matrix4.identity()));

        // Last column - should apply right tilt
        final matrix3 = testTransform.calculateColumnTransform(
          2,
          3,
          DimensionConstants.perspectiveValue,
        );
        expect(matrix3.entry(3, 2),
            closeTo(DimensionConstants.perspectiveValue, 0.001));
        expect(matrix3, isNot(equals(Matrix4.identity())));

        // Two columns - both transformed
        final left = testTransform.calculateColumnTransform(0, 2, 0.005);
        final right = testTransform.calculateColumnTransform(1, 2, 0.005);
        expect(left, isNot(equals(Matrix4.identity())));
        expect(right, isNot(equals(Matrix4.identity())));

        // Four columns - first and last transformed
        final first = testTransform.calculateColumnTransform(0, 4, 0.01);
        final middle1 = testTransform.calculateColumnTransform(1, 4, 0.01);
        final middle2 = testTransform.calculateColumnTransform(2, 4, 0.01);
        final last = testTransform.calculateColumnTransform(3, 4, 0.01);

        expect(first, isNot(equals(Matrix4.identity())));
        expect(middle1, equals(Matrix4.identity()));
        expect(middle2, equals(Matrix4.identity()));
        expect(last, isNot(equals(Matrix4.identity())));
      });
    });

    group('calculateColumnTransformWithAngle', () {
      test('should use custom angles and perspectives', () {
        // Test first column with custom values
        final matrix1 = testTransform.calculateColumnTransformWithAngle(
          0,
          3,
          0.2,
          0.005,
        );
        expect(matrix1.entry(3, 2), closeTo(0.005, 0.001));
        expect(matrix1, isNot(equals(Matrix4.identity())));

        // Test middle column - should still be identity
        final matrix2 = testTransform.calculateColumnTransformWithAngle(
          1,
          3,
          0.5,
          0.01,
        );
        expect(matrix2, equals(Matrix4.identity()));

        // Test last column with custom values
        final matrix3 = testTransform.calculateColumnTransformWithAngle(
          2,
          3,
          0.3,
          0.006,
        );
        expect(matrix3.entry(3, 2), closeTo(0.006, 0.001));
        expect(matrix3, isNot(equals(Matrix4.identity())));

        // Test with different column counts
        final matrix4 = testTransform.calculateColumnTransformWithAngle(
          0,
          2,
          0.15,
          0.004,
        );
        expect(matrix4.entry(3, 2), closeTo(0.004, 0.001));

        final matrix5 = testTransform.calculateColumnTransformWithAngle(
          3,
          4,
          0.25,
          0.008,
        );
        expect(matrix5.entry(3, 2), closeTo(0.008, 0.001));
      });
    });

    group('shouldApplyTransform', () {
      test('should identify outer columns correctly', () {
        // First columns
        expect(testTransform.shouldApplyTransform(0, 2), true);
        expect(testTransform.shouldApplyTransform(0, 3), true);
        expect(testTransform.shouldApplyTransform(0, 4), true);
        expect(testTransform.shouldApplyTransform(0, 5), true);

        // Last columns
        expect(testTransform.shouldApplyTransform(1, 2), true);
        expect(testTransform.shouldApplyTransform(2, 3), true);
        expect(testTransform.shouldApplyTransform(3, 4), true);
        expect(testTransform.shouldApplyTransform(4, 5), true);

        // Middle columns
        expect(testTransform.shouldApplyTransform(1, 3), false);
        expect(testTransform.shouldApplyTransform(1, 4), false);
        expect(testTransform.shouldApplyTransform(2, 4), false);
        expect(testTransform.shouldApplyTransform(2, 5), false);
        expect(testTransform.shouldApplyTransform(3, 5), false);
      });
    });

    group('getColumnRotationAngle', () {
      test('should return correct angles', () {
        // First column - negative angle
        expect(
          testTransform.getColumnRotationAngle(0, 2),
          -DimensionConstants.outerColumnAngle,
        );
        expect(
          testTransform.getColumnRotationAngle(0, 3),
          -DimensionConstants.outerColumnAngle,
        );
        expect(
          testTransform.getColumnRotationAngle(0, 4),
          -DimensionConstants.outerColumnAngle,
        );

        // Last column - positive angle
        expect(
          testTransform.getColumnRotationAngle(1, 2),
          DimensionConstants.outerColumnAngle,
        );
        expect(
          testTransform.getColumnRotationAngle(2, 3),
          DimensionConstants.outerColumnAngle,
        );
        expect(
          testTransform.getColumnRotationAngle(3, 4),
          DimensionConstants.outerColumnAngle,
        );

        // Middle columns - zero
        expect(testTransform.getColumnRotationAngle(1, 3), 0.0);
        expect(testTransform.getColumnRotationAngle(1, 4), 0.0);
        expect(testTransform.getColumnRotationAngle(2, 4), 0.0);
        expect(testTransform.getColumnRotationAngle(2, 5), 0.0);
        expect(testTransform.getColumnRotationAngle(3, 5), 0.0);
      });
    });

    group('buildTransformedColumn', () {
      testWidgets('should transform outer columns', (tester) async {
        final child = Container(key: const Key('test'));

        // Test first column
        final transformed1 = testTransform.buildTransformedColumn(
          child: child,
          columnIndex: 0,
          totalColumns: 3,
        );

        await tester.pumpWidget(MaterialApp(home: transformed1));
        expect(find.byType(Transform), findsOneWidget);

        // Test last column with custom values
        final transformed2 = testTransform.buildTransformedColumn(
          child: child,
          columnIndex: 2,
          totalColumns: 3,
          customAngle: 0.5,
          customPerspective: 0.01,
        );

        await tester.pumpWidget(MaterialApp(home: transformed2));
        expect(find.byType(Transform), findsOneWidget);

        final transform = tester.widget<Transform>(find.byType(Transform));
        expect(transform.alignment, Alignment.center);
      });

      testWidgets('should not transform middle column', (tester) async {
        final child = Container(key: const Key('test'));

        final notTransformed = testTransform.buildTransformedColumn(
          child: child,
          columnIndex: 1,
          totalColumns: 3,
        );

        await tester.pumpWidget(MaterialApp(home: notTransformed));
        expect(find.byType(Transform), findsNothing);
        expect(find.byKey(const Key('test')), findsOneWidget);
      });
    });
  });
}
