// ignore_for_file: public_member_api_docs
// packages/services_locator/lib/src/service_locator/getit_service_locator.dart
//
// Adapter that implements [ServiceLocator] on top of the get_it package.
// Accepts an injected [GetIt] instance so tests can use a fresh registry
// per test via `GetIt.asNewInstance()` instead of the `GetIt.I` singleton.
//

import 'package:get_it/get_it.dart';
import 'package:services_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotReady, ServiceNotRegistered;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

class GetItServiceLocator implements ServiceLocator {
  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  GetItServiceLocator({GetIt? getIt}) : _getIt = getIt ?? GetIt.I;

  final GetIt _getIt;

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    _assertRegistered<SRV>(name);
    await _getIt.isReady<SRV>(instanceName: name, timeout: timeout);
    return _getIt.get<SRV>(instanceName: name);
  }

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    _assertRegistered<SRV>(name);
    return _getOrThrowNotReady<SRV>(name);
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }
    _getIt.registerLazySingletonAsync<SRV>(
      builder,
      instanceName: name,
      onCreated: (service) {
        serviceState(LocatorStatus.ready, instance: service);
      },
    );
    serviceState(LocatorStatus.starting);
  }

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }
    // Register with signalsReady:true so the instance participates in GetIt's
    // readiness machinery (isReady / isReadySync), then immediately signal
    // it ready. A sync-registered instance is, by definition, ready at the
    // moment of registration -- there's no async initialization to wait for.
    // This lets getServiceAsync call GetIt.isReady uniformly for both sync
    // and lazy-async registrations without special-casing either path.
    final result = _getIt.registerSingleton<SRV>(
      instance,
      instanceName: name,
      signalsReady: true,
    );
    _getIt.signalReady(instance);
    return result;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _assertRegistered<SRV extends ServiceClass>(String name) {
    if (_getIt.isRegistered<SRV>(instanceName: name)) return;
    throw ServiceNotRegistered(name);
  }

  SRV _getOrThrowNotReady<SRV extends ServiceClass>(String name) {
    try {
      return _getIt.get<SRV>(instanceName: name);
      // ignore: avoid_catching_errors
    } on Error {
      // GetIt throws an Error (not Exception) when a singleton is not yet
      // ready. This is documented behaviour in the GetIt API.
      throw ServiceNotReady(name, status: 'GetIt.I.get<> failed');
    }
  }
}
