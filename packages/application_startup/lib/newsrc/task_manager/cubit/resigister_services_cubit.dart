// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/task_manager/register_service_manager_abstract.dart'
    show RegisterServicesCubitAbstract;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:my_logger/my_logger.dart' show MyLogger;

abstract class RegisterSericesManagerCubit
    extends Cubit<AsyncTakeManagerState> {
  RegisterSericesManagerCubit({
    required RegisterServicesCubitAbstract manager,
  }) : _manager = manager,
       super(AsyncTakeManagerState.starting);

  final RegisterServicesCubitAbstract _manager;

  FutureOr<void> registerRootServices();

  void notify(AsyncTaskRunState runState, {required String taskName});
}

class DefaultRegisterServicesManagerCubit extends RegisterSericesManagerCubit {
  DefaultRegisterServicesManagerCubit({required super.manager});

  ListOfTaskType _waitingList = [];

  @override
  Future<void> registerRootServices() async {
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
}
