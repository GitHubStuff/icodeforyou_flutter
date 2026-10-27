// packages/services_provider/lib/src/service_provider.dart

/// Contract for a service container.
///
/// Kept to the operations this package needs so that mocks and
/// alternative containers stay trivial to implement.
abstract interface class ServiceProvider {
  /// Resolves the registered instance of [T].
  T get<T extends Object>();

  /// Whether an instance or factory for [T] has been registered.
  bool isRegistered<T extends Object>();

  /// Registers [factory] to create a single instance of [T] on first use.
  void registerLazySingleton<T extends Object>(T Function() factory);
}
