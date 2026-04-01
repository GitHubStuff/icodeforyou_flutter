// ignore_for_file: public_member_api_docs

abstract class BaseServicesProvider {
  bool isRegistered({required String serviceName});
  bool isReady({required String serviceName});
  Future<void> isReadyAsync({
    required String instanceName,
    required Duration timeout,
  });
  void registerSingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    required String serviceName,
  });
  T get<T extends Object>({required String serviceItem});
}
