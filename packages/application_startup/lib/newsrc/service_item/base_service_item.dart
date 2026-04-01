// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr, unawaited;

import 'package:application_startup/newsrc/common.dart'
    show AsyncTaskRunMode, ListOfServiceItems;
import 'package:application_startup/newsrc/service_provider/base_service_provider.dart'
    show BaseServicesProvider;
import 'package:application_startup/newsrc/services_registrar/base_services_registrar.dart'
    show BaseServicesRegistrar;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;
import 'package:get_it/get_it.dart' show WaitingTimeOutException;
import 'package:meta/meta.dart';

abstract class BaseServiceItem<T extends BlocBase<Object?>> {
  BaseServicesRegistrar get registrar;

  String get name;

  List<String> get dependencies => const <String>[];

  FutureOr<T> create();

  Duration get timeout;

  AsyncTaskRunMode get startupTaskRunMode;

  bool isRegistered();
  bool isReady();

  @nonVirtual
  bool isFor<S extends Object>() => <T>[] is List<S>;

  Future<void> _checkDependencies() async {
    final ListOfServiceItems dependenciesList = registrar.getServiceItems(
      forNameList: dependencies,
    );
    for (final BaseServiceItem serviceItem in dependenciesList) {
      if (!serviceItem.isRegistered()) {
        throw StateError('Dependency "${serviceItem.name}" is not registered');
      }

      try {
        await registrar.isServiceItemReady(serviceItem);
      } on WaitingTimeOutException catch (_) {
        throw StateError(
          'Dependency "${serviceItem.name}" did not become ready within '
          '${timeout.inMilliseconds} milliseconds.',
        );
      }
    }
  }

  @nonVirtual
  Future<void> registerUsing({
    required BaseServicesRegistrar registrar,
  }) async {
    if (isReady()) {
      registrar.notifyState(.alreadyRegisted, of: this);
      return;
    }
    registrar.notifyState(.registering, of: this);

    await _checkDependencies(registrar);

    unawaited(
      registrar.registerAsync<T>(serviceItem: this).then((_) {
        registrar.notifyState(.ready, of: this);
      }),
    );
  }

  @nonVirtual
  BlocProvider<BlocBase<Object?>> blocProvider() {
    if (isRegistered()) {
      throw StateError('Dependency "$name" is not registered. No BlocProvider');
    }
    if (!isReady()) {
      throw StateError('Task "$name" is not ready. No BlocProvider');
    }
    return BlocProvider<T>.value(
      value: registrar.registry.get(this, name),
    );
  }
}
