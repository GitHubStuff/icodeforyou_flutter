// ignore_for_file: public_member_api_docs

import 'package:my_logger/my_logger.dart' show MyLogger;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceDescriptorMode;

abstract class _ServiceStateManagerStateDetail {
  const _ServiceStateManagerStateDetail(this.name, this.status);
  final String name;
  final ServiceDescriptorMode status;
  @override
  String toString() => 'Name: "$name" Status: ${status.name}';
  void debugLog() {
    // ignore: prefer_asserts_with_message
    assert(() {
      MyLogger.d(toString());
      return true;
    }());
  }
}

//-
sealed class ServiceStateManagerState extends _ServiceStateManagerStateDetail {
  const ServiceStateManagerState(super.name, super.status);
}

//-
class ServicesManagerCataloged extends ServiceStateManagerState {
  ServicesManagerCataloged(String name) : super(name, .cataloged);
}

//-
class ServicesManagerReady extends ServiceStateManagerState {
  const ServicesManagerReady(String name) : super(name, .ready);
}

class ServicesManagerRegistered extends ServiceStateManagerState {
  const ServicesManagerRegistered(String name) : super(name, .registered);
}

class ServicesManagerRegistering extends ServiceStateManagerState {
  const ServicesManagerRegistering(String name) : super(name, .registering);
}

class ServicesManagerStarting extends ServiceStateManagerState {
  const ServicesManagerStarting(String name) : super(name, .starting);
}

class ServicesManagerWaiting extends ServiceStateManagerState {
  const ServicesManagerWaiting(String name) : super(name, .waiting);
}

//-
