// theme_manager/test/src/theme_service/theme_descriptor_default_resolver_test.dart

// ignore_for_file: comment_references

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, MockPreferences;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferences;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:service_locator/service_locator.dart'
    show ServiceRegistry, SyncServiceDescriptor;
import 'package:theme_manager/src/theme_service/theme_descriptor.dart'
    show ThemeDescriptor;

class _FakeAppPreferences extends Mock implements AppPreferences {
  _FakeAppPreferences(this._prefs);
  final AbstractPreferencesInterface _prefs;

  @override
  AbstractPreferencesInterface get prefs => _prefs;
}

/// Sync descriptor producing a pre-built [AppPreferences] instance.
///
/// Replaces the production lazy-async wiring so the dependency lands
/// in [ServiceRegistry] at [LocatorStatus.ready] after a single
/// [stage]/[register] pair — no real preferences backend involved.
class _FakeAppPreferencesDescriptor
    extends SyncServiceDescriptor<AppPreferences> {
  _FakeAppPreferencesDescriptor({
    required this.name,
    required AppPreferences instance,
  }) : _instance = instance;

  @override
  final String name;

  final AppPreferences _instance;

  @override
  List<Type> get dependencies => const [];

  @override
  AppPreferences Function() get builder =>
      () => _instance;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(GetIt.I.reset);
  tearDown(GetIt.I.reset);

  group('ThemeDescriptor.defaultAppPreferencesResolver', () {
    test(
      'resolves the registered AppPreferences via ServiceRegistry.R.getAsync',
      () async {
        final fakeAppPrefs = _FakeAppPreferences(MockPreferences());
        ServiceRegistry.R.stage(
          _FakeAppPreferencesDescriptor(
            name: 'AppPreferences',
            instance: fakeAppPrefs,
          ),
        );
        await ServiceRegistry.R.register('AppPreferences');

        final resolved = await ThemeDescriptor.defaultAppPreferencesResolver(
          'AppPreferences',
        );

        expect(resolved, same(fakeAppPrefs));
      },
    );

    test(
      'surfaces registry failure when AppPreferences is not registered',
      () async {
        await expectLater(
          ThemeDescriptor.defaultAppPreferencesResolver('AppPreferences'),
          throwsA(anything),
        );
      },
    );
  });
}
