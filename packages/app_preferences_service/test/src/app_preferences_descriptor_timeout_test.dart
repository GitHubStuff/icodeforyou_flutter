// app_preferences_service/test/src/app_preferences_descriptor_timeout_test.dart

// ignore_for_file: always_use_package_imports

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface, MockPreferences;
import 'package:app_preferences_service/src/app_preferences_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/service_locator.dart' show ServiceItemTimeout;

/// Test descriptor whose [build] sleeps past the 500 ms timeout so the
/// `TimeoutException` branch in [AppPreferencesDescriptor.builder] fires.
class _SlowDescriptor extends AppPreferencesDescriptor {
  const _SlowDescriptor() : super.mock();

  @override
  Future<AbstractPreferencesInterface> build() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return MockPreferences();
  }
}

void main() {
  group('AppPreferencesDescriptor builder timeout', () {
    test('rethrows TimeoutException as ServiceItemTimeout', () async {
      const descriptor = _SlowDescriptor();

      await expectLater(
        descriptor.builder(),
        throwsA(
          isA<ServiceItemTimeout>()
              .having((e) => e.toString(), 'toString', contains('AppPreferences')),
        ),
      );
    });
  });
}
