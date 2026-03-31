// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/spinner/spinner_cubit.dart';
import 'package:application_startup/newsrc/startup_task/base_service_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase;

class DefaultSpinnerTask extends BaseServiceItem {
  DefaultSpinnerTask({
    required super.serviceDispatcher,
    required super.registrar,
  });

  @override
  FutureOr<BlocBase<Object?>> create() => SpinnerCubit();

  @override
  String get name => 'DefaultSpinnerTask';

  @override
  AsyncTaskRunMode get startupTaskRunMode => AsyncTaskRunMode.root;

  @override
  Duration get timeout => const Duration(milliseconds: 250);
}
