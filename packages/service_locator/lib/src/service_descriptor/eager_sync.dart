// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, ServiceDescriptor, ServiceDescriptorRegisterType;

abstract class EagerSync<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  SRV get instance;
  @override
  final ServiceDescriptorRegisterType registerType = .eagerSync;

  @override
  String toString() => '${super.toString()} instance: $instance';
}
