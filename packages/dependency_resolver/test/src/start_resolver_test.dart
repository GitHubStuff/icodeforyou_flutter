// packages/dependency_resolver/test/src/start_resolver_test.dart

import 'package:dependency_resolver/dependency_resolver.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';

void main() {
  group('startResolver', () {
    late GetIt getIt;
    late GetItDependencyResolver container;

    setUp(() {
      getIt = GetIt.asNewInstance();
      container = GetItDependencyResolver(getIt: getIt);
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('completes normally', () async {
      await expectLater(startResolver(container), completes);
    });

    test('registers the container under the DependencyResolver '
        'interface', () async {
      await startResolver(container);

      expect(container.isRegistered<DependencyResolver>(), isTrue);
    });

    test('resolves the same container instance that was started', () async {
      await startResolver(container);

      final resolved = container.get<DependencyResolver>();

      expect(resolved, same(container));
    });
  });
}
