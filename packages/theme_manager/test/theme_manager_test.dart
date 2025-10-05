// test/theme_cubit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nosql/nosql.dart' show NoSqlDBAbstract, NoSqlBoxAbstract;
import 'package:theme_manager/theme_manager.dart' show ThemeCubit, ThemeState;

class MockNoSqlDB extends Mock implements NoSqlDBAbstract {}

class MockNoSqlBoxAbstract extends Mock implements NoSqlBoxAbstract<String> {}

void main() {
  group('ThemeCubit', () {
    late MockNoSqlDB mockDb;
    late MockNoSqlBoxAbstract mockBox;

    setUp(() {
      mockDb = MockNoSqlDB();
      mockBox = MockNoSqlBoxAbstract();
    });

    group('create', () {
      test('successfully creates cubit with saved theme', () async {
        when(
          () => mockDb.openBox<String>(any()),
        ).thenAnswer((_) async => mockBox);
        when(
          () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
        ).thenAnswer((_) async => 'dark');

        final cubit = await ThemeCubit.create(nosqlDB: mockDb);

        expect(cubit.state, equals(ThemeState.dark));
        verify(
          () => mockDb.openBox<String>('theme_mgr_pkg_b8f4c2e9d1a7f5b3'),
        ).called(1);
        verify(
          () => mockBox.get(
            'theme_mgr_pkg_b8f4c2e9d1a7f5b3',
            defaultValue: 'system',
          ),
        ).called(1);
      });

      test('successfully creates cubit with default theme', () async {
        when(
          () => mockDb.openBox<String>(any()),
        ).thenAnswer((_) async => mockBox);
        when(
          () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
        ).thenAnswer((_) async => 'system');

        final cubit = await ThemeCubit.create(nosqlDB: mockDb);

        expect(cubit.state, equals(ThemeState.system));
      });

      test('throws exception when box is null', () async {
        when(() => mockDb.openBox<String>(any())).thenAnswer((_) async => null);

        expect(
          () => ThemeCubit.create(nosqlDB: mockDb),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid state for NoSqlBox'),
            ),
          ),
        );
      });

      test('creates cubit with light theme', () async {
        when(
          () => mockDb.openBox<String>(any()),
        ).thenAnswer((_) async => mockBox);
        when(
          () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
        ).thenAnswer((_) async => 'light');

        final cubit = await ThemeCubit.create(nosqlDB: mockDb);

        expect(cubit.state, equals(ThemeState.light));
      });

      test('creates cubit with initial theme', () async {
        when(
          () => mockDb.openBox<String>(any()),
        ).thenAnswer((_) async => mockBox);
        when(
          () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
        ).thenAnswer((_) async => 'initial');

        final cubit = await ThemeCubit.create(nosqlDB: mockDb);

        expect(cubit.state, equals(ThemeState.initial));
      });
    });

    group('brightness', () {
      test('returns correct brightness for current state', () async {
        when(
          () => mockDb.openBox<String>(any()),
        ).thenAnswer((_) async => mockBox);
        when(
          () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
        ).thenAnswer((_) async => 'dark');

        final cubit = await ThemeCubit.create(nosqlDB: mockDb);

        expect(cubit.brightness, equals(Brightness.dark));
      });
    });

    group('setTheme', () {
      late ThemeCubit cubit;

      blocTest<ThemeCubit, ThemeState>(
        'emits dark theme when setTheme called with dark mode',
        setUp: () async {
          when(
            () => mockDb.openBox<String>(any()),
          ).thenAnswer((_) async => mockBox);
          when(
            () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
          ).thenAnswer((_) async => 'light');
          when(() => mockBox.put(any(), any())).thenAnswer((_) async => true);

          cubit = await ThemeCubit.create(nosqlDB: mockDb);
        },
        build: () => cubit,
        act: (cubit) => cubit.setTheme(ThemeMode.dark),
        expect: () => [ThemeState.dark],
        verify: (_) {
          verify(
            () => mockBox.put('theme_mgr_pkg_b8f4c2e9d1a7f5b3', 'dark'),
          ).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits light theme when setTheme called with light mode',
        setUp: () async {
          when(
            () => mockDb.openBox<String>(any()),
          ).thenAnswer((_) async => mockBox);
          when(
            () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
          ).thenAnswer((_) async => 'dark');
          when(() => mockBox.put(any(), any())).thenAnswer((_) async => true);

          cubit = await ThemeCubit.create(nosqlDB: mockDb);
        },
        build: () => cubit,
        act: (cubit) => cubit.setTheme(ThemeMode.light),
        expect: () => [ThemeState.light],
        verify: (_) {
          verify(
            () => mockBox.put('theme_mgr_pkg_b8f4c2e9d1a7f5b3', 'light'),
          ).called(1);
        },
      );

      blocTest<ThemeCubit, ThemeState>(
        'emits system theme when setTheme called with system mode',
        setUp: () async {
          when(
            () => mockDb.openBox<String>(any()),
          ).thenAnswer((_) async => mockBox);
          when(
            () => mockBox.get(any(), defaultValue: any(named: 'defaultValue')),
          ).thenAnswer((_) async => 'dark');
          when(() => mockBox.put(any(), any())).thenAnswer((_) async => true);

          cubit = await ThemeCubit.create(nosqlDB: mockDb);
        },
        build: () => cubit,
        act: (cubit) => cubit.setTheme(ThemeMode.system),
        expect: () => [ThemeState.system],
        verify: (_) {
          verify(
            () => mockBox.put('theme_mgr_pkg_b8f4c2e9d1a7f5b3', 'system'),
          ).called(1);
        },
      );
    });
  });

  group('ThemeState', () {
    group('from', () {
      test('returns dark for dark name', () {
        expect(ThemeState.from(name: 'dark'), equals(ThemeState.dark));
      });

      test('returns light for light name', () {
        expect(ThemeState.from(name: 'light'), equals(ThemeState.light));
      });

      test('returns system for system name', () {
        expect(ThemeState.from(name: 'system'), equals(ThemeState.system));
      });

      test('returns initial for initial name', () {
        expect(ThemeState.from(name: 'initial'), equals(ThemeState.initial));
      });

      test('handles case insensitive lookup', () {
        expect(ThemeState.from(name: 'DARK'), equals(ThemeState.dark));
        expect(ThemeState.from(name: 'Light'), equals(ThemeState.light));
        expect(ThemeState.from(name: 'SYSTEM'), equals(ThemeState.system));
        expect(ThemeState.from(name: 'Initial'), equals(ThemeState.initial));
      });

      test('throws exception for invalid name', () {
        expect(
          () => ThemeState.from(name: 'invalid'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('ThemeState not found'),
            ),
          ),
        );
      });
    });

    group('mode', () {
      test('returns correct ThemeMode for dark', () {
        expect(ThemeState.dark.mode, equals(ThemeMode.dark));
      });

      test('returns correct ThemeMode for light', () {
        expect(ThemeState.light.mode, equals(ThemeMode.light));
      });

      test('returns correct ThemeMode for system', () {
        expect(ThemeState.system.mode, equals(ThemeMode.system));
      });

      test('returns correct ThemeMode for initial', () {
        expect(ThemeState.initial.mode, equals(ThemeMode.system));
      });
    });

    group('brightness', () {
      test('returns dark brightness for dark state', () {
        expect(ThemeState.dark.brightness, equals(Brightness.dark));
      });

      test('returns light brightness for light state', () {
        expect(ThemeState.light.brightness, equals(Brightness.light));
      });

      test('returns platform brightness for system state', () {
        expect(ThemeState.system.brightness, isA<Brightness>());
      });

      test('returns platform brightness for initial state', () {
        expect(ThemeState.initial.brightness, isA<Brightness>());
      });
    });
  });
}
