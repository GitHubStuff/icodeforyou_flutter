// packages/services_provider/lib/src/get_it_services_provider.dart
import 'package:get_it/get_it.dart';
import 'package:services_provider/src/service_provider.dart'
    show ServiceProvider;

/// A [ServiceProvider] implementation backed by the [GetIt] service
/// locator.
///
/// This class is a thin adapter: every member delegates directly to the
/// global [GetIt.instance] without adding behaviour, caching, or error
/// handling of its own. Its purpose is to let application and feature code
/// depend on the [ServiceProvider] abstraction rather than on `get_it`
/// itself, so that the concrete locator can be swapped (for example with an
/// in-memory fake in tests) without touching consumers.
///
/// Because [GetIt.instance] is a process-wide singleton, all
/// [GetItServiceProvider] instances share the same underlying registry.
/// Creating several instances does **not** create isolated containers;
/// registrations made through one instance are visible through every other
/// instance and through any direct use of `GetIt.instance`.
///
/// ## Lifecycle and registration rules
///
/// * Services are registered with [registerLazySingleton]. The factory is
///   invoked at most once, on the first call to [get] for that type, and the
///   resulting object is cached for the lifetime of the container.
/// * Registering the same type twice throws an [ArgumentError] from `get_it`
///   (unless `allowReassignment` has been enabled on the global instance).
///   Use [isRegistered] to guard against duplicate registration.
/// * Resolving an unregistered type via [get] throws a [StateError]
///   (surfaced from `get_it`); it does not return `null`.
/// * Resetting the registry (for example between tests) must be done through
///   `GetIt.instance.reset()`, as this adapter deliberately exposes no reset
///   API.
///
/// ## Example
///
/// ```dart
/// final ServiceProvider services = GetItServiceProvider();
///
/// if (!services.isRegistered<Clock>()) {
///   services.registerLazySingleton<Clock>(SystemClock.new);
/// }
///
/// final clock = services.get<Clock>();
/// ```
///
/// See also:
///
/// * [ServicesProvider], the abstraction this class implements.
/// * [GetIt], the underlying service locator.
class GetItServiceProvider implements ServiceProvider {
  /// Creates a provider that delegates to the global [GetIt.instance].
  ///
  /// The constructor takes no arguments and performs no registration; the
  /// container is empty until [registerLazySingleton] is called (or until
  /// something else registers services directly on `GetIt.instance`).
  GetItServiceProvider();

  /// The shared [GetIt] container that all operations are forwarded to.
  ///
  /// This is always [GetIt.instance]; the field exists only to keep the
  /// delegation explicit and to avoid repeating the global lookup in every
  /// member.
  final GetIt _getIt = GetIt.instance;

  /// Resolves and returns the registered service of type [T].
  ///
  /// For a type registered with [registerLazySingleton], the first call
  /// invokes the stored factory and caches the result; subsequent calls
  /// return the same cached instance.
  ///
  /// Throws a [StateError] (from `get_it`) if no service of type [T] has been
  /// registered. Use [isRegistered] beforehand if the type may be absent.
  ///
  /// [T] must be the exact type used at registration time; `get_it` does not
  /// resolve by subtype or interface unless the service was registered under
  /// that interface.
  @override
  T get<T extends Object>() => _getIt<T>();

  /// Returns whether a service of type [T] is currently registered.
  ///
  /// This checks registration only; it does not report whether a lazy
  /// singleton's factory has already been invoked. A registered but
  /// not-yet-created lazy singleton still returns `true`.
  ///
  /// Typically used to guard [registerLazySingleton] against the
  /// [ArgumentError] that `get_it` throws on duplicate registration.
  @override
  bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();

  /// Registers [factory] as a lazy singleton for type [T].
  ///
  /// [factory] is not invoked here. It is called exactly once, on the first
  /// [get] for [T], and the object it returns is cached for the lifetime of
  /// the container.
  ///
  /// Throws an [ArgumentError] (from `get_it`) if a service of type [T] is
  /// already registered and reassignment has not been enabled on the global
  /// [GetIt] instance. Call [isRegistered] first if registration may be
  /// repeated (for example in hot-restart or test setup paths).
  ///
  /// The registration is global: it is visible to every
  /// [GetItServiceProvider] and to any direct use of `GetIt.instance`.
  @override
  void registerLazySingleton<T extends Object>(T Function() factory) =>
      _getIt.registerLazySingleton<T>(factory);
}
