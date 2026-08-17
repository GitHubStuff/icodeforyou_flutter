// packages/dependency_resolver/test/src/get_it_dependency_resolver_test.dart

import 'package:dependency_resolver/dependency_resolver.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  group(GetItDependencyResolver, () {
    late GetIt getIt;
    late GetItDependencyResolver resolver;

    setUp(() {
      getIt = GetIt.asNewInstance();
      resolver = GetItDependencyResolver(getIt: getIt);
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('defaults to GetIt.instance when no instance is injected', () {
      expect(GetItDependencyResolver.new, returnsNormally);
    });

    group('registerSingleton', () {
      test('registers and returns the instance', () {
        const value = 'singleton';

        final returned = resolver.registerSingleton<String>(value);

        expect(returned, same(value));
        expect(getIt.get<String>(), same(value));
      });

      test('registers under an instance name', () {
        const value = 42;

        resolver.registerSingleton<int>(value, instanceName: 'answer');

        expect(getIt.get<int>(instanceName: 'answer'), value);
      });
    });

    group('registerLazySingleton', () {
      test('defers construction until first resolution', () {
        var constructed = false;

        resolver.registerLazySingleton<String>(() {
          constructed = true;
          return 'lazy';
        });

        expect(constructed, isFalse);
        expect(getIt.get<String>(), 'lazy');
        expect(constructed, isTrue);
      });

      test('registers under an instance name', () {
        resolver.registerLazySingleton<String>(
          () => 'named lazy',
          instanceName: 'named',
        );

        expect(getIt.get<String>(instanceName: 'named'), 'named lazy');
      });
    });

    group('get', () {
      test('resolves a registered instance', () {
        getIt.registerSingleton<String>('resolved');

        expect(resolver.get<String>(), 'resolved');
      });

      test('resolves by instance name', () {
        getIt.registerSingleton<String>('named resolved', instanceName: 'n');

        expect(resolver.get<String>(instanceName: 'n'), 'named resolved');
      });
    });

    group('isRegistered', () {
      test('returns true for a registered type', () {
        getIt.registerSingleton<String>('present');

        expect(resolver.isRegistered<String>(), isTrue);
      });

      test('returns false for an unregistered type', () {
        expect(resolver.isRegistered<int>(), isFalse);
      });

      test('respects instance name', () {
        getIt.registerSingleton<String>('present', instanceName: 'x');

        expect(resolver.isRegistered<String>(instanceName: 'x'), isTrue);
        expect(resolver.isRegistered<String>(), isFalse);
      });
    });
  });
}
