// main_test.dart
import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook_workspace/main.dart';

void main() {
  group('WidgetbookApp Tests', () {
    test('should create WidgetbookApp instance', () {
      const app = WidgetbookApp();
      expect(app, isA<WidgetbookApp>());
    });

    test('should have super.key parameter', () {
      const app = WidgetbookApp(key: Key('test-key'));
      expect(app.key, equals(const Key('test-key')));
    });
  });
}
