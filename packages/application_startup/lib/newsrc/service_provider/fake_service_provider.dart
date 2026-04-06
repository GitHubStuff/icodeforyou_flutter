// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/errors/errors.dart'
    show ServiceItemTimeout;
import 'package:application_startup/newsrc/service_provider/base_service_provider.dart'
    show BaseServiceProvider;
import 'package:application_startup/newsrc/services_registery/registery.dart';

class FakeServicesProvider implements BaseServiceProvider {
  final Map<String, Object> _instances = {};
  final Map<String, bool> _readySync = {};
  final Map<String, bool> _timedOut = {};

  void seed<T extends Object>(
    String name,
    T instance, {
    bool readySync = false,
    bool timedOut = false,
  }) {
    _instances[name] = instance;
    _readySync[name] = readySync;
    _timedOut[name] = timedOut;
  }

  @override
  Future<bool> isReadyAsync({required BaseServiceItem serviceItem}) async {
    return Future.delayed(serviceItem.timeout, () {
      final timedOut = _timedOut[serviceItem.name]!;
      if (timedOut) {
        throw ServiceItemTimeout(serviceItem.name, serviceItem.timeout);
      }
      _readySync[serviceItem.name] = timedOut;
      return timedOut;
    });
  }

  @override
  bool isReadySync({required BaseServiceItem<Object> serviceItem}) =>
      _readySync[serviceItem.name] ?? false;

  @override
  String get name => 'FakeServiceProvider';

  @override
  Future<void> registerSingleton({
    required BaseServiceItem<Object> serviceItem,
  }) async {
    _instances[serviceItem.name] = await serviceItem.create();
    _readySync[serviceItem.name] = true;
  }
}
