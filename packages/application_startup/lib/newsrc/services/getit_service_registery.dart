// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/services/base_services_provider.dart'
    show BaseServicesProvider;
import 'package:get_it/get_it.dart' show GetIt;

class GetItServiceRegistry implements BaseServicesProvider {
  const GetItServiceRegistry();

  @override
  bool isRegistered({required String serviceName}) =>
      GetIt.I.isRegistered(instanceName: serviceName);

  @override
  bool isReady({required String serviceName}) =>
      GetIt.I.isReadySync(instanceName: serviceName);

  @override
  Future<void> isReadyAsync({
    required String instanceName,
    required Duration timeout,
  }) => GetIt.I.isReady(instanceName: instanceName, timeout: timeout);

  @override
  void registerSingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    required String serviceName,
  }) => GetIt.I.registerSingletonAsync<T>(factory, instanceName: serviceName);

  @override
  T get<T extends Object>({required String serviceName}) =>
      GetIt.I.get<T>(instanceName: serviceName);
}
