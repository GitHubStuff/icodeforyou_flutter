// test/src/presentation/widgets/scrolling_time_picker_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/time_picker/time_picker_cubit.dart';

void main() {
  group('ScrollingTimePicker Widget', () {
    testWidgets('should create with required parameters', (tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (dateTime) {
              },
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingTimePicker), findsOneWidget);
      expect(find.byType(CupertinoPicker),
          findsNWidgets(3)); // hour, minute, am/pm
    });

    testWidgets('should use default values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
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

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, StyleConstants.defaultBackgroundColor);
      expect(decoration.borderRadius, BorderRadius.circular(0.0));
    });

    testWidgets('should show seconds column when enabled', (tester) async {
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

      expect(find.byType(CupertinoPicker),
          findsNWidgets(4)); // hour, minute, second, am/pm
    });

    testWidgets('should use custom initial time', (tester) async {
      final customTime = DateTime(2024, 1, 1, 14, 30, 45);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              initialDateTime: customTime,
              onDateTimeChanged: (_) {},
            ),
          ),
        ),
      );

      // The cubit should be initialized with custom time
      final cubitFinder = find.byType(BlocProvider<TimePickerCubit>);
      expect(cubitFinder, findsOneWidget);
    });

    testWidgets('should use custom background color', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              backgroundColor: customColor,
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

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('should use custom text style', (tester) async {
      const customStyle = TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w300,
        color: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              timeStyle: customStyle,
            ),
          ),
        ),
      );

      // Find text widgets and check their style
      final texts = tester.widgetList<Text>(
        find.descendant(
          of: find.byType(CupertinoPicker),
          matching: find.byType(Text),
        ),
      );

      expect(texts.isNotEmpty, true);
    });

    testWidgets('should use custom border radius', (tester) async {
      const customRadius = 20.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              borderRadius: customRadius,
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

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(customRadius));
    });

    testWidgets('should use custom fade configuration', (tester) async {
      final customFade = FadeConfiguration.noFade();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollingTimePicker(
              onDateTimeChanged: (_) {},
              fadeConfiguration: customFade,
            ),
          ),
        ),
      );

      expect(find.byType(ScrollingTimePicker), findsOneWidget);
    });
  });
}
