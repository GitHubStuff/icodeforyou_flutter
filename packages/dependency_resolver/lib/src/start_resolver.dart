import 'package:dependency_resolver/src/dependency_container.dart'
    show DependencyContainer;
import 'package:dependency_resolver/src/dependency_resolver.dart'
    show DependencyResolver;

/// Starts the resolver: registers [container] under the
/// [DependencyResolver] interface so downstream code resolves the
/// resolver itself without knowing the backend.
///
/// [container] is the one backend decision in the application — pass
/// `GetItDependencyResolver()` in production, any other
/// [DependencyContainer] to swizzle.
Future<void> startResolver(DependencyContainer container) async {
  container.registerSingleton<DependencyResolver>(container);
}
