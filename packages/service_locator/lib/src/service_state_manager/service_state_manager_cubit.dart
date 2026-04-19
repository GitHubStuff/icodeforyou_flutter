// ignore_for_file: public_member_api_docs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/src/service_state_manager/service_state_manager.dart'
    show ServiceStateManager;

import 'package:service_locator/src/service_state_manager/service_state_manager_state.dart'
    show ServiceStateManagerState, ServicesManagerWaiting;

class ServicesStateManagerCubit extends Cubit<ServiceStateManagerState>
    implements ServiceStateManager {
  ServicesStateManagerCubit() : super(const ServicesManagerWaiting('Cubit'));

  @override
  void broadcast(ServiceStateManagerState state) => emit(state);
}
