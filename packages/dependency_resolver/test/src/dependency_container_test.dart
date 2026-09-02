// packages/dependency_resolver/test/src/dependency_container_test.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyRegistrar, DependencyResolver;
import 'package:dependency_resolver/src/dependency_container.dart';
import 'package:flutter_test/flutter_test.dart';

/// A simple fake to instantiate the interface without needing to know or
/// override any of the underlying methods from Registrar or Resolver.
class _FakeContainer extends Fake implements DependencyContainer {}

void main() {
  group('DependencyContainer', () {
    test('is a subtype of both DependencyRegistrar and DependencyResolver', () {
      final container = _FakeContainer();

      expect(
        container,
        isA<DependencyContainer>(),
        reason: 'Should instantiate as a DependencyContainer',
      );

      expect(
        container,
        isA<DependencyRegistrar>(),
        reason: 'Should implement DependencyRegistrar for write authority',
      );

      expect(
        container,
        isA<DependencyResolver>(),
        reason: 'Should implement DependencyResolver for read authority',
      );
    });
  });
}
