// service_locator/test/src/service_locator/get_it_service_locator_register_async_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:service_locator/service_locator.dart' show GetItServiceLocator;
import 'package:service_locator/src/errors.dart' show DuplicateServiceEntry;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;

// ─── Test doubles ────────────────────────────────────────────────────────────

abstract interface class _AuthService implements ServiceClass {
  String get token;
}

class _FakeAuth implements _AuthService {
  _FakeAuth(this.token);
  @override
  final String token;
}

void main() {
  late GetIt getIt;
  late GetItServiceLocator locator;

  setUp(() {
    getIt = GetIt.asNewInstance();
    locator = GetItServiceLocator(getIt: getIt);
  });

  tearDown(() => getIt.reset());

  group('GetItServiceLocator.registerServiceAsync', () {
    test('registers and returns the built instance', () async {
      final result = await locator.registerServiceAsync<_AuthService>(
        name: 'auth',
        builder: () async => _FakeAuth('eager'),
      );

      expect(result, isA<_FakeAuth>());
      expect(result.token, 'eager');
      expect(getIt.isRegistered<_AuthService>(instanceName: 'auth'), isTrue);
    });

    test('subsequent sync resolution returns the registered instance',
        () async {
      final registered = await locator.registerServiceAsync<_AuthService>(
        name: 'auth',
        builder: () async => _FakeAuth('eager'),
      );

      final resolved = locator.getServiceSync<_AuthService>(name: 'auth');
      expect(identical(resolved, registered), isTrue);
    });

    test('throws DuplicateServiceEntry when name is already registered',
        () async {
      await locator.registerServiceAsync<_AuthService>(
        name: 'auth',
        builder: () async => _FakeAuth('first'),
      );

      expect(
        () => locator.registerServiceAsync<_AuthService>(
          name: 'auth',
          builder: () async => _FakeAuth('second'),
        ),
        throwsA(
          isA<DuplicateServiceEntry>().having(
            (e) => e.message,
            'message',
            contains('"auth"'),
          ),
        ),
      );
    });

    test(
      'swallows builder failure during isReady await, then surfaces it on '
      'the post-await getServiceSync',
      () async {
        // The adapter intentionally swallows isReady's exception (the empty
        // catch on the post-registerSingletonAsync isReady), then defers to
        // getServiceSync — which propagates the original error from get_it's
        // internal state.
        expect(
          () => locator.registerServiceAsync<_AuthService>(
            name: 'auth',
            builder: () async => throw StateError('builder boom'),
          ),
          throwsA(isA<Object>()),
        );
      },
    );
  });
}
