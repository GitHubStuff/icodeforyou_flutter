// ignore_for_file: public_member_api_docs

// import 'package:get_it/get_it.dart';
// import 'package:service_locator/service_locator.dart'
//     show ServicesStateManagerCubit;
// import 'package:service_locator/src/service_locator_registry/service_descriptor_repository.dart'
//     show DescriptorMapRepo;
// import 'package:service_locator/src/service_locator_registry/service_locator_registry.dart'
//     show ServiceLocatorRegistry;

import 'package:get_it/get_it.dart';
import 'package:service_locator/src/service_locator_registry/service_descriptor_repository.dart'
    show DescriptorMapRepo;
import 'package:service_locator/src/service_locator_registry/service_locator_registry.dart'
    show ServiceLocatorRegistry;
import 'package:service_locator/src/service_state_manager/service_state_manager_cubit.dart'
    show ServicesStateManagerCubit;

export 'package:service_locator/src/service_descriptor/eager_sync.dart';
export 'package:service_locator/src/service_descriptor/lazy_async.dart';
export 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
export 'package:service_locator/src/service_locator_registry/service_locator_registry.dart'
    show Registry;
export 'package:service_locator/src/service_state_manager/service_state_manager_cubit.dart'
    show ServicesStateManagerCubit;

class SetUp {
  static ServicesStateManagerCubit serviceLocatorSetup() {
    GetIt.I.registerSingleton<ServicesStateManagerCubit>(
      ServicesStateManagerCubit(),
    );

    GetIt.I.registerSingleton<ServiceLocatorRegistry>(
      ServiceLocatorRegistry(
        serviceStateManager: GetIt.I.get<ServicesStateManagerCubit>(),
        descriptorRepository: DescriptorMapRepo(),
      ),
    );

    return GetIt.I.get<ServicesStateManagerCubit>();
  }
}
