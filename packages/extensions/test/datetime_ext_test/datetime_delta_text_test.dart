// delta_datetime_text_test.dart

import 'package:extensions/extensions.dart' show DateTimeDeltaText;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:extensions/datetime_ext/datetime_delta.dart';

void main() {
  group('DateTimeDeltaText Widget Tests', () {
    // Test DateTimeDelta objects
    late DateTimeDelta positiveDelta;
    late DateTimeDelta negativeDelta;
    late DateTimeDelta zeroDelta;

    setUpAll(() {
      // Create test DateTimeDelta objects
      positiveDelta = DateTimeDelta(
        years: 2,
        months: 3,
        days: 15,
        hours: 4,
        minutes: 30,
        seconds: 45,
        isFuture: true,
      );

      negativeDelta = DateTimeDelta(
        days: 5,
        hours: 2,
        minutes: 15,
        isFuture: false,
      );

      zeroDelta = DateTimeDelta(isFuture: true);
    });

    group('Basic Functionality', () {
      testWidgets('renders with minimal required parameters', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DateTimeDeltaText(delta: positiveDelta)),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(find.byType(Row), findsNothing);
      });

      testWidgets('displays formatted delta string', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DateTimeDeltaText(delta: positiveDelta)),
          ),
        );

        final textFinder = find.byType(Text);
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.data, isNotNull);
        expect(textWidget.data, isNotEmpty);
      });

      testWidgets('handles zero delta', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DateTimeDeltaText(delta: zeroDelta)),
          ),
        );

        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('handles negative delta', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DateTimeDeltaText(delta: negativeDelta)),
          ),
        );

        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Format Parameter', () {
      testWidgets('uses custom format when provided', (tester) async {
        const customFormat = r'${D} days only';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                format: customFormat,
              ),
            ),
          ),
        );

        expect(find.byType(Text), findsOneWidget);
        // The widget should use the custom format
      });

      testWidgets('uses default format when format is null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, format: null),
            ),
          ),
        );

        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('handles empty format string', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, format: ''),
            ),
          ),
        );

        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Leading Widget', () {
      testWidgets('renders with leading widget only', (tester) async {
        const leadingIcon = Icon(Icons.schedule);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                leading: leadingIcon,
              ),
            ),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        // Verify Row structure
        final rowWidget = tester.widget<Row>(find.byType(Row));
        expect(rowWidget.mainAxisSize, MainAxisSize.min);
        expect(rowWidget.children.length, 2);
      });

      testWidgets('renders without Row when leading is null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, leading: null),
            ),
          ),
        );

        expect(find.byType(Row), findsNothing);
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Trailing Widget', () {
      testWidgets('renders with trailing widget only', (tester) async {
        const trailingIcon = Icon(Icons.arrow_forward);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                trailing: trailingIcon,
              ),
            ),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        // Verify Row structure
        final rowWidget = tester.widget<Row>(find.byType(Row));
        expect(rowWidget.mainAxisSize, MainAxisSize.min);
        expect(rowWidget.children.length, 2);
      });

      testWidgets('renders without Row when trailing is null', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, trailing: null),
            ),
          ),
        );

        expect(find.byType(Row), findsNothing);
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Leading and Trailing Widgets', () {
      testWidgets('renders with both leading and trailing widgets', (
        tester,
      ) async {
        const leadingIcon = Icon(Icons.schedule);
        const trailingIcon = Icon(Icons.check_circle);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                leading: leadingIcon,
                trailing: trailingIcon,
              ),
            ),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        // Verify Row structure
        final rowWidget = tester.widget<Row>(find.byType(Row));
        expect(rowWidget.mainAxisSize, MainAxisSize.min);
        expect(rowWidget.children.length, 3);
      });

      testWidgets('renders complex leading and trailing widgets', (
        tester,
      ) async {
        final leadingWidget = Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(width: 20, height: 20, color: Colors.red),
        );

        final trailingWidget = Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(width: 15, height: 15, color: Colors.blue),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                leading: leadingWidget,
                trailing: trailingWidget,
              ),
            ),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Container), findsNWidgets(2));
        expect(find.byType(Padding), findsNWidgets(2));
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Text Widget Parameters', () {
      testWidgets('applies custom TextStyle', (tester) async {
        const customStyle = TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, style: customStyle),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.style, customStyle);
      });

      testWidgets('applies TextAlign parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.textAlign, TextAlign.center);
      });

      testWidgets('applies TextOverflow parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.overflow, TextOverflow.ellipsis);
      });

      testWidgets('applies maxLines parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, maxLines: 2),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.maxLines, 2);
      });

      testWidgets('applies softWrap parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, softWrap: false),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.softWrap, false);
      });

      testWidgets('applies textDirection parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.textDirection, TextDirection.rtl);
      });

      testWidgets('applies locale parameter', (tester) async {
        const locale = Locale('en', 'US');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(delta: positiveDelta, locale: locale),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.locale, locale);
      });

      testWidgets('applies semanticsLabel parameter', (tester) async {
        const semanticsLabel = 'Time remaining';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                semanticsLabel: semanticsLabel,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.semanticsLabel, semanticsLabel);
      });

      testWidgets('applies textWidthBasis parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.textWidthBasis, TextWidthBasis.longestLine);
      });

      testWidgets('applies selectionColor parameter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                selectionColor: Colors.yellow,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.selectionColor, Colors.yellow);
      });

      testWidgets('applies textScaler parameter', (tester) async {
        const textScaler = TextScaler.linear(2.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                textScaler: textScaler,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.textScaler, textScaler);
      });
    });

    group('Complex Scenarios', () {
      testWidgets('renders with all parameters set', (tester) async {
        const leadingIcon = Icon(Icons.schedule);
        const trailingIcon = Icon(Icons.done);
        const customStyle = TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue,
        );
        const customFormat = r'${D}d $*{hh>}:${mm}';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: positiveDelta,
                format: customFormat,
                leading: leadingIcon,
                trailing: trailingIcon,
                style: customStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                semanticsLabel: 'Duration display',
              ),
            ),
          ),
        );

        // Verify structure
        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        expect(find.byIcon(Icons.done), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        // Verify Text widget parameters
        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.style, customStyle);
        expect(textWidget.textAlign, TextAlign.center);
        expect(textWidget.overflow, TextOverflow.fade);
        expect(textWidget.maxLines, 1);
        expect(textWidget.softWrap, false);
        expect(textWidget.semanticsLabel, 'Duration display');

        // Verify Row structure
        final rowWidget = tester.widget<Row>(find.byType(Row));
        expect(rowWidget.children.length, 3);
        expect(rowWidget.mainAxisSize, MainAxisSize.min);
      });

      testWidgets('handles edge case with empty string format and zero delta', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DateTimeDeltaText(
                delta: zeroDelta,
                format: '',
                leading: Container(width: 10, height: 10, color: Colors.red),
                trailing: Container(width: 10, height: 10, color: Colors.blue),
              ),
            ),
          ),
        );

        expect(find.byType(DateTimeDeltaText), findsOneWidget);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(find.byType(Container), findsNWidgets(2));
      });
    });
  });
}
