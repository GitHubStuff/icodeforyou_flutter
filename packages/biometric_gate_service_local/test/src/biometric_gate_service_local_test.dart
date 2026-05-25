// packages/biometric_gate_service_local/test/src/biometric_gate_service_local_test.dart
import 'package:biometric_gate_service_local/biometric_gate_service_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalAuth extends Mock implements LocalAuthentication {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

LocalAuthException _ex(LocalAuthExceptionCode code) =>
    LocalAuthException(code: code, description: code.name);

void main() {
  group('defaultBiometricErrorMapper', () {
    test('maps noBiometricHardware to BiometricUnavailable', () {
      final result = defaultBiometricErrorMapper(
        _ex(LocalAuthExceptionCode.noBiometricHardware),
      );

      expect(result, isA<BiometricUnavailable>());
    });

    test('maps noBiometricsEnrolled to BiometricNotEnrolled', () {
      final result = defaultBiometricErrorMapper(
        _ex(LocalAuthExceptionCode.noBiometricsEnrolled),
      );

      expect(result, isA<BiometricNotEnrolled>());
    });

    test('maps temporaryLockout to BiometricLockedOut, carrying cause', () {
      final ex = _ex(LocalAuthExceptionCode.temporaryLockout);

      final result = defaultBiometricErrorMapper(ex);

      expect(result, isA<BiometricLockedOut>());
      expect(result.cause, same(ex));
    });

    test(
      'maps biometricLockout to BiometricPermanentlyLockedOut, carrying cause',
      () {
        final ex = _ex(LocalAuthExceptionCode.biometricLockout);

        final result = defaultBiometricErrorMapper(ex);

        expect(result, isA<BiometricPermanentlyLockedOut>());
        expect(result.cause, same(ex));
      },
    );

    test('maps unknown LocalAuthExceptionCode to BiometricUnknownFailure', () {
      // Pick any code not in the explicit-mapping list. The mapping logic is
      // about what's in the explicit list — anything else goes to Unknown.
      final unmapped = LocalAuthExceptionCode.values.firstWhere(
        (c) =>
            c != LocalAuthExceptionCode.noBiometricHardware &&
            c != LocalAuthExceptionCode.noBiometricsEnrolled &&
            c != LocalAuthExceptionCode.temporaryLockout &&
            c != LocalAuthExceptionCode.biometricLockout,
      );
      final ex = _ex(unmapped);

      final result = defaultBiometricErrorMapper(ex);

      expect(result, isA<BiometricUnknownFailure>());
      expect(result.cause, same(ex));
      expect(result.message, contains(unmapped.name));
    });

    test('maps any other Object to BiometricUnknownFailure', () {
      final ex = StateError('boom');

      final result = defaultBiometricErrorMapper(ex);

      expect(result, isA<BiometricUnknownFailure>());
      expect(result.message, ex.toString());
      expect(result.cause, same(ex));
    });
  });

  group('BiometricGateServiceLocal', () {
    late _MockLocalAuth auth;
    late _MockSecureStorage storage;

    setUp(() {
      auth = _MockLocalAuth();
      storage = _MockSecureStorage();
    });

    BiometricGateServiceLocal buildService({
      BiometricErrorMapper? errorMapper,
    }) => BiometricGateServiceLocal(
      localAuth: auth,
      secureStorage: storage,
      errorMapper: errorMapper,
    );

    /// Stubs `auth.authenticate` to return [result] regardless of arguments.
    /// `local_auth` 3.x has flat named bool params; matchers must be on the
    /// same names to be picked up.
    void stubAuth({required bool result}) {
      when(
        () => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer((_) async => result);
    }

    void stubAuthThrows(Object error) {
      when(
        () => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          sensitiveTransaction: any(named: 'sensitiveTransaction'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(error);
    }

    group('capability', () {
      test('returns none when device is not supported', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => false);

        expect(await buildService().capability(), BiometricCapability.none);
      });

      test('returns none when canCheckBiometrics is false', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);

        expect(await buildService().capability(), BiometricCapability.none);
      });

      test('returns notEnrolled when no biometrics are enrolled', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(() => auth.getAvailableBiometrics()).thenAnswer((_) async => []);

        expect(
          await buildService().capability(),
          BiometricCapability.notEnrolled,
        );
      });

      test('returns face when face is available', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          () => auth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.face]);

        expect(await buildService().capability(), BiometricCapability.face);
      });

      test('returns fingerprint when only fingerprint is available', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          () => auth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.fingerprint]);

        expect(
          await buildService().capability(),
          BiometricCapability.fingerprint,
        );
      });

      test('returns iris when only iris is available', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(
          () => auth.getAvailableBiometrics(),
        ).thenAnswer((_) async => [BiometricType.iris]);

        expect(await buildService().capability(), BiometricCapability.iris);
      });

      test(
        'returns generic for strong/weak (Android) classifications',
        () async {
          when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
          when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
          when(
            () => auth.getAvailableBiometrics(),
          ).thenAnswer((_) async => [BiometricType.strong]);

          expect(
            await buildService().capability(),
            BiometricCapability.generic,
          );
        },
      );

      test('prefers face over fingerprint when both are available', () async {
        when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
        when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
        when(() => auth.getAvailableBiometrics()).thenAnswer(
          (_) async => [BiometricType.fingerprint, BiometricType.face],
        );

        expect(await buildService().capability(), BiometricCapability.face);
      });

      test('returns none when isDeviceSupported throws', () async {
        when(() => auth.isDeviceSupported()).thenThrow(Exception('boom'));

        expect(await buildService().capability(), BiometricCapability.none);
      });
    });

    group('isEnabled', () {
      test('returns true when stored value is exactly "true"', () async {
        when(
          () => storage.read(
            key: kBiometricEnabledKey,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async => 'true');

        expect(await buildService().isEnabled(), isTrue);
      });

      test('returns false when no value is stored', () async {
        when(
          () => storage.read(
            key: kBiometricEnabledKey,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async => null);

        expect(await buildService().isEnabled(), isFalse);
      });

      test(
        'returns false when stored value is anything other than "true"',
        () async {
          when(
            () => storage.read(
              key: kBiometricEnabledKey,
              iOptions: any(named: 'iOptions'),
              aOptions: any(named: 'aOptions'),
            ),
          ).thenAnswer((_) async => 'false');

          expect(await buildService().isEnabled(), isFalse);
        },
      );

      test('returns false when storage throws', () async {
        when(
          () => storage.read(
            key: kBiometricEnabledKey,
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenThrow(Exception('boom'));

        expect(await buildService().isEnabled(), isFalse);
      });
    });

    group('enable', () {
      test('writes "true" under the enabled key', () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async {});

        final result = await buildService().enable();

        expect(result.isRight(), isTrue);
        verify(
          () => storage.write(
            key: kBiometricEnabledKey,
            value: 'true',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).called(1);
      });

      test('routes thrown errors through the injected mapper', () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenThrow(Exception('boom'));
        const sentinel = BiometricStorageFailure(message: 'sentinel-enable');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).enable();

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });

    group('disable', () {
      test('clears all stored values', () async {
        when(
          () => storage.deleteAll(
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async {});

        final result = await buildService().disable();

        expect(result.isRight(), isTrue);
        verify(
          () => storage.deleteAll(
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).called(1);
      });

      test('routes thrown errors through the injected mapper', () async {
        when(
          () => storage.deleteAll(
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenThrow(Exception('boom'));
        const sentinel = BiometricStorageFailure(message: 'sentinel-disable');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).disable();

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });

    group('verify', () {
      test('returns Right(unit) when prompt succeeds', () async {
        stubAuth(result: true);

        final result = await buildService().verify(reason: 'Unlock');

        expect(result.isRight(), isTrue);
        result.match(
          (_) => fail('expected Right'),
          (u) => expect(u, unit),
        );
      });

      test('returns BiometricCancelled when prompt returns false', () async {
        stubAuth(result: false);

        final result = await buildService().verify(reason: 'Unlock');

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            isA<BiometricCancelled>(),
          ),
        );
      });

      test('routes thrown errors through the injected mapper', () async {
        stubAuthThrows(Exception('boom'));
        const sentinel = BiometricUnknownFailure(message: 'sentinel-verify');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).verify(reason: 'Unlock');

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });

    group('store', () {
      test('writes the supplied key and value', () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async {});

        final result = await buildService().store(
          key: 'session_token',
          value: 'opaque-payload',
        );

        expect(result.isRight(), isTrue);
        verify(
          () => storage.write(
            key: 'session_token',
            value: 'opaque-payload',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).called(1);
      });

      test('routes thrown errors through the injected mapper', () async {
        when(
          () => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenThrow(Exception('boom'));
        const sentinel = BiometricStorageFailure(message: 'sentinel-store');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).store(key: 'k', value: 'v');

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });

    group('retrieve', () {
      test('returns the stored value when prompt succeeds', () async {
        stubAuth(result: true);
        when(
          () => storage.read(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async => 'stored-value');

        final result = await buildService().retrieve(
          key: 'session_token',
          reason: 'Unlock',
        );

        expect(result.isRight(), isTrue);
        result.match(
          (_) => fail('expected Right'),
          (v) => expect(v, 'stored-value'),
        );
      });

      test('returns BiometricCancelled when prompt returns false', () async {
        stubAuth(result: false);

        final result = await buildService().retrieve(
          key: 'session_token',
          reason: 'Unlock',
        );

        expect(
          result,
          isA<Left<BiometricFailure, String>>().having(
            (l) => l.value,
            'value',
            isA<BiometricCancelled>(),
          ),
        );
      });

      test(
        'returns BiometricStorageFailure when stored value is null',
        () async {
          stubAuth(result: true);
          when(
            () => storage.read(
              key: any(named: 'key'),
              iOptions: any(named: 'iOptions'),
              aOptions: any(named: 'aOptions'),
            ),
          ).thenAnswer((_) async => null);

          final result = await buildService().retrieve(
            key: 'missing_key',
            reason: 'Unlock',
          );

          expect(
            result,
            isA<Left<BiometricFailure, String>>().having(
              (l) => l.value,
              'value',
              isA<BiometricStorageFailure>(),
            ),
          );
        },
      );

      test('routes thrown errors through the injected mapper', () async {
        stubAuthThrows(Exception('boom'));
        const sentinel = BiometricUnknownFailure(message: 'sentinel-retrieve');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).retrieve(key: 'k', reason: 'r');

        expect(
          result,
          isA<Left<BiometricFailure, String>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });

    group('clear', () {
      test('deletes the value under the supplied key', () async {
        when(
          () => storage.delete(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenAnswer((_) async {});

        final result = await buildService().clear(key: 'session_token');

        expect(result.isRight(), isTrue);
        verify(
          () => storage.delete(
            key: 'session_token',
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).called(1);
      });

      test('routes thrown errors through the injected mapper', () async {
        when(
          () => storage.delete(
            key: any(named: 'key'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          ),
        ).thenThrow(Exception('boom'));
        const sentinel = BiometricStorageFailure(message: 'sentinel-clear');

        final result = await buildService(
          errorMapper: (_) => sentinel,
        ).clear(key: 'k');

        expect(
          result,
          isA<Left<BiometricFailure, Unit>>().having(
            (l) => l.value,
            'value',
            same(sentinel),
          ),
        );
      });
    });
  });
}
