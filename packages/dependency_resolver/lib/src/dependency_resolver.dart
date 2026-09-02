// packages/dependency_resolver/lib/src/dependency_resolver.dart

/// Abstraction over dependency resolution.
///
/// Consumers depend on this interface instead of any concrete backend,
/// satisfying the Dependency Inversion Principle and making resolution
/// mockable in tests.
///
/// Deliberately segregated to resolution only, per the Interface
/// Segregation Principle. Registration lives on the write-side
/// counterpart `DependencyRegistrar`; composition-root code holds both
/// roles through `DependencyContainer`.
abstract interface class DependencyResolver {
  /// Resolves the registered instance of [T].
  ///
  /// Provide [instanceName] when the registration was made as a named
  /// instance.
  T get<T extends Object>({String? instanceName});

  /// Returns `true` when a registration exists for [T].
  ///
  /// Provide [instanceName] to query a named registration.
  bool isRegistered<T extends Object>({String? instanceName});
}
