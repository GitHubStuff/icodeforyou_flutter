// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_state_manager/service_state_manager.dart'
    show ReportServiceState;

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
    required Future<SRV> Function() factory,
    required ReportServiceState serviceState,
  });

  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  });

  //+ START
  Future<SRV> startServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  });
}
