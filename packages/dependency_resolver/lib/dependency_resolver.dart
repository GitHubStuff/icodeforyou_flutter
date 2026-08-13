// packages/dependency_resolver/lib/dependency_resolver.dart

/// DIP-compliant abstraction over dependency registration and
/// resolution.
library;

export 'src/dependency_container.dart' show DependencyContainer;
export 'src/dependency_registrar.dart' show DependencyRegistrar;
export 'src/dependency_resolver.dart' show DependencyResolver;
export 'src/get_it_dependency_resolver.dart' show GetItDependencyResolver;
export 'src/in_memory_dependency_resolver.dart' show InMemoryDependencyResolver;
export 'src/start_resolver.dart' show startResolver;
