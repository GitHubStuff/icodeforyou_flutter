// app_preferences_service/test/src/app_preferences_descriptor_platform_test.dart

import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesDescriptor.platform', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('builds an AppPreferences via the platform backend', () async {
      const descriptor = AppPreferencesDescriptor.platform();

      final prefs = await descriptor.builder();

      expect(prefs, isA<AppPreferences>());
    });
  });
}
