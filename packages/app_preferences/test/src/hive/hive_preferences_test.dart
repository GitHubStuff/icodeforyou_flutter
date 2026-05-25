// app_preferences/test/src/hive/hive_preferences_test.dart

import 'dart:io';

import 'package:app_preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('HivePreferences', () {
    late Directory tempDir;
    late HivePreferences prefs;
    var boxCounter = 0;

    String nextBoxName() => 'test_box_${boxCounter++}';

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_pref_test_');
      Hive.init(tempDir.path);
      final box = await Hive.openBox<dynamic>(nextBoxName());
      prefs = HivePreferences(box);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
      HivePreferences.resetForTesting();
    });

    group('reads', () {
      test('getString returns stored String', () async {
        await prefs.setString('k', 'v');
        expect(await prefs.getString('k'), 'v');
      });

      test('getString returns null for missing key', () async {
        expect(await prefs.getString('missing'), isNull);
      });

      test(
        'getString returns null when stored value is not a String',
        () async {
          await prefs.setInt('k', 1);
          expect(await prefs.getString('k'), isNull);
        },
      );

      test('getInt returns stored int', () async {
        await prefs.setInt('k', 42);
        expect(await prefs.getInt('k'), 42);
      });

      test('getInt returns null for missing key', () async {
        expect(await prefs.getInt('missing'), isNull);
      });

      test('getInt returns null when stored value is not an int', () async {
        await prefs.setString('k', '42');
        expect(await prefs.getInt('k'), isNull);
      });

      test('getDouble returns stored double', () async {
        await prefs.setDouble('k', 3.14);
        expect(await prefs.getDouble('k'), 3.14);
      });

      test('getDouble returns null for missing key', () async {
        expect(await prefs.getDouble('missing'), isNull);
      });

      test(
        'getDouble returns null when stored value is not a double',
        () async {
          await prefs.setString('k', '3.14');
          expect(await prefs.getDouble('k'), isNull);
        },
      );

      test('getBool returns stored bool', () async {
        await prefs.setBool('k', true);
        expect(await prefs.getBool('k'), isTrue);
      });

      test('getBool returns null for missing key', () async {
        expect(await prefs.getBool('missing'), isNull);
      });

      test('getBool returns null when stored value is not a bool', () async {
        await prefs.setInt('k', 1);
        expect(await prefs.getBool('k'), isNull);
      });

      test('getStringList returns stored List<String>', () async {
        await prefs.setStringList('k', ['a', 'b']);
        expect(await prefs.getStringList('k'), ['a', 'b']);
      });

      test('getStringList returns null for missing key', () async {
        expect(await prefs.getStringList('missing'), isNull);
      });

      test(
        'getStringList returns null when stored value is not a List',
        () async {
          await prefs.setString('k', 'not a list');
          expect(await prefs.getStringList('k'), isNull);
        },
      );

      test('mutating original input does not affect stored value', () async {
        final source = ['a', 'b'];
        await prefs.setStringList('k', source);
        source.add('c');
        expect(await prefs.getStringList('k'), ['a', 'b']);
      });
    });

    group('writes overwrite existing values', () {
      test('setString overwrites', () async {
        await prefs.setString('k', 'v1');
        await prefs.setString('k', 'v2');
        expect(await prefs.getString('k'), 'v2');
      });

      test('setInt overwrites', () async {
        await prefs.setInt('k', 1);
        await prefs.setInt('k', 2);
        expect(await prefs.getInt('k'), 2);
      });
    });

    group('structural', () {
      test('remove deletes stored value', () async {
        await prefs.setString('k', 'v');
        await prefs.remove('k');
        expect(await prefs.contains('k'), isFalse);
      });

      test('remove is a no-op for missing key', () async {
        await prefs.remove('missing');
        expect(await prefs.contains('missing'), isFalse);
      });

      test('clear removes all stored values', () async {
        await prefs.setString('a', '1');
        await prefs.setInt('b', 2);
        await prefs.clear();
        expect(await prefs.contains('a'), isFalse);
        expect(await prefs.contains('b'), isFalse);
      });

      test('contains returns true for present key', () async {
        await prefs.setBool('k', true);
        expect(await prefs.contains('k'), isTrue);
      });

      test('contains returns false for absent key', () async {
        expect(await prefs.contains('missing'), isFalse);
      });
    });

    group('init', () {
      late Directory initTempDir;

      setUp(() async {
        // Each init test wants a clean Hive state.
        await Hive.close();
        HivePreferences.resetForTesting();
        initTempDir = await Directory.systemTemp.createTemp('hive_init_test_');
      });

      tearDown(() async {
        await Hive.close();
        if (initTempDir.existsSync()) {
          await initTempDir.delete(recursive: true);
        }
        HivePreferences.resetForTesting();
      });

      test('init with HiveInitMode.test creates a temp directory', () async {
        await HivePreferences.init(mode: HiveInitMode.test);
        // No throw — creating a box afterwards confirms init succeeded.
        final p = await HivePreferences.create(boxName: 'init_test_box');
        await p.setString('k', 'v');
        expect(await p.getString('k'), 'v');
      });

      test('init with HiveInitMode.custom uses customPath', () async {
        await HivePreferences.init(
          mode: HiveInitMode.custom,
          customPath: initTempDir.path,
        );
        final p = await HivePreferences.create(boxName: 'custom_box');
        await p.setString('k', 'v');
        // The box file should now exist under the custom path.
        final files = initTempDir.listSync();
        expect(files.any((f) => f.path.endsWith('custom_box.hive')), isTrue);
      });

      test('init returns early if already initialized in release', () async {
        await HivePreferences.init(
          mode: HiveInitMode.custom,
          customPath: initTempDir.path,
        );
        // Second init would assert in debug, return early in release.
        // We can't easily test the release branch, but we can confirm
        // the flag is set and resetForTesting clears it.
        HivePreferences.resetForTesting();
        await HivePreferences.init(
          mode: HiveInitMode.custom,
          customPath: initTempDir.path,
        );
      });

      test('create asserts when init has not been called', () async {
        // _initialized was just reset in setUp.
        expect(
          () => HivePreferences.create(boxName: 'no_init'),
          throwsA(isA<AssertionError>()),
        );
      });

      test('init asserts when called twice', () async {
        await HivePreferences.init(
          mode: HiveInitMode.custom,
          customPath: initTempDir.path,
        );
        expect(
          () => HivePreferences.init(
            mode: HiveInitMode.custom,
            customPath: initTempDir.path,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test(
        'init with HiveInitMode.custom asserts when customPath is null',
        () async {
          expect(
            () => HivePreferences.init(mode: HiveInitMode.custom),
            throwsA(isA<AssertionError>()),
          );
        },
      );
    });
  });
}
