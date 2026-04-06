// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/service_item/service_items.dart';

abstract class BaseServiceProvider<T extends Object> {
  String get name;
  Future<bool> isReadyAsync<SRV>(
    String name, {
    Duration? timeout,
  });
  bool isReadySync<SRV>(String name);
  SRV getService<SRV>(String name);
  void registerLazySingletonAsync<SRV>(
    String name,
    Future<SRV> Function() function,
  );
  void registerLazySingletonSync<SRV>(
    String name,
    Future<SRV> Function() function,
  );
  void registerSingleton({required BaseServiceItem serviceItem});
}
