// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart';

abstract class BaseServiceItemRegistry {
  FutureOr<void> registerTasks(ListOfServiceItems tasks);
  ListOfBlocProviders getblocProviders({required BlocProviderRequest forType});
  ListOfServiceItems getTasksOf({required BlocProviderRequest type});
  void validateTasks(ListOfServiceItems tasks);
}
