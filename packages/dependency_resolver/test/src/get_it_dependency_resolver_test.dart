// packages/dependency_resolver/test/get_it_dependency_resolver_test.dart

import 'package:dependency_resolver/dependency_resolver.dart';
import 'package:dependency_resolver/src/dependency_resolver.dart' show DependencyResolver;
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeService {
  const _FakeService();
}

class _MockDependencyResolver extends Mock implements DependencyResolver {}

void main() {
  group('GetItDependencyResolver', () {
    const kInstanceName = 'named';

    late GetIt getIt;
    late GetItDependencyResolver resolver;

    setUp(() {
      getIt = GetIt.asNewInstance();
      resolver = GetItDependencyResolver(getIt: getIt);
    });

    test('resolves a registered singleton', () {
      const service = _FakeService();
      getIt.registerSingleton<_FakeService>(service);

      expect(resolver.get<_FakeService>(), same(service));
    });

    test('resolves a named registration', () {
      const service = _FakeService();
      getIt.registerSingleton<_FakeService>(
        service,
        instanceName: kInstanceName,
      );

      expect(
        resolver.get<_FakeService>(instanceName: kInstanceName),
        same(service),
      );
    });

    test('isRegistered reflects registration state', () {
      expect(resolver.isRegistered<_FakeService>(), isFalse);

      getIt.registerSingleton<_FakeService>(const _FakeService());

      expect(resolver.isRegistered<_FakeService>(), isTrue);
    });

    test('isRegistered honors instanceName', () {
      getIt.registerSingleton<_FakeService>(
        const _FakeService(),
        instanceName: kInstanceName,
      );

      expect(
        resolver.isRegistered<_FakeService>(instanceName: kInstanceName),
        isTrue,
      );
      expect(resolver.isRegistered<_FakeService>(), isFalse);
    });

    test('defaults to GetIt.instance when no instance is injected', () {
      GetIt.I.registerSingleton<_FakeService>(const _FakeService());
      addTearDown(GetIt.I.reset);

      final defaulted = GetItDependencyResolver();

      expect(defaulted.get<_FakeService>(), isA<_FakeService>());
    });
  });

  group('DependencyResolver mocking', () {
    test('consumers stub resolution through the interface', () {
      final resolver = _MockDependencyResolver();
      const service = _FakeService();

      when(() => resolver.get<_FakeService>()).thenReturn(service);
      when(() => resolver.isRegistered<_FakeService>()).thenReturn(true);

      expect(resolver.get<_FakeService>(), same(service));
      expect(resolver.isRegistered<_FakeService>(), isTrue);
      verify(() => resolver.get<_FakeService>()).called(1);
    });
  });
}
