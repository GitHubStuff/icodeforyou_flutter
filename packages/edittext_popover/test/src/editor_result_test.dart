// test/src/editor_result_test.dart
import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorCompleted', () {
    test('stores text correctly', () {
      const result = EditorCompleted(text: 'hello');

      expect(result.text, equals('hello'));
    });

    test('equality works for same text', () {
      const a = EditorCompleted(text: 'hello');
      const b = EditorCompleted(text: 'hello');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality fails for different text', () {
      const a = EditorCompleted(text: 'hello');
      const b = EditorCompleted(text: 'world');

      expect(a, isNot(equals(b)));
    });

    test('toString returns expected format', () {
      const result = EditorCompleted(text: 'test');

      expect(result.toString(), equals('EditorCompleted(text: test)'));
    });

    test('is not equal to EditorDismissed with same text', () {
      const completed = EditorCompleted(text: 'hello');
      const dismissed = EditorDismissed(text: 'hello');

      expect(completed, isNot(equals(dismissed)));
    });
  });

  group('EditorDismissed', () {
    test('stores text correctly', () {
      const result = EditorDismissed(text: 'hello');

      expect(result.text, equals('hello'));
    });

    test('equality works for same text', () {
      const a = EditorDismissed(text: 'hello');
      const b = EditorDismissed(text: 'hello');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality fails for different text', () {
      const a = EditorDismissed(text: 'hello');
      const b = EditorDismissed(text: 'world');

      expect(a, isNot(equals(b)));
    });

    test('toString returns expected format', () {
      const result = EditorDismissed(text: 'test');

      expect(result.toString(), equals('EditorDismissed(text: test)'));
    });
  });

  group('EditorResult pattern matching', () {
    test('can pattern match EditorCompleted', () {
      const EditorResult result = EditorCompleted(text: 'hello');

      final text = switch (result) {
        EditorCompleted(:final text) => 'completed: $text',
        EditorDismissed(:final text) => 'dismissed: $text',
      };

      expect(text, equals('completed: hello'));
    });

    test('can pattern match EditorDismissed', () {
      const EditorResult result = EditorDismissed(text: 'hello');

      final text = switch (result) {
        EditorCompleted(:final text) => 'completed: $text',
        EditorDismissed(:final text) => 'dismissed: $text',
      };

      expect(text, equals('dismissed: hello'));
    });
  });
}
