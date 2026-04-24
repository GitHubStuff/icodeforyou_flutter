// ignore_for_file: public_member_api_docs

import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

abstract interface class ServiceClass {}

sealed class ServiceDescriptor<SRV extends ServiceClass> {
  const ServiceDescriptor();

  String get name;
  List<Type> get dependencies => const [];
  Duration get timeout => const Duration(seconds: 30);

  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  });

  @override
  String toString() =>
      'ServiceDescriptor(name: "$name", deps: $dependencies, '
      'timeout: ${timeout.inSeconds}s)';
}

abstract class SyncServiceDescriptor<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  const SyncServiceDescriptor();

  SRV Function() get builder;

  @override
  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  }) {
    final instance = builder();
    locator.registerServiceSync<SRV>(name: name, instance: instance);
    serviceState(LocatorStatus.ready, instance: instance);
  }
}

abstract class LazyAsyncServiceDescriptor<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  const LazyAsyncServiceDescriptor();

  Future<SRV> Function() get builder;

  @override
  void registerWith(
    ServiceLocator locator, {
    required ReportServiceState serviceState,
  }) {
    locator.registerServiceLazyAsync<SRV>(
      name: name,
      builder: builder,
      serviceState: serviceState,
    );
  }
}
