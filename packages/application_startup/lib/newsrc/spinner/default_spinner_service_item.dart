// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/service_item/base_service_item.dart'
    show BaseServiceItem;
import 'package:application_startup/newsrc/service_provider/base_service_provider.dart'
    show BaseServicesProvider;
import 'package:application_startup/newsrc/services_registrar/base_services_registrar.dart'
    show BaseServicesRegistrar;
import 'package:application_startup/newsrc/spinner/spinner_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;
import 'package:get_it/get_it.dart' show WaitingTimeOutException;

final class DefaultSpinnerServiceItem extends BaseServiceItem {
  DefaultSpinnerServiceItem({
    required BaseServicesProvider provider,
    required BaseServicesRegistrar registrar,
  }) : _provider = provider,
       _registrar = registrar;

  final BaseServicesProvider _provider;
  final BaseServicesRegistrar _registrar;

  @override
  FutureOr<BlocBase<Object?>> create() => SpinnerCubit();

  @override
  String get name => 'DefaultSpinnerTask';

  @override
  AsyncTaskRunMode get startupTaskRunMode => AsyncTaskRunMode.root;

  @override
  Duration get timeout => const Duration(milliseconds: 250);

  @override
  bool inRegistry() => _provider.isServiceRegistered(serviceItem: this);

  @override
  bool isServiceReady() => _provider.isServiceReady(serviceItem: this);

  @override
  Future<void> checkDependencies() async {
    final ListOfServiceItems dependenciesList = _registrar.getServiceItems(
      forNameList: dependencies,
    );
    for (final BaseServiceItem serviceItem in dependenciesList) {
      if (!serviceItem.inRegistry()) {
        throw StateError('Dependency "${serviceItem.name}" is not registered');
      }

      try {
        await _provider.isServiceReadyAsync(serviceItem: serviceItem);
      } on WaitingTimeOutException catch (_) {
        throw StateError(
          'Dependency "${serviceItem.name}" did not become ready within '
          '${timeout.inMilliseconds} milliseconds.',
        );
      }
    }
  }

  @override
  Future<void> registerAsService() async {
    if (isServiceReady()) {
      _registrar.notifyState(.alreadyRegisted, of: this);
      return;
    }
    _registrar.notifyState(.registering, of: this);

    await checkDependencies();

    unawaited(
      _registrar.register(this).then((_) {
        _registrar.notifyState(.ready, of: this);
      }),
    );
  }

  @override
  BlocProvider<BlocBase<Object?>> getBlocProvider() {
    if (inRegistry()) {
      throw StateError('Dependency "$name" is not registered. No BlocProvider');
    }
    if (!isServiceReady()) {
      throw StateError('Task "$name" is not ready. No BlocProvider');
    }

    return BlocProvider.value(
      value: _provider.getBlocOf(this),
    );
  }
}
