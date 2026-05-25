// test/src/presentation/widgets/scrolling_time_picker_column_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';

void main() {
  group('_ScrollingTimePickerColumn', () {
    testWidgets(
      'renders CupertinoPicker columns',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 216,
                child: ScrollingTimePicker(
                  onDateTimeChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoPicker), findsWidgets);
      },
    );

    testWidgets(
      'applies custom timeStyle to picker text',
      (tester) async {
        const style = TextStyle(color: Colors.red, fontSize: 24);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 216,
                child: ScrollingTimePicker(
                  onDateTimeChanged: (_) {},
                  timeStyle: style,
                ),
              ),
            ),
          ),
        );

        final texts = tester.widgetList<Text>(find.byType(Text));
        expect(
          texts.any(
            (t) => t.style?.color == Colors.red && t.style?.fontSize == 24,
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'uses default text style when timeStyle is null',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 216,
                child: ScrollingTimePicker(
                  onDateTimeChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Text), findsWidgets);
      },
    );
  });
}
