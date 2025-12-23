// test/src/editor_state_test.dart
import 'package:edittext_popover/src/_editor_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorState', () {
    test('constructor stores values correctly', () {
      const state = EditorState(
        text: 'hello',
        lineCount: 1,
        characterCount: 5,
      );

      expect(state.text, equals('hello'));
      expect(state.lineCount, equals(1));
      expect(state.characterCount, equals(5));
    });

    group('initial factory', () {
      test('empty string returns 0 lines and 0 characters', () {
        final state = EditorState.initial('');

        expect(state.text, equals(''));
        expect(state.lineCount, equals(0));
        expect(state.characterCount, equals(0));
      });

      test('single character returns 1 line', () {
        final state = EditorState.initial('a');

        expect(state.text, equals('a'));
        expect(state.lineCount, equals(1));
        expect(state.characterCount, equals(1));
      });

      test('single line returns 1 line', () {
        final state = EditorState.initial('hello');

        expect(state.lineCount, equals(1));
        expect(state.characterCount, equals(5));
      });

      test('text with one newline returns 2 lines', () {
        final state = EditorState.initial('hello\nworld');

        expect(state.lineCount, equals(2));
        expect(state.characterCount, equals(11));
      });

      test('text with multiple newlines counts correctly', () {
        final state = EditorState.initial('a\nb\nc\nd');

        expect(state.lineCount, equals(4));
        expect(state.characterCount, equals(7));
      });

      test('trailing newline adds a line', () {
        final state = EditorState.initial('hello\n');

        expect(state.lineCount, equals(2));
        expect(state.characterCount, equals(6));
      });

      test('only newline returns 2 lines', () {
        final state = EditorState.initial('\n');

        expect(state.lineCount, equals(2));
        expect(state.characterCount, equals(1));
      });
    });

    group('copyWith', () {
      test('copies all values when none provided', () {
        const original = EditorState(
          text: 'hello',
          lineCount: 1,
          characterCount: 5,
        );

        final copy = original.copyWith();

        expect(copy.text, equals('hello'));
        expect(copy.lineCount, equals(1));
        expect(copy.characterCount, equals(5));
      });

      test('overrides text when provided', () {
        const original = EditorState(
          text: 'hello',
          lineCount: 1,
          characterCount: 5,
        );

        final copy = original.copyWith(text: 'world');

        expect(copy.text, equals('world'));
        expect(copy.lineCount, equals(1));
        expect(copy.characterCount, equals(5));
      });

      test('overrides lineCount when provided', () {
        const original = EditorState(
          text: 'hello',
          lineCount: 1,
          characterCount: 5,
        );

        final copy = original.copyWith(lineCount: 3);

        expect(copy.text, equals('hello'));
        expect(copy.lineCount, equals(3));
        expect(copy.characterCount, equals(5));
      });

      test('overrides characterCount when provided', () {
        const original = EditorState(
          text: 'hello',
          lineCount: 1,
          characterCount: 5,
        );

        final copy = original.copyWith(characterCount: 10);

        expect(copy.text, equals('hello'));
        expect(copy.lineCount, equals(1));
        expect(copy.characterCount, equals(10));
      });

      test('overrides all values when all provided', () {
        const original = EditorState(
          text: 'hello',
          lineCount: 1,
          characterCount: 5,
        );

        final copy = original.copyWith(
          text: 'new',
          lineCount: 2,
          characterCount: 3,
        );

        expect(copy.text, equals('new'));
        expect(copy.lineCount, equals(2));
        expect(copy.characterCount, equals(3));
      });
    });

    group('equality', () {
      test('equal states are equal', () {
        const a = EditorState(text: 'hi', lineCount: 1, characterCount: 2);
        const b = EditorState(text: 'hi', lineCount: 1, characterCount: 2);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different text makes states unequal', () {
        const a = EditorState(text: 'hi', lineCount: 1, characterCount: 2);
        const b = EditorState(text: 'bye', lineCount: 1, characterCount: 2);

        expect(a, isNot(equals(b)));
      });

      test('different lineCount makes states unequal', () {
        const a = EditorState(text: 'hi', lineCount: 1, characterCount: 2);
        const b = EditorState(text: 'hi', lineCount: 2, characterCount: 2);

        expect(a, isNot(equals(b)));
      });

      test('different characterCount makes states unequal', () {
        const a = EditorState(text: 'hi', lineCount: 1, characterCount: 2);
        const b = EditorState(text: 'hi', lineCount: 1, characterCount: 5);

        expect(a, isNot(equals(b)));
      });
    });

    test('toString returns expected format', () {
      const state = EditorState(text: 'hi', lineCount: 1, characterCount: 2);

      expect(
        state.toString(),
        equals('EditorState(text: hi, lineCount: 1, characterCount: 2)'),
      );
    });
  });
}
