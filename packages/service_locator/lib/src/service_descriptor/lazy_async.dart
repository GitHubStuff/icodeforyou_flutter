// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, ServiceDescriptor, ServiceDescriptorRegisterType;

abstract class LazyAsync<SRV extends ServiceClass>
    extends ServiceDescriptor<SRV> {
  @override
  final ServiceDescriptorRegisterType registerType = .lazyAsync;

  Future<SRV> Function() get factory;

  @override
  String toString() => '${super.toString()} factory: $factory';
}
