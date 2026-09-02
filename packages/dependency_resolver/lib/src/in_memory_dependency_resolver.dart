// packages/dependency_resolver/lib/src/in_memory_dependency_resolver.dart
import 'package:dependency_resolver/src/dependency_container.dart';
import 'package:meta/meta.dart' show immutable;

/// In-memory [DependencyContainer] with no backend dependency.
///
/// A working fake (not a mock): registrations and resolutions behave
/// like the production container, backed by a `Map` keyed on
/// `(type, instanceName)`. Use it in tests to exercise real
/// register-then-resolve flows without `get_it`'s global state, or as
/// the swizzle target proving startup code depends only on the
/// interfaces.
///
/// Mirrors production semantics: duplicate registrations throw
/// [ArgumentError]; resolving an unregistered entry throws
/// [StateError]; lazy singletons build once on first resolution and
/// cache thereafter.
@immutable
final class InMemoryDependencyResolver implements DependencyContainer {
  final Map<_RegistrationKey, Object> _instances = {};
  final Map<_RegistrationKey, Object Function()> _pending = {};

  @override
  T get<T extends Object>({String? instanceName}) {
    final key = _RegistrationKey(T, instanceName);
    final existing = _instances[key];
    if (existing != null) return existing as T;

    final create = _pending.remove(key);
    if (create == null) throw StateError('No registration for $key.');

    final instance = create() as T;
    _instances[key] = instance;
    return instance;
  }

  @override
  bool isRegistered<T extends Object>({String? instanceName}) {
    final key = _RegistrationKey(T, instanceName);
    return _instances.containsKey(key) || _pending.containsKey(key);
  }

  @override
  T registerSingleton<T extends Object>(T instance, {String? instanceName}) {
    _instances[_claimKey<T>(instanceName)] = instance;
    return instance;
  }

  @override
  void registerLazySingleton<T extends Object>(
    T Function() create, {
    String? instanceName,
  }) {
    _pending[_claimKey<T>(instanceName)] = create;
  }

  /// Removes every registration, restoring the container to empty.
  ///
  /// Test hook for reuse across cases; production containers have no
  /// equivalent on the interfaces and never need one.
  void reset() {
    _instances.clear();
    _pending.clear();
  }

  /// Returns the key for `(T, instanceName)`, throwing [ArgumentError]
  /// if it is already claimed by any registration.
  _RegistrationKey _claimKey<T extends Object>(String? instanceName) {
    final key = _RegistrationKey(T, instanceName);
    if (_instances.containsKey(key) || _pending.containsKey(key)) {
      throw ArgumentError('Duplicate registration for $key.');
    }
    return key;
  }
}

/// Value key identifying a registration by type and optional name.
@immutable
final class _RegistrationKey {
  const _RegistrationKey(this.type, this.instanceName);

  final Type type;
  final String? instanceName;

  @override
  bool operator ==(Object other) =>
      other is _RegistrationKey &&
      other.type == type &&
      other.instanceName == instanceName;

  @override
  int get hashCode => Object.hash(type, instanceName);

  @override
  String toString() =>
      'type $type${instanceName == null ? '' : ' (name "$instanceName")'}';
}
