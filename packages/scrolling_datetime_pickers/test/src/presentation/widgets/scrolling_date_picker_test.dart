// test/src/presentation/widgets/scrolling_date_picker_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/date_picker/date_picker_cubit.dart';

void main() {
  group('ScrollingDatePicker Widget', () {
    testWidgets('should create with required parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScrollingDatePicker(onDateChanged: (date) {})),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
      expect(
        find.byType(CupertinoPicker),
        findsNWidgets(3),
      ); // day, month, year
    });

    testWidgets('should use default values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScrollingDatePicker(onDateChanged: (_) {})),
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

      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, StyleConstants.defaultBackgroundColor);
      expect(decoration.borderRadius, BorderRadius.circular(0));
    });

    testWidgets('should use custom initial date', (tester) async {
      final customDate = DateTime(2020, 6, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              initialDate: customDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      final cubitFinder = find.byType(BlocProvider<DatePickerCubit>);
      expect(cubitFinder, findsOneWidget);
    });

    testWidgets('should use custom background color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              backgroundColor: customColor,
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

      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('should use custom text style', (tester) async {
      const customStyle = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dateStyle: customStyle,
            ),
          ),
        ),
      );

      final texts = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(CupertinoPicker),
          matching: find.byType(Text),
        ),
      );

      expect(texts.isNotEmpty, isTrue);
    });

    testWidgets('should use custom border radius', (tester) async {
      const customRadius = 16.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              borderRadius: customRadius,
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

      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(customRadius));
    });

    testWidgets('should use custom fade configuration', (tester) async {
      final customFade = FadeConfiguration.noFade();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              fadeConfiguration: customFade,
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
    });

    testWidgets('should use custom divider configuration', (tester) async {
      final customDivider = DividerConfiguration.withGlow(color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dividerConfiguration: customDivider,
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
    });

    testWidgets('should use custom portrait size', (tester) async {
      const customSize = Size(400, 300);

      // Set portrait screen size (height > width)
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              portraitSize: customSize,
            ),
          ),
        ),
      );

      final pickerSize = tester.getSize(find.byType(ScrollingDatePicker));

      expect(pickerSize.width, customSize.width);
      expect(pickerSize.height, customSize.height);
    });

    testWidgets('should respect dayAscending false (year-month-day)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
              dayAscending: false,
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('should respect dayAscending true (day-month-year)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingDatePicker(
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingDatePicker), findsOneWidget);
      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('should create BlocProvider with DatePickerCubit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ScrollingDatePicker(onDateChanged: (_) {})),
        ),
      );

      expect(find.byType(BlocProvider<DatePickerCubit>), findsOneWidget);
    });
  });
}
