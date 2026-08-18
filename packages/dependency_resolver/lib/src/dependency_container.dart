// packages/dependency_resolver/lib/src/dependency_container.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyRegistrar, DependencyResolver;

/// A full dependency container: resolves and registers.
///
/// Held only by composition-root code — the one place allowed both
/// roles. Everything downstream takes the narrower `DependencyResolver`
/// or `DependencyRegistrar`, keeping read and write authority separate
/// per the Interface Segregation Principle.
abstract interface class DependencyContainer
    implements DependencyRegistrar, DependencyResolver {}
