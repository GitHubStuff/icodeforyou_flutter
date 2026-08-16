// app_preferences_service/test/src/app_preferences_service_class_test.dart

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;
import 'package:app_preferences_service/src/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/service_locator.dart' show ServiceClass;

class _FakePreferences implements AbstractPreferencesInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AppPreferencesServiceClass', () {
    test('exposes the AbstractPreferences handle passed in', () {
      final prefs = _FakePreferences();
      final service = AppPreferences(prefs);

      expect(service.prefs, same(prefs));
    });

    test('implements ServiceClass', () {
      final service = AppPreferences(_FakePreferences());

      expect(service, isA<ServiceClass>());
    });

    test('holds the same instance across reads (final field)', () {
      final prefs = _FakePreferences();
      final service = AppPreferences(prefs);

      expect(identical(service.prefs, service.prefs), isTrue);
    });
  });
}
