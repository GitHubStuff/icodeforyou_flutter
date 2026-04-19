// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';
import 'package:service_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotReady, ServiceNotRegistered;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_locator/service_locator.dart'
    show ServiceLocator;
import 'package:service_locator/src/service_state_manager/service_state_manager.dart'
    show ReportServiceState;
import 'package:service_locator/src/service_state_manager/service_state_manager_state.dart'
    show ServicesManagerRegistered, ServicesManagerRegistering;

class GetItServiceLocator implements ServiceLocator {
  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  const GetItServiceLocator();

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    _assertRegistered<SRV>(name);
    await GetIt.I.isReady<SRV>(instanceName: name, timeout: timeout);
    return GetIt.I.get<SRV>(instanceName: name);
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
    required Future<SRV> Function() factory,
    required ReportServiceState serviceState,
  }) {
    if (GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }

    GetIt.I.registerLazySingletonAsync<SRV>(
      factory,
      instanceName: name,
      onCreated: (service) {
        serviceState(ServicesManagerRegistered(name));
      },
    );
    serviceState(ServicesManagerRegistering(name));
    _assertRegistered<SRV>(name);
  }

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    if (GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }

    return GetIt.I.registerSingleton<SRV>(
      instance,
      instanceName: name,
      signalsReady: true,
    );
  }

  //+
  @override
  Future<SRV> startServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) {
    _assertRegistered<SRV>(name);
    return GetIt.I.getAsync<SRV>(instanceName: name).timeout(timeout);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _assertRegistered<SRV extends ServiceClass>(String name) {
    if (GetIt.I.isRegistered<SRV>(instanceName: name)) return;
    throw ServiceNotRegistered(name);
  }

  SRV _getOrThrowNotReady<SRV extends ServiceClass>(String name) {
    try {
      return GetIt.I.get<SRV>(instanceName: name);
      // ignore: avoid_catching_errors
    } on Error {
      // GetIt throws an Error (not Exception) when a singleton is not yet ready.
      // This is documented behaviour in the GetIt API.
      throw ServiceNotReady(name);
    }
  }
}
