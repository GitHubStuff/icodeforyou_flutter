// ignore_for_file: public_member_api_docs

import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;

typedef ReportServiceState =
    void Function(
      LocatorStatus status, {
      Object? instance,
    });

abstract interface class ServiceLocator {
  //+ GET
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  });

  SRV getServiceSync<SRV extends ServiceClass>({required String name});

  //+ REGISTER
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  });

  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  });
}
