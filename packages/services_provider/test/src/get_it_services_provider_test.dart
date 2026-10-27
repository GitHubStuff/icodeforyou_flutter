// packages/services_provider/test/src/get_it_services_provider_test.dart
import 'package:get_it/get_it.dart';
import 'package:services_provider/src/get_it_services_provider.dart';
import 'package:services_provider/src/service_provider.dart';
import 'package:test/test.dart';

class _Counter {
  int value = 0;
}

void main() {
  late GetItServiceProvider sut;

  setUp(() async {
    await GetIt.instance.reset();
    sut = GetItServiceProvider();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('GetItServiceProvider', () {
    test('is a ServiceProvider', () {
      expect(sut, isA<ServiceProvider>());
    });

    group('isRegistered', () {
      test('returns false when nothing is registered for T', () {
        expect(sut.isRegistered<_Counter>(), isFalse);
      });

      test('returns true after registerLazySingleton for T', () {
        sut.registerLazySingleton<_Counter>(_Counter.new);

        expect(sut.isRegistered<_Counter>(), isTrue);
      });
    });

    group('registerLazySingleton', () {
      test('does not invoke the factory at registration time', () {
        var calls = 0;

        sut.registerLazySingleton<_Counter>(() {
          calls++;
          return _Counter();
        });

        expect(calls, 0);
      });

      test('throws ArgumentError when T is already registered', () {
        sut.registerLazySingleton<_Counter>(_Counter.new);

        expect(
          () => sut.registerLazySingleton<_Counter>(_Counter.new),
          throwsArgumentError,
        );
      });
    });

    group('get', () {
      test('throws StateError when T is not registered', () {
        expect(sut.get<_Counter>, throwsStateError);
      });

      test('invokes the factory on first resolution', () {
        var calls = 0;

        sut.registerLazySingleton<_Counter>(() {
          calls++;
          return _Counter();
        });

        sut.get<_Counter>();

        expect(calls, 1);
      });

      test('returns the same instance on repeated resolution', () {
        sut.registerLazySingleton<_Counter>(_Counter.new);

        final first = sut.get<_Counter>();
        final second = sut.get<_Counter>();

        expect(identical(first, second), isTrue);
      });

      test('shares the registry across provider instances', () {
        sut.registerLazySingleton<_Counter>(_Counter.new);
        final other = GetItServiceProvider();

        expect(other.isRegistered<_Counter>(), isTrue);
        expect(identical(other.get<_Counter>(), sut.get<_Counter>()), isTrue);
      });
    });
  });
}
