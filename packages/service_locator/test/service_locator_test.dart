// service_locator/test/service_locator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:service_locator/service_locator.dart';

void main() {
  group('ServiceRegistry.R', () {
    setUp(GetIt.I.reset);
    tearDown(GetIt.I.reset);

    test('lazy-registers a ServiceLocatorRegistry on first access', () {
      expect(GetIt.I.isRegistered<ServiceLocatorRegistry>(), isFalse);

      final registry = ServiceRegistry.R;

      expect(registry, isA<ServiceLocatorRegistry>());
      expect(GetIt.I.isRegistered<ServiceLocatorRegistry>(), isTrue);
    });

    test('returns the same instance across calls (singleton)', () {
      final first = ServiceRegistry.R;
      final second = ServiceRegistry.R;

      expect(identical(first, second), isTrue);
    });

    test(
      'returns the pre-registered instance when one already exists',
      () {
        // Pre-register a custom instance so the `if (!isRegistered)` branch
        // is skipped on access — exercises the early-return path.
        final preRegistered = ServiceLocatorRegistry(
          locator: GetItServiceLocator(),
        );
        GetIt.I.registerSingleton<ServiceLocatorRegistry>(preRegistered);

        final registry = ServiceRegistry.R;

        expect(identical(registry, preRegistered), isTrue);
      },
    );
  });
}
