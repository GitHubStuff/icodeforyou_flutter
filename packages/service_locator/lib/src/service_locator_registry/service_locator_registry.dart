// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart' show GetIt;
import 'package:service_locator/src/service_locator_registry/service_descriptor_repository.dart';
import 'package:service_locator/src/service_state_manager/service_state_manager.dart'
    show ServiceStateManager;

/// A short name for the register for 'Registry.R.'
typedef Registry = ServiceLocatorRegistry;

final class ServiceLocatorRegistry {
  const ServiceLocatorRegistry({
    required ServiceStateManager serviceStateManager,
    required DescriptorMapRepo descriptorRepository,
  }) : _stateManager = serviceStateManager,
       _repo = descriptorRepository;

  static ServiceLocatorRegistry get R => GetIt.I.get<ServiceLocatorRegistry>();

  final DescriptorMapRepo _repo;
  final ServiceStateManager _stateManager;
}
