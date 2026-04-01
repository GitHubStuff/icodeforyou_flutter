// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/service_item/base_service_item.dart';
import 'package:application_startup/newsrc/services_registrar/base_services_registrar.dart'
    show DefaultServicesRegistrarCubit;
import 'package:application_startup/newsrc/services_registrar/default_register_services_manager.dart'
    show DefaultRegisterServicesManager;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase;

class DefaultTaskManagerTask extends BaseServiceItem {
  DefaultTaskManagerTask({
    required ListOfServiceItems taskList,
  }) : _taskList = taskList;

  final ListOfServiceItems _taskList;

  @override
  FutureOr<BlocBase<Object?>> create() => DefaultServicesRegistrarCubit(
    manager: DefaultRegisterServicesManager(_taskList),
  );

  @override
  String get name => 'DefaultSpinnerTask';

  @override
  AsyncTaskRunMode get startupTaskRunMode => AsyncTaskRunMode.root;

  @override
  Duration get timeout => const Duration(milliseconds: 250);
}
