// packages/dependency_resolver/lib/src/get_it_dependency_resolver.dart

import 'package:dependency_resolver/src/dependency_container.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart' show immutable;

/// Production [DependencyContainer] backed by [GetIt].
///
/// Delegates every registration and resolution to the wrapped [GetIt]
/// instance. One concrete backend among possibly many — startup code
/// depends on the interfaces, so swapping this class for another
/// container implementation touches only the call site that constructs
/// it.
@immutable
final class GetItDependencyResolver implements DependencyContainer {
  /// Creates a container delegating to [getIt].
  ///
  /// Defaults to [GetIt.instance] so production construction requires no
  /// arguments. Inject a scoped instance (for example
  /// `GetIt.asNewInstance()`) for integration tests that exercise real
  /// registrations in isolation.
  GetItDependencyResolver({GetIt? getIt}) : _getIt = getIt ?? GetIt.instance;

  final GetIt _getIt;

  @override
  T get<T extends Object>({String? instanceName}) =>
      _getIt.get<T>(instanceName: instanceName);

  @override
  bool isRegistered<T extends Object>({String? instanceName}) =>
      _getIt.isRegistered<T>(instanceName: instanceName);

  @override
  T registerSingleton<T extends Object>(T instance, {String? instanceName}) =>
      _getIt.registerSingleton<T>(instance, instanceName: instanceName);

  @override
  void registerLazySingleton<T extends Object>(
    T Function() create, {
    String? instanceName,
  }) => _getIt.registerLazySingleton<T>(create, instanceName: instanceName);
}
