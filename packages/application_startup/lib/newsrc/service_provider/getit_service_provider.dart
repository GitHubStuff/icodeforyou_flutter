// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/errors/errors.dart'
    show ServiceItemTimeout;
import 'package:application_startup/newsrc/service_item/service_items.dart';
import 'package:application_startup/newsrc/service_provider/base_service_provider.dart'
    show BaseServiceProvider;
import 'package:application_startup/newsrc/services_registery/registery.dart';
import 'package:get_it/get_it.dart' show GetIt;

class GetItServiceProvider implements BaseServiceProvider {
  const GetItServiceProvider();

  @override
  Future<bool> isReadyAsync({
    required BaseServiceItem<Object> serviceItem,
  }) async {
    await GetIt.I
        .isReady(
          instanceName: serviceItem.name,
          timeout: serviceItem.timeout,
        )
        .catchError((_) {
          throw ServiceItemTimeout(serviceItem.name, serviceItem.timeout);
        });
    return true;
  }

  @override
  bool isReadySync({required BaseServiceItem<Object> serviceItem}) =>
      GetIt.I.isReadySync(instanceName: serviceItem.name);

  @override
  String get name => 'GetIt';

  @override
  Future<void> registerSingleton<S extends Object>({
    required BaseServiceItem<Object> serviceItem,
  }) async {
    GetIt.I.get<S>(instanceName: serviceItem.name);
    GetIt.I.registerSingleton(
      await serviceItem.create(),
      instanceName: serviceItem.name,
      signalsReady: true,
    );
    GetIt.I.registerSingletonAsync(
      serviceItem.create,
      instanceName: serviceItem.name,
      signalsReady: true,
    );
    GetIt.I.registerLazySingleton(
      serviceItem.create,
      instanceName: serviceItem.name,
    );
    GetIt.I.registerLazySingletonAsync(
      serviceItem.create,
      instanceName: serviceItem.name,
    );
  }

  @override
  Object getService({required BaseServiceItem<Object> serviceIteme}) {
    // TODO: implement getService
    throw UnimplementedError();
  }
}
