// main_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook_workspace/main.dart';

void main() {
  group('WidgetbookApp Tests', () {
    test('should create WidgetbookApp instance', () {
      final app = WidgetbookApp();
      expect(app, isA<WidgetbookApp>());
    });

    test('should have key parameter', () {
      const testKey = Key('test-key');
      final app = WidgetbookApp(key: testKey);
      expect(app.key, equals(testKey));
    });

    testWidgets('should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(WidgetbookApp());
      expect(find.byType(WidgetbookApp), findsOneWidget);
    });
  });
}
