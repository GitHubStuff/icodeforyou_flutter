// app_preferences/test/src/platform/platform_preferences_test.dart

import 'package:app_preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('PlatformPreferences', () {
    late _MockSharedPreferencesAsync mockPrefs;
    late PlatformPreferences prefs;

    setUp(() {
      mockPrefs = _MockSharedPreferencesAsync();
      prefs = PlatformPreferences(mockPrefs);
    });

    group('create', () {
      test('returns a ready instance', () async {
        final created = await PlatformPreferences.create();
        expect(created, isA<PlatformPreferences>());
      });
    });

    group('reads', () {
      test('getString delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.getString('k')).thenAnswer((_) async => 'v');
        expect(await prefs.getString('k'), 'v');
        verify(() => mockPrefs.getString('k')).called(1);
      });

      test('getString propagates null', () async {
        when(() => mockPrefs.getString('k')).thenAnswer((_) async => null);
        expect(await prefs.getString('k'), isNull);
      });

      test('getInt delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.getInt('k')).thenAnswer((_) async => 42);
        expect(await prefs.getInt('k'), 42);
        verify(() => mockPrefs.getInt('k')).called(1);
      });

      test('getInt propagates null', () async {
        when(() => mockPrefs.getInt('k')).thenAnswer((_) async => null);
        expect(await prefs.getInt('k'), isNull);
      });

      test('getDouble delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.getDouble('k')).thenAnswer((_) async => 3.14);
        expect(await prefs.getDouble('k'), 3.14);
        verify(() => mockPrefs.getDouble('k')).called(1);
      });

      test('getDouble propagates null', () async {
        when(() => mockPrefs.getDouble('k')).thenAnswer((_) async => null);
        expect(await prefs.getDouble('k'), isNull);
      });

      test('getBool delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.getBool('k')).thenAnswer((_) async => true);
        expect(await prefs.getBool('k'), isTrue);
        verify(() => mockPrefs.getBool('k')).called(1);
      });

      test('getBool propagates null', () async {
        when(() => mockPrefs.getBool('k')).thenAnswer((_) async => null);
        expect(await prefs.getBool('k'), isNull);
      });

      test('getStringList delegates to SharedPreferencesAsync', () async {
        when(
          () => mockPrefs.getStringList('k'),
        ).thenAnswer((_) async => ['a', 'b']);
        expect(await prefs.getStringList('k'), ['a', 'b']);
        verify(() => mockPrefs.getStringList('k')).called(1);
      });

      test('getStringList propagates null', () async {
        when(
          () => mockPrefs.getStringList('k'),
        ).thenAnswer((_) async => null);
        expect(await prefs.getStringList('k'), isNull);
      });
    });

    group('writes', () {
      test('setString delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.setString('k', 'v')).thenAnswer((_) async {});
        await prefs.setString('k', 'v');
        verify(() => mockPrefs.setString('k', 'v')).called(1);
      });

      test('setInt delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.setInt('k', 42)).thenAnswer((_) async {});
        await prefs.setInt('k', 42);
        verify(() => mockPrefs.setInt('k', 42)).called(1);
      });

      test('setDouble delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.setDouble('k', 3.14)).thenAnswer((_) async {});
        await prefs.setDouble('k', 3.14);
        verify(() => mockPrefs.setDouble('k', 3.14)).called(1);
      });

      test('setBool delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.setBool('k', true)).thenAnswer((_) async {});
        await prefs.setBool('k', true);
        verify(() => mockPrefs.setBool('k', true)).called(1);
      });

      test('setStringList delegates to SharedPreferencesAsync', () async {
        when(
          () => mockPrefs.setStringList('k', ['a', 'b']),
        ).thenAnswer((_) async {});
        await prefs.setStringList('k', ['a', 'b']);
        verify(() => mockPrefs.setStringList('k', ['a', 'b'])).called(1);
      });
    });

    group('structural', () {
      test('remove delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.remove('k')).thenAnswer((_) async {});
        await prefs.remove('k');
        verify(() => mockPrefs.remove('k')).called(1);
      });

      test('clear delegates to SharedPreferencesAsync', () async {
        when(() => mockPrefs.clear()).thenAnswer((_) async {});
        await prefs.clear();
        verify(() => mockPrefs.clear()).called(1);
      });

      test(
        'contains delegates to SharedPreferencesAsync.containsKey',
        () async {
          when(
            () => mockPrefs.containsKey('k'),
          ).thenAnswer((_) async => true);
          expect(await prefs.contains('k'), isTrue);
          verify(() => mockPrefs.containsKey('k')).called(1);
        },
      );

      test('contains returns false when key absent', () async {
        when(
          () => mockPrefs.containsKey('missing'),
        ).thenAnswer((_) async => false);
        expect(await prefs.contains('missing'), isFalse);
      });
    });
  });
}
