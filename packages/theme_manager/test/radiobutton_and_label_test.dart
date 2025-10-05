// radiobutton_and_label_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_manager/theme_manager.dart';

enum TestEnum { first, second, third }

void main() {
  group('RadiobuttonAndLabel', () {
    group('Constructor', () {
      testWidgets('creates widget with required parameters', (tester) async {
        const testValue = 'test';
        const testLabel = Text('Test Label');
        void testCallback(String? value) {}

        final widget = RadiobuttonAndLabel<String>(
          value: testValue,
          label: testLabel,
          onChanged: testCallback,
        );

        expect(widget.value, equals(testValue));
        expect(widget.label, equals(testLabel));
        expect(widget.onChanged, equals(testCallback));
        expect(widget.key, isNull);
      });

      testWidgets('creates widget with custom key', (tester) async {
        const testKey = Key('test-key');

        final widget = RadiobuttonAndLabel<String>(
          key: testKey,
          value: 'test',
          label: const Text('Test'),
          onChanged: (_) {},
        );

        expect(widget.key, equals(testKey));
      });
    });

    group('Widget Rendering', () {
      testWidgets('renders ListTile with correct properties', (tester) async {
        const testValue = 'test-value';
        const testLabel = Text('Test Label');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: testValue,
                label: testLabel,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final listTileFinder = find.byType(ListTile);
        expect(listTileFinder, findsOneWidget);

        final listTile = tester.widget<ListTile>(listTileFinder);
        expect(listTile.title, equals(testLabel));
        expect(listTile.visualDensity, equals(VisualDensity.compact));
        expect(listTile.dense, isTrue);
        expect(listTile.onTap, isNotNull);
      });

      testWidgets('renders Radio widget with correct value', (tester) async {
        const testValue = 42;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<int>(
                value: testValue,
                label: const Text('Test'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final radioFinder = find.byType(Radio<int>);
        expect(radioFinder, findsOneWidget);

        final radio = tester.widget<Radio<int>>(radioFinder);
        expect(radio.value, equals(testValue));
      });

      testWidgets('displays correct label text', (tester) async {
        const labelText = 'Custom Label Text';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'test',
                label: const Text(labelText),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.text(labelText), findsOneWidget);
      });
    });

    group('onTap Behavior', () {
      testWidgets('calls onChanged when ListTile is tapped', (tester) async {
        const testValue = 'tap-test';
        String? capturedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: testValue,
                label: const Text('Tap Test'),
                onChanged: (value) {
                  capturedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        await tester.pump();

        expect(capturedValue, equals(testValue));
      });

      testWidgets('passes correct value to onChanged callback', (tester) async {
        const expectedValue = 999;
        int? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<int>(
                value: expectedValue,
                label: const Text('Number Test'),
                onChanged: (value) {
                  receivedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));

        expect(receivedValue, equals(expectedValue));
      });

      testWidgets('onChanged can receive null value parameter', (tester) async {
        bool callbackInvoked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'test',
                label: const Text('Null Test'),
                onChanged: (String? value) {
                  callbackInvoked = true;
                  expect(value, equals('test')); // Will be 'test', not null
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));

        expect(callbackInvoked, isTrue);
      });
    });

    group('Generic Type Support', () {
      testWidgets('works with String type', (tester) async {
        const stringValue = 'string-test';
        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: stringValue,
                label: const Text('String Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(stringValue));
      });

      testWidgets('works with int type', (tester) async {
        const intValue = 12345;
        int? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<int>(
                value: intValue,
                label: const Text('Int Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(intValue));
      });

      testWidgets('works with enum type', (tester) async {
        const enumValue = TestEnum.second;
        TestEnum? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<TestEnum>(
                value: enumValue,
                label: const Text('Enum Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(enumValue));
      });

      testWidgets('works with custom object type', (tester) async {
        final customObject = DateTime(2025, 1, 1);
        DateTime? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<DateTime>(
                value: customObject,
                label: const Text('DateTime Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(customObject));
      });
    });

    group('Widget Properties', () {
      testWidgets('ListTile has compact visual density', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'test',
                label: const Text('Test'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.visualDensity, equals(VisualDensity.compact));
      });

      testWidgets('ListTile is dense', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'test',
                label: const Text('Test'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.dense, isTrue);
      });

      testWidgets('Radio is in leading position', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'test',
                label: const Text('Test'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.leading, isA<Radio<String>>());
      });
    });

    group('Complex Label Widgets', () {
      testWidgets('works with complex label widget', (tester) async {
        final complexLabel = Row(
          children: const [
            Icon(Icons.star),
            SizedBox(width: 8),
            Text('Complex Label'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'complex',
                label: complexLabel,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('Complex Label'), findsOneWidget);
      });

      testWidgets('works with rich text label', (tester) async {
        const richLabel = Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Bold',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'italic',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: 'rich',
                label: richLabel,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.title, equals(richLabel));
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty string value', (tester) async {
        const emptyValue = '';
        String? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: emptyValue,
                label: const Text('Empty Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(emptyValue));
      });

      testWidgets('handles zero value', (tester) async {
        const zeroValue = 0;
        int? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<int>(
                value: zeroValue,
                label: const Text('Zero Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(zeroValue));
      });

      testWidgets('handles negative values', (tester) async {
        const negativeValue = -42;
        int? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<int>(
                value: negativeValue,
                label: const Text('Negative Test'),
                onChanged: (value) => result = value,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(result, equals(negativeValue));
      });
    });

    group('Integration Tests', () {
      testWidgets('multiple radio buttons work independently', (tester) async {
        String? result1;
        String? result2;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  RadiobuttonAndLabel<String>(
                    value: 'option1',
                    label: const Text('Option 1'),
                    onChanged: (value) => result1 = value,
                  ),
                  RadiobuttonAndLabel<String>(
                    value: 'option2',
                    label: const Text('Option 2'),
                    onChanged: (value) => result2 = value,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.text('Option 1'));
        expect(result1, equals('option1'));
        expect(result2, isNull);

        await tester.tap(find.text('Option 2'));
        expect(result1, equals('option1'));
        expect(result2, equals('option2'));
      });

      testWidgets('maintains state across rebuilds', (tester) async {
        String? lastValue;

        Widget buildWidget(String value) {
          return MaterialApp(
            home: Scaffold(
              body: RadiobuttonAndLabel<String>(
                value: value,
                label: Text('Value: $value'),
                onChanged: (v) => lastValue = v,
              ),
            ),
          );
        }

        await tester.pumpWidget(buildWidget('initial'));
        await tester.tap(find.byType(ListTile));
        expect(lastValue, equals('initial'));

        await tester.pumpWidget(buildWidget('updated'));
        await tester.tap(find.byType(ListTile));
        expect(lastValue, equals('updated'));
      });
    });
  });
}
