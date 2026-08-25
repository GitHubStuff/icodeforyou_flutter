// packages/service_locator/lib/service_locator.dart
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

/// A global accessor for the default [ServiceLocatorRegistry] instance.
///
/// This class serves as the primary entry point to access the shared registry
/// using lazy initialization backed by [GetIt].
class ServiceRegistry {
  ServiceRegistry._(); // coverage:ignore-line

  /// Returns the singleton instance of [ServiceLocatorRegistry].
  ///
  /// Lazily initializes and registers a new [ServiceLocatorRegistry] configured
  /// with a [GetItServiceLocator] into [GetIt] if one does not already exist.
  ///
  /// ```dart
  /// // Register a service descriptor
  /// ServiceRegistry.R.register(myServiceDescriptor);
  ///
  /// // Resolve a dependency
  /// final myService = ServiceRegistry.R.get<MyService>();
  /// ```
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
