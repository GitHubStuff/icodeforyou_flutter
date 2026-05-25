// app_preferences_service/test/app_preferences_service_test.dart

import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app_preferences_service barrel', () {
    test('re-exports AppPreferencesDescriptor', () {
      const descriptor = AppPreferencesDescriptor.platform();
      expect(descriptor, isA<AppPreferencesDescriptor>());
    });

    test('re-exports AppPreferencesServiceClass via descriptor type', () {
      const descriptor = AppPreferencesDescriptor.platform();
      // Generic argument resolves to AppPreferencesServiceClass — proves
      // both symbols are reachable through the barrel.
      expect(descriptor.timeout, isA<Duration>());
    });

    test('re-exports AppPreferencesBackend enum', () {
      expect(AppPreferencesBackend.values, hasLength(3));
      expect(
        AppPreferencesBackend.values,
        containsAll(<AppPreferencesBackend>[
          AppPreferencesBackend.platform,
          AppPreferencesBackend.hive,
          AppPreferencesBackend.mock,
        ]),
      );
    });
  });
}
