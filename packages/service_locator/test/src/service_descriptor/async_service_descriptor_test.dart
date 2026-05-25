// service_locator/test/src/service_descriptor/async_service_descriptor_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/errors.dart' show BadServiceClass;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show AsyncServiceDescriptor, ServiceClass;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

// ─── Test doubles ────────────────────────────────────────────────────────────

abstract interface class _AuthService implements ServiceClass {
  String get token;
}

class _FakeAuth implements _AuthService {
  _FakeAuth(this.token);
  @override
  final String token;
}

/// Async descriptor that builds an _AuthService eagerly.
class _AsyncAuthDescriptor extends AsyncServiceDescriptor<_AuthService> {
  _AsyncAuthDescriptor({required this.onBuild});

  final void Function() onBuild;

  @override
  String get name => 'auth-async';

  @override
  Future<_AuthService> Function() get builder => () async {
    onBuild();
    return _FakeAuth('async');
  };
}

class _AsyncCall {
  _AsyncCall({
    required this.type,
    required this.name,
    required this.builder,
  });
  final Type type;
  final String name;
  final Object builder;
}

class _RecordingLocator implements ServiceLocator {
  final List<_AsyncCall> asyncCalls = [];

  @override
  Future<SRV> registerServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
  }) async {
    asyncCalls.add(_AsyncCall(type: SRV, name: name, builder: builder));
    return builder();
  }

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) => throw UnimplementedError('not used by async descriptor tests');

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) => throw UnimplementedError('not used by async descriptor tests');

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) => throw UnimplementedError('not used by async descriptor tests');

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) =>
      throw UnimplementedError('not used by async descriptor tests');
}

class _StateEvent {
  const _StateEvent({required this.status, this.instance});
  final LocatorStatus status;
  final ServiceClass? instance;
}

class _StateRecorder {
  final List<_StateEvent> events = [];

  void call(
    LocatorStatus status, {
    ServiceClass? instance,
    Object? error,
    StackTrace? stackTrace,
  }) {
    events.add(_StateEvent(status: status, instance: instance));
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('AsyncServiceDescriptor.registerWith', () {
    late _RecordingLocator locator;
    late _StateRecorder recorder;

    setUp(() {
      locator = _RecordingLocator();
      recorder = _StateRecorder();
    });

    test(
      'forwards to registerServiceAsync, awaits the builder, '
      'and emits ready with the built instance',
      () async {
        var buildCount = 0;
        final descriptor = _AsyncAuthDescriptor(
          onBuild: () => buildCount++,
        );

        await descriptor.registerWith(locator, serviceState: recorder.call);

        // Forwarded to the eager-async registration entry point.
        expect(locator.asyncCalls, hasLength(1));
        expect(locator.asyncCalls.single.type, _AuthService);
        expect(locator.asyncCalls.single.name, 'auth-async');

        // Builder ran exactly once during registration (eager, not lazy).
        expect(buildCount, 1);

        // Ready emitted with the built instance.
        expect(recorder.events, hasLength(1));
        expect(recorder.events.single.status, LocatorStatus.ready);
        expect(recorder.events.single.instance, isA<_FakeAuth>());
        expect(
          (recorder.events.single.instance! as _FakeAuth).token,
          'async',
        );
      },
    );
  });

  group('ServiceClass.checkGeneric', () {
    test('returns normally for a concrete subtype of ServiceClass', () {
      expect(
        () => ServiceClass.checkGeneric<_AuthService>('auth'),
        returnsNormally,
      );
    });

    test('throws BadServiceClass when SRV is the marker itself', () {
      expect(
        () => ServiceClass.checkGeneric<ServiceClass>('marker'),
        throwsA(
          isA<BadServiceClass>().having(
            (e) => e.message,
            'message',
            contains('"marker"'),
          ),
        ),
      );
    });
  });
}
