// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:service_locator/src/service_state_manager/service_state_manager_state.dart'
    show ServiceStateManagerState;

typedef ReportServiceState = void Function(ServiceStateManagerState state);

// ignore: one_member_abstracts
abstract interface class ServiceStateManager {
  void broadcast(ServiceStateManagerState state);
}
