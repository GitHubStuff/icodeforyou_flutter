// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart'
    show AsyncTaskRunState, ListOfServiceItems;
import 'package:application_startup/newsrc/service_item/base_service_item.dart'
    show BaseServiceItem;
import 'package:application_startup/newsrc/services_registrar/base_services_registrar.dart'
    show BaseServicesRegistrar;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase;
import 'package:my_logger/my_logger.dart' show MyLogger;

class DefaultServicesRegistrarCubit extends BaseServicesRegistrar {
  DefaultServicesRegistrarCubit({required super.manager});

  ListOfServiceItems _waitingList = [];

  @override
  Future<void> registerRootServiceItems() async {
    emit(.starting);
    _waitingList = _manager.getTasksOf(type: .root);
    await _manager.registerTasks(_waitingList);
  }

  @override
  void notify(AsyncTaskRunState runState, {required String taskName}) {
    switch (runState) {
      case .alreadyRegisted:

        // ignore: prefer_asserts_with_message
        assert(() {
          MyLogger.w('FYI: "$taskName" is already registed');
          return true;
        }());
        return;
      case .ready:
        _waitingList.removeWhere((task) => task.name == taskName);
        if (_waitingList.isEmpty) {
          emit(.ready);
        }
      case .registering:
        return;
    }
  }

  @override
  FutureOr<void> register({
    required BaseServiceItem<BlocBase<Object?>> serviceItem,
  }) {
    // TODO: implement register
    throw UnimplementedError();
  }
}
