// application_startup/test/fakes/fake_service_registry.dart

// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/services/base_services_provider.dart'
    show BaseServicesProvider;

class FakeServiceRegistry implements BaseServicesProvider {
  final Map<String, Object> _instances = {};
  final Map<String, bool> _readySync = {};

  void seed<T extends Object>(
    String name,
    T instance, {
    bool readySync = true,
  }) {
    _instances[name] = instance;
    _readySync[name] = readySync;
  }

  @override
  bool isRegistered({required String serviceName}) =>
      _instances.containsKey(serviceName);

  @override
  bool isReady({required String serviceName}) =>
      _readySync[serviceName] ?? false;

  @override
  Future<void> isReadyAsync({
    required String instanceName,
    required Duration timeout,
  }) async {
    if (!_instances.containsKey(instanceName)) {
      throw StateError('FakeServiceRegistry: "$instanceName" not seeded.');
    }
  }

  @override
  Future<void> registerSingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    required String serviceName,
  }) async {
    _instances[serviceName] = await factory();
    _readySync[serviceName] = true;
  }

  @override
  T get<T extends Object>({required String serviceName}) {
    final instance = _instances[serviceName];
    if (instance == null) {
      throw StateError('FakeServiceRegistry: "$serviceName" not found.');
    }
    return instance as T;
  }
}
