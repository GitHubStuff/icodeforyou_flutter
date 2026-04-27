// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';
import 'package:service_locator/service_locator.dart'
    show GetItServiceLocator, ServiceLocatorRegistry;

export 'src/errors.dart';
export 'src/service_descriptor/service_descriptor.dart'
    show
        AsyncServiceDescriptor,
        LazyAsyncServiceDescriptor,
        ServiceClass,
        SyncServiceDescriptor;
export 'src/service_descriptor/service_descriptor.dart' show ServiceDescriptor;
export 'src/service_locator/getit_service_locator.dart'
    show GetItServiceLocator;
export 'src/service_registry/service_registry.dart' show ServiceLocatorRegistry;
export 'src/service_registry/service_registry_interfaces.dart'
    show ServiceRegistryInterface, ServiceResolver;

class ServiceRegistry {
  ServiceRegistry._();

  static ServiceLocatorRegistry get R {
    final getIt = GetIt.I;

    if (!getIt.isRegistered<ServiceLocatorRegistry>()) {
      getIt.registerSingleton<ServiceLocatorRegistry>(
        ServiceLocatorRegistry(locator: GetItServiceLocator()),
      );
    }

    return getIt.get<ServiceLocatorRegistry>();
  }
}
