// packages/dependency_resolver/test/src/in_memory_dependency_resolver_test.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyContainer, DependencyResolver, InMemoryDependencyResolver;
import 'package:test/test.dart';

class _FakeService {
  const _FakeService();
}

class _OtherService {
  const _OtherService();
}

void main() {
  group('InMemoryDependencyResolver', () {
    const kInstanceName = 'named';

    late InMemoryDependencyResolver container;

    setUp(() {
      container = InMemoryDependencyResolver();
    });

    group('registerSingleton', () {
      test('resolves the registered instance', () {
        const service = _FakeService();
        container.registerSingleton<_FakeService>(service);

        expect(container.get<_FakeService>(), same(service));
      });

      test('returns the instance for chaining', () {
        const service = _FakeService();

        expect(
          container.registerSingleton<_FakeService>(service),
          same(service),
        );
      });

      test('keeps named and unnamed registrations independent', () {
        const unnamed = _FakeService();
        const named = _FakeService();
        container
          ..registerSingleton<_FakeService>(unnamed)
          ..registerSingleton<_FakeService>(
            named,
            instanceName: kInstanceName,
          );

        expect(container.get<_FakeService>(), same(unnamed));
        expect(
          container.get<_FakeService>(instanceName: kInstanceName),
          same(named),
        );
      });

      test('throws on duplicate registration', () {
        container.registerSingleton<_FakeService>(const _FakeService());

        expect(
          () => container.registerSingleton<_FakeService>(
            const _FakeService(),
          ),
          throwsArgumentError,
        );
      });
    });

    group('registerLazySingleton', () {
      test('builds on first resolution and caches', () {
        var buildCount = 0;
        container.registerLazySingleton<_FakeService>(() {
          buildCount++;
          return const _FakeService();
        });

        expect(buildCount, 0);

        final first = container.get<_FakeService>();
        final second = container.get<_FakeService>();

        expect(buildCount, 1);
        expect(second, same(first));
      });

      test('throws on duplicate registration across modes', () {
        container.registerLazySingleton<_FakeService>(_FakeService.new);

        expect(
          () => container.registerSingleton<_FakeService>(
            const _FakeService(),
          ),
          throwsArgumentError,
        );
        expect(
          () => container.registerLazySingleton<_FakeService>(
            _FakeService.new,
          ),
          throwsArgumentError,
        );
      });
    });

    group('get', () {
      test('throws StateError for an unregistered type', () {
        expect(container.get<_FakeService>, throwsStateError);
      });

      test('throws StateError for an unregistered name', () {
        container.registerSingleton<_FakeService>(const _FakeService());

        expect(
          () => container.get<_FakeService>(instanceName: kInstanceName),
          throwsStateError,
        );
      });

      test('error message identifies type and name', () {
        expect(
          () => container.get<_FakeService>(instanceName: kInstanceName),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              allOf(contains('_FakeService'), contains(kInstanceName)),
            ),
          ),
        );
      });
    });

    group('isRegistered', () {
      test('reflects eager, lazy, named, and absent registrations', () {
        container
          ..registerSingleton<_FakeService>(const _FakeService())
          ..registerLazySingleton<_OtherService>(_OtherService.new);

        expect(container.isRegistered<_FakeService>(), isTrue);
        expect(container.isRegistered<_OtherService>(), isTrue);
        expect(
          container.isRegistered<_FakeService>(instanceName: kInstanceName),
          isFalse,
        );
      });

      test('remains true for a lazy registration after materialization', () {
        container.registerLazySingleton<_FakeService>(_FakeService.new);
        container.get<_FakeService>();

        expect(container.isRegistered<_FakeService>(), isTrue);
      });
    });

    group('reset', () {
      test('clears eager and lazy registrations', () {
        container
          ..registerSingleton<_FakeService>(const _FakeService())
          ..registerLazySingleton<_OtherService>(_OtherService.new)
          ..reset();

        expect(container.isRegistered<_FakeService>(), isFalse);
        expect(container.isRegistered<_OtherService>(), isFalse);
      });
    });

    group('as DependencyContainer', () {
      test('supports register-then-resolve through the interfaces', () {
        final DependencyContainer asContainer = container;
        const service = _FakeService();

        asContainer.registerSingleton<DependencyResolver>(asContainer);
        asContainer.registerSingleton<_FakeService>(service);

        final DependencyResolver resolver = asContainer
            .get<DependencyResolver>();

        expect(resolver.get<_FakeService>(), same(service));
      });
    });
  });
}
