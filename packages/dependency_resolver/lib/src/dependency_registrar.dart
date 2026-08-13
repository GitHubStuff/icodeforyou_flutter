// packages/dependency_resolver/lib/src/dependency_registrar.dart

/// Abstraction over dependency registration.
///
/// The write-side counterpart to `DependencyResolver`, split per the
/// Interface Segregation Principle: startup code registers, consumers
/// resolve, and neither can do the other's job. Backed by any concrete
/// container — swap the implementation to swizzle backends without
/// touching startup code.
abstract interface class DependencyRegistrar {
  /// Registers [instance] as the singleton for [T] and returns it
  /// unchanged so call sites can chain into further wiring.
  ///
  /// Provide [instanceName] to register a named instance alongside an
  /// unnamed one of the same type.
  T registerSingleton<T extends Object>(T instance, {String? instanceName});

  /// Registers [create] as a lazy singleton for [T].
  ///
  /// [create] runs on the first resolution of [T]; the result is cached
  /// for every subsequent resolution. Provide [instanceName] to
  /// register a named instance.
  void registerLazySingleton<T extends Object>(
    T Function() create, {
    String? instanceName,
  });
}
