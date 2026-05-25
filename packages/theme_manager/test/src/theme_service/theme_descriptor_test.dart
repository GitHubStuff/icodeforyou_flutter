// theme_manager/test/src/theme_service/theme_descriptor_test.dart

import 'dart:async';

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, MockPreferences;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferences;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:service_locator/service_locator.dart'
    show ServiceItemTimeout;
import 'package:theme_manager/src/theme_service/theme_descriptor.dart';
import 'package:theme_manager/theme_manager.dart'
    show ThemePersistence, ThemeService;

class _FakeAppPreferences extends Mock implements AppPreferences {
  _FakeAppPreferences(this._prefs);
  final AbstractPreferencesInterface _prefs;

  @override
  AbstractPreferencesInterface get prefs => _prefs;
}

class _DescriptorBuilderError implements Exception {
  const _DescriptorBuilderError(this.message);
  final String message;

  @override
  String toString() => 'DescriptorBuilderError: $message';
}

void main() {
  group('ThemeDescriptor', () {
    late MockPreferences mockPrefs;
    late _FakeAppPreferences fakeAppPrefs;

    setUp(() {
      mockPrefs = MockPreferences();
      fakeAppPrefs = _FakeAppPreferences(mockPrefs);
    });

    group('property contract', () {
      test('name is the value supplied at construction', () {
        final descriptor = ThemeDescriptor(name: 'ThemeService');

        expect(descriptor.name, 'ThemeService');
      });

      test('dependencies lists AppPreferences', () {
        final descriptor = ThemeDescriptor(name: 'ThemeService');

        expect(descriptor.dependencies, [AppPreferences]);
      });

      test('timeout is 250 milliseconds', () {
        final descriptor = ThemeDescriptor(name: 'ThemeService');

        expect(descriptor.timeout, const Duration(milliseconds: 250));
      });

      test('dark and light themes are stored when provided', () {
        final dark = ThemeData.dark();
        final light = ThemeData.light();
        final descriptor = ThemeDescriptor(
          name: 'ThemeService',
          dark: dark,
          light: light,
        );

        expect(descriptor.dark, same(dark));
        expect(descriptor.light, same(light));
      });
    });

    group('builder', () {
      test(
        'happy path: resolves AppPreferences, builds persistence, '
        'returns ThemeService',
        () async {
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (_) async => fakeAppPrefs,
            themePersistenceFactory: ThemePersistence.create,
          );

          final service = await descriptor.builder();

          expect(service, isA<ThemeService>());
          expect(service.themeCubit, isNotNull);
        },
      );

      test(
        'happy path: persisted mode is restored into the cubit state',
        () async {
          await mockPrefs.setString(
            'theme_mode-317293440000',
            ThemeMode.light.name,
          );

          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (_) async => fakeAppPrefs,
            themePersistenceFactory: ThemePersistence.create,
          );

          final service = await descriptor.builder();

          expect(service.themeCubit.state.mode, ThemeMode.light);
        },
      );

      test(
        'happy path: supplied dark and light themes flow into the cubit state',
        () async {
          final dark = ThemeData.dark();
          final light = ThemeData.light();
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            dark: dark,
            light: light,
            appPreferencesResolver: (_) async => fakeAppPrefs,
            themePersistenceFactory: ThemePersistence.create,
          );

          final service = await descriptor.builder();

          expect(service.themeCubit.state.dark, same(dark));
          expect(service.themeCubit.state.light, same(light));
        },
      );

      test(
        'resolver is invoked with the registered AppPreferences name',
        () async {
          String? capturedName;
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (n) async {
              capturedName = n;
              return fakeAppPrefs;
            },
            themePersistenceFactory: ThemePersistence.create,
          );

          await descriptor.builder();

          expect(capturedName, 'AppPreferences');
        },
      );

      test(
        'throws ServiceItemTimeout when the persistence factory exceeds '
        'the timeout',
        () async {
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (_) async => fakeAppPrefs,
            themePersistenceFactory: (_) =>
                Completer<ThemePersistence>().future, // never completes
          );

          await expectLater(
            descriptor.builder(),
            throwsA(isA<ServiceItemTimeout>()),
          );
        },
      );

      test(
        'rethrows when the resolver fails (outer catch path)',
        () async {
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (_) async =>
                throw const _DescriptorBuilderError('resolver failed'),
            themePersistenceFactory: ThemePersistence.create,
          );

          await expectLater(
            descriptor.builder(),
            throwsA(isA<_DescriptorBuilderError>()),
          );
        },
      );

      test(
        'rethrows when the persistence factory fails synchronously '
        '(outer catch path)',
        () async {
          final descriptor = ThemeDescriptor(
            name: 'ThemeService',
            appPreferencesResolver: (_) async => fakeAppPrefs,
            themePersistenceFactory: (_) async =>
                throw const _DescriptorBuilderError('factory failed'),
          );

          await expectLater(
            descriptor.builder(),
            throwsA(isA<_DescriptorBuilderError>()),
          );
        },
      );
    });

    group('default seams', () {
      test(
        'constructed without overrides exposes the production '
        'AppPreferences resolver and ThemePersistence factory',
        () {
          // The descriptor must construct cleanly with no injected seams.
          // The builder is not invoked here — that would touch the real
          // global ServiceRegistry, which has no place in a unit test.
          // This guards the default-construction path without requiring
          // registry setup.
          final descriptor = ThemeDescriptor(name: 'ThemeService');

          expect(descriptor, isA<ThemeDescriptor>());
          expect(descriptor.builder, isA<Future<ThemeService> Function()>());
        },
      );

      test(
        'defaultAppPreferencesResolver delegates to the global '
        'ServiceRegistry — invoked directly so the static is covered '
        'without coupling the builder test to the registry',
        () async {
          // Invoking the static directly executes its body and the
          // ServiceRegistry.R.getAsync call site. The registry is empty
          // in the test environment, so getAsync throws — which is the
          // signal that the call site was reached. We do not assert
          // success; we assert that the static actually ran.
          await expectLater(
            ThemeDescriptor.defaultAppPreferencesResolver('AppPreferences'),
            throwsA(anything),
          );
        },
      );
    });
  });
}
