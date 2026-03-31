// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/startup_task/base_service_item.dart';
import 'package:application_startup/newsrc/task_manager/cubit/resigister_services_cubit.dart'
    show DefaultRegisterServicesManagerCubit;
import 'package:application_startup/newsrc/task_manager/default_register_services_manager.dart'
    show DefaultRegisterServicesManager;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase;

class DefaultTaskManagerTask extends BaseServiceItem {
  DefaultTaskManagerTask({
    required super.serviceDispatcher,
    required super.registrar,
    required ListOfTaskType taskList,
  }) : _taskList = taskList;

  final ListOfTaskType _taskList;

  @override
  FutureOr<BlocBase<Object?>> create() => DefaultRegisterServicesManagerCubit(
    manager: DefaultRegisterServicesManager(_taskList),
  );

  @override
  String get name => 'DefaultSpinnerTask';

  @override
  AsyncTaskRunMode get startupTaskRunMode => AsyncTaskRunMode.root;

  @override
  Duration get timeout => const Duration(milliseconds: 250);
}
