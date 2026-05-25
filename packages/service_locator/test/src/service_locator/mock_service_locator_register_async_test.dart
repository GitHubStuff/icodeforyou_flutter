// service_locator/test/src/service_locator/mock_service_locator_register_async_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/errors.dart' show DuplicateServiceEntry;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_locator/mock_service_locator.dart'
    show MockServiceLocator;

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
  late MockServiceLocator locator;

  setUp(() {
    locator = MockServiceLocator();
  });

  tearDown(() {
    locator.reset();
  });

  group('MockServiceLocator.registerServiceAsync', () {
    test('returns the resolved instance, not the builder Future', () async {
      final result = await locator.registerServiceAsync<_AuthService>(
        name: 'auth',
        builder: () async => _FakeAuth('eager'),
      );

      // Pins the bug fix: result is the resolved value, not Future<SRV>.
      expect(result, isA<_FakeAuth>());
      expect(result, isNot(isA<Future<dynamic>>()));
      expect(result.token, 'eager');
    });

    test('marks the (type, name) pair as registered', () async {
      await locator.registerServiceAsync<_AuthService>(
        name: 'auth',
        builder: () async => _FakeAuth('eager'),
      );

      expect(locator.isRegistered<_AuthService>(name: 'auth'), isTrue);
    });

    test(
      'subsequent getServiceSync returns the resolved instance',
      () async {
        // Pins the bug fix: stored entry must hold the resolved value, not a
        // Future. Pre-fix, getServiceSync returned `Future<_AuthService>` and
        // the cast inside the sync arm would blow up at the call site.
        final registered = await locator.registerServiceAsync<_AuthService>(
          name: 'auth',
          builder: () async => _FakeAuth('eager'),
        );

        final resolved = locator.getServiceSync<_AuthService>(name: 'auth');

        expect(resolved, isA<_FakeAuth>());
        expect(identical(resolved, registered), isTrue);
        expect(resolved.token, 'eager');
      },
    );

    test(
      'subsequent getServiceAsync returns the resolved instance',
      () async {
        await locator.registerServiceAsync<_AuthService>(
          name: 'auth',
          builder: () async => _FakeAuth('eager'),
        );

        final resolved = await locator.getServiceAsync<_AuthService>(
          name: 'auth',
          timeout: const Duration(seconds: 1),
        );

        expect(resolved, isA<_FakeAuth>());
        expect(resolved.token, 'eager');
      },
    );

    test(
      'awaits the builder before completing',
      () async {
        var resolved = false;
        final future = locator.registerServiceAsync<_AuthService>(
          name: 'auth',
          builder: () async {
            // Force a real microtask gap so the test verifies the method
            // truly awaits, not just that an `async` keyword is present.
            await Future<void>.delayed(Duration.zero);
            resolved = true;
            return _FakeAuth('eager');
          },
        );

        await future;
        expect(resolved, isTrue);
      },
    );

    test(
      'throws DuplicateServiceEntry when the same key is already registered',
      () async {
        await locator.registerServiceAsync<_AuthService>(
          name: 'auth',
          builder: () async => _FakeAuth('first'),
        );

        await expectLater(
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
      },
    );

    test('isolates entries by name within the same type', () async {
      await locator.registerServiceAsync<_AuthService>(
        name: 'auth-a',
        builder: () async => _FakeAuth('a'),
      );
      await locator.registerServiceAsync<_AuthService>(
        name: 'auth-b',
        builder: () async => _FakeAuth('b'),
      );

      expect(locator.isRegistered<_AuthService>(name: 'auth-a'), isTrue);
      expect(locator.isRegistered<_AuthService>(name: 'auth-b'), isTrue);

      final a = locator.getServiceSync<_AuthService>(name: 'auth-a');
      final b = locator.getServiceSync<_AuthService>(name: 'auth-b');
      expect(a.token, 'a');
      expect(b.token, 'b');
    });

    test(
      'propagates a builder failure to the awaiter without registering',
      () async {
        await expectLater(
          () => locator.registerServiceAsync<_AuthService>(
            name: 'auth',
            builder: () async => throw StateError('builder boom'),
          ),
          throwsA(isA<StateError>()),
        );

        // Pins behavior: a failed registration should not have left a
        // half-built entry behind. This isn't the bug-fix scope but it's
        // worth pinning since the new `await` pulls the throw forward to
        // the registration call site instead of leaving a Future to fail
        // on later resolve.
        expect(
          locator.isRegistered<_AuthService>(name: 'auth'),
          isFalse,
          reason:
              'failed registration must not leave a stale entry — pre-fix '
              'an entry was added before the builder Future failed',
        );
      },
    );
  });
}
