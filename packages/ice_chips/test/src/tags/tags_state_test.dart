// packages/ice_chips/test/src/tags/tags_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/glossary_types_todo.dart'
    show RecordTagDefinition, SinceWhenFailure;
import 'package:ice_chips/src/tags/tags_state.dart'
    show TagsError, TagsInitial, TagsLoaded, TagsLoading, TagsState;
import 'package:since_when_framework/database.dart'
    show DatabaseOpenFailure;

/// Persisted tag used in the loaded-state tests.
const _kTag = RecordTagDefinition(
  id: 1,
  createdTimeStamp: 1000,
  tagName: 'ALPHA',
  color: 0xFF112233,
);

void main() {
  group('TagsInitial', () {
    test('is a TagsState with empty props and value equality', () {
      const state = TagsInitial();
      expect(state, isA<TagsState>());
      expect(state.props, isEmpty);
      expect(state, equals(const TagsInitial()));
    });
  });

  group('TagsLoading', () {
    test('is a TagsState with empty props and value equality', () {
      const state = TagsLoading();
      expect(state, isA<TagsState>());
      expect(state.props, isEmpty);
      expect(state, equals(const TagsLoading()));
    });
  });

  group('TagsLoaded', () {
    test('carries its tags in props', () {
      const state = TagsLoaded([_kTag]);
      expect(state.tags, const [_kTag]);
      expect(state.props, const [
        [_kTag],
      ]);
    });

    test('value equality follows the tag list', () {
      expect(const TagsLoaded([_kTag]), equals(const TagsLoaded([_kTag])));
      expect(
        const TagsLoaded([_kTag]),
        isNot(equals(const TagsLoaded([]))),
      );
    });
  });

  group('TagsError', () {
    test('carries its failure in props with value equality', () {
      const failure = SinceWhenFailure(DatabaseOpenFailure('boom'));
      const state = TagsError(failure);
      expect(state.failure, same(failure));
      expect(state.props, [failure]);
      expect(state, equals(const TagsError(failure)));
    });

    test('distinct states are not equal to each other', () {
      const initial = TagsInitial();
      const loading = TagsLoading();
      expect(initial, isNot(equals(loading)));
    });
  });
}
