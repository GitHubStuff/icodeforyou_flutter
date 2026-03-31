// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart';

abstract class RegisterServicesCubitAbstract {
  FutureOr<void> registerTasks(ListOfTaskType tasks);
  ListOfBlocProviders getblocProviders({required BlocProviderRequest forType});
  ListOfTaskType getTasksOf({required BlocProviderRequest type});
  void validateTasks(ListOfTaskType tasks);
}
