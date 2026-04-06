// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/service_provider/base_service_provider.dart';
import 'package:application_startup/newsrc/services_registery/registery.dart'
    show Registery;
import 'package:flutter/foundation.dart';

abstract class BaseServiceItem<SRV extends Object> {
  BaseServiceItem({
    required this.name,
    required BaseServiceProvider usingProvider,
  }) : provider = usingProvider {
    Registery.addItem(name, this);
    usingProvider.registerLazySingletonAsync<SRV>(name, create);
  }

  final String name;

  final BaseServiceProvider provider;

  Duration? get timeout;

  Future<SRV> create();

  List<String> get dependencies;

  @nonVirtual
  bool isReadySync() => provider.isReadySync<SRV>(name);

  @nonVirtual
  Future<bool> isReadyAsync() =>
      provider.isReadyAsync<SRV>(name, timeout: timeout);

  @nonVirtual
  SRV get service => provider.getService<SRV>(name);

  @nonVirtual
  Future<void> start() async {
    if (isReadySync()) return;
    await Future.wait(
      dependencies.map((dependency) async {
        final BaseServiceItem serviceItem = Registery.getItem(dependency);
        if (!serviceItem.isReadySync()) {
          await serviceItem.start();
          await serviceItem.isReadyAsync();
        }
      }),
    );
    service;
    await isReadyAsync();
  }
}
