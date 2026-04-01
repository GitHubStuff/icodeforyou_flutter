// ignore_for_file: public_member_api_docs

import 'dart:async' show FutureOr;

import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/service_item/base_service_item.dart';
import 'package:application_startup/newsrc/service_provider/base_service_provider.dart'
    show BaseServicesProvider;
import 'package:application_startup/newsrc/services_registery/base_service_item_registry.dart'
    show BaseServiceItemRegistry;

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;

abstract class BaseServicesRegistrar extends Cubit<AsyncTakeManagerState> {
  BaseServicesRegistrar({
    required this.provider,
    required this.registry,
  }) : super(AsyncTakeManagerState.starting);

  Future<bool> isServiceItemReady(BaseServiceItem serviceItem);
  final BaseServicesProvider provider;
  final BaseServiceItemRegistry registry;
  ListOfServiceItems getServiceItems({required List<String> forNameList});
  FutureOr<void> register({required BaseServiceItem serviceItem});
  FutureOr<void> registerRootServiceItems();
  void notifyState(AsyncTaskRunState state, {required BaseServiceItem of});
}
