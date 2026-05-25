// app_preferences/test/src/mock/mock_preferences_test.dart
// ignore_for_file: prefer_const_constructors

import 'package:app_preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockPreferences', () {
    late MockPreferences prefs;

    setUp(() => prefs = MockPreferences());

    group('construction', () {
      test('starts empty when no initialValues provided', () async {
        expect(await prefs.contains('any'), isFalse);
        expect(prefs.snapshot(), isEmpty);
      });

      test('seeds store from initialValues', () async {
        final seeded = MockPreferences(
          initialValues: {'name': 'alice', 'count': 7},
        );
        expect(await seeded.getString('name'), 'alice');
        expect(await seeded.getInt('count'), 7);
      });

      test('initialValues are copied, not aliased', () async {
        final source = <String, Object?>{'k': 1};
        final seeded = MockPreferences(initialValues: source);
        source['k'] = 999;
        expect(await seeded.getInt('k'), 1);
      });
    });

    group('getString', () {
      test('returns stored String', () async {
        await prefs.setString('k', 'v');
        expect(await prefs.getString('k'), 'v');
      });

      test('returns null for missing key', () async {
        expect(await prefs.getString('missing'), isNull);
      });

      test('returns null when stored value is not a String', () async {
        await prefs.setInt('k', 1);
        expect(await prefs.getString('k'), isNull);
      });
    });

    group('getInt', () {
      test('returns stored int', () async {
        await prefs.setInt('k', 42);
        expect(await prefs.getInt('k'), 42);
      });

      test('returns null for missing key', () async {
        expect(await prefs.getInt('missing'), isNull);
      });

      test('returns null when stored value is not an int', () async {
        await prefs.setString('k', '42');
        expect(await prefs.getInt('k'), isNull);
      });
    });

    group('getDouble', () {
      test('returns stored double', () async {
        await prefs.setDouble('k', 3.14);
        expect(await prefs.getDouble('k'), 3.14);
      });

      test('returns null for missing key', () async {
        expect(await prefs.getDouble('missing'), isNull);
      });

      test('returns null when stored value is not a double', () async {
        await prefs.setInt('k', 3);
        expect(await prefs.getDouble('k'), isNull);
      });
    });

    group('getBool', () {
      test('returns stored bool', () async {
        await prefs.setBool('k', true);
        expect(await prefs.getBool('k'), isTrue);
      });

      test('returns null for missing key', () async {
        expect(await prefs.getBool('missing'), isNull);
      });

      test('returns null when stored value is not a bool', () async {
        await prefs.setInt('k', 1);
        expect(await prefs.getBool('k'), isNull);
      });
    });

    group('getStringList', () {
      test('returns stored List<String>', () async {
        await prefs.setStringList('k', ['a', 'b']);
        expect(await prefs.getStringList('k'), ['a', 'b']);
      });

      test('returns null for missing key', () async {
        expect(await prefs.getStringList('missing'), isNull);
      });

      test('returns null when stored value is not a List', () async {
        await prefs.setString('k', 'not a list');
        expect(await prefs.getStringList('k'), isNull);
      });

      test('returned list is unmodifiable', () async {
        await prefs.setStringList('k', ['a']);
        final result = await prefs.getStringList('k');
        expect(() => result!.add('b'), throwsUnsupportedError);
      });

      test('mutating original input does not affect stored value', () async {
        final source = ['a', 'b'];
        await prefs.setStringList('k', source);
        source.add('c');
        expect(await prefs.getStringList('k'), ['a', 'b']);
      });
    });

    group('remove', () {
      test('removes stored value', () async {
        await prefs.setString('k', 'v');
        await prefs.remove('k');
        expect(await prefs.contains('k'), isFalse);
      });

      test('is a no-op for missing key', () async {
        await prefs.remove('missing');
        expect(await prefs.contains('missing'), isFalse);
      });
    });

    group('clear', () {
      test('removes all stored values', () async {
        await prefs.setString('a', '1');
        await prefs.setInt('b', 2);
        await prefs.clear();
        expect(prefs.snapshot(), isEmpty);
      });

      test('is a no-op on an empty store', () async {
        await prefs.clear();
        expect(prefs.snapshot(), isEmpty);
      });
    });

    group('contains', () {
      test('returns true for present key', () async {
        await prefs.setBool('k', false);
        expect(await prefs.contains('k'), isTrue);
      });

      test('returns false for absent key', () async {
        expect(await prefs.contains('missing'), isFalse);
      });

      test('returns true even when stored value is null', () async {
        final seeded = MockPreferences(initialValues: {'k': null});
        expect(await seeded.contains('k'), isTrue);
      });
    });

    group('test helpers', () {
      test('reset wipes the store', () async {
        await prefs.setString('a', '1');
        prefs.reset();
        expect(prefs.snapshot(), isEmpty);
      });

      test('snapshot returns an unmodifiable copy', () async {
        await prefs.setString('a', '1');
        final snap = prefs.snapshot();
        expect(snap, {'a': '1'});
        expect(() => snap['b'] = 2, throwsUnsupportedError);
      });

      test('snapshot reflects state at call time, not later', () async {
        await prefs.setString('a', '1');
        final snap = prefs.snapshot();
        await prefs.setString('b', '2');
        expect(snap, {'a': '1'});
      });

      test('peek returns raw value without type filtering', () async {
        await prefs.setInt('k', 7);
        expect(prefs.peek('k'), 7);
      });

      test('peek returns null for missing key', () {
        expect(prefs.peek('missing'), isNull);
      });

      test('peek returns null even for keys with null values', () {
        final seeded = MockPreferences(initialValues: {'k': null});
        expect(seeded.peek('k'), isNull);
      });
    });
  });
}
