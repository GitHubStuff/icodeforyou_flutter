// test/src/editor_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:edittext_popover/src/_editor_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorScreenCubit', () {
    test('initial state is created from initialText', () async {
      final cubit = EditorScreenCubit(initialText: 'hello');

      expect(cubit.state.text, equals('hello'));
      expect(cubit.state.lineCount, equals(1));
      expect(cubit.state.characterCount, equals(5));

      await cubit.close();
    });

    test('initial state with empty string', () async {
      final cubit = EditorScreenCubit(initialText: '');

      expect(cubit.state.text, equals(''));
      expect(cubit.state.lineCount, equals(0));
      expect(cubit.state.characterCount, equals(0));

      await cubit.close();
    });

    test('initial state with newlines', () async {
      final cubit = EditorScreenCubit(initialText: 'a\nb\nc');

      expect(cubit.state.text, equals('a\nb\nc'));
      expect(cubit.state.lineCount, equals(3));
      expect(cubit.state.characterCount, equals(5));

      await cubit.close();
    });

    group('updateText', () {
      blocTest<EditorScreenCubit, EditorState>(
        'emits new state with updated text',
        build: () => EditorScreenCubit(initialText: ''),
        act: (cubit) => cubit.updateText('hello'),
        expect: () => [
          const EditorState(text: 'hello', lineCount: 1, characterCount: 5),
        ],
      );

      blocTest<EditorScreenCubit, EditorState>(
        'updates line count correctly with newlines',
        build: () => EditorScreenCubit(initialText: ''),
        act: (cubit) => cubit.updateText('a\nb\nc'),
        expect: () => [
          const EditorState(text: 'a\nb\nc', lineCount: 3, characterCount: 5),
        ],
      );

      blocTest<EditorScreenCubit, EditorState>(
        'updates to empty string',
        build: () => EditorScreenCubit(initialText: 'hello'),
        act: (cubit) => cubit.updateText(''),
        expect: () => [
          const EditorState(text: '', lineCount: 0, characterCount: 0),
        ],
      );

      blocTest<EditorScreenCubit, EditorState>(
        'handles multiple updates',
        build: () => EditorScreenCubit(initialText: ''),
        act: (cubit) {
          cubit
            ..updateText('a')
            ..updateText('ab')
            ..updateText('abc');
        },
        expect: () => [
          const EditorState(text: 'a', lineCount: 1, characterCount: 1),
          const EditorState(text: 'ab', lineCount: 1, characterCount: 2),
          const EditorState(text: 'abc', lineCount: 1, characterCount: 3),
        ],
      );

      blocTest<EditorScreenCubit, EditorState>(
        'handles trailing newline',
        build: () => EditorScreenCubit(initialText: ''),
        act: (cubit) => cubit.updateText('hello\n'),
        expect: () => [
          const EditorState(text: 'hello\n', lineCount: 2, characterCount: 6),
        ],
      );

      blocTest<EditorScreenCubit, EditorState>(
        'handles only newline',
        build: () => EditorScreenCubit(initialText: ''),
        act: (cubit) => cubit.updateText('\n'),
        expect: () => [
          const EditorState(text: '\n', lineCount: 2, characterCount: 1),
        ],
      );
    });
  });
}
