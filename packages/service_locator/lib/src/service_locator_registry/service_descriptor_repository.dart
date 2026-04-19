// ignore_for_file: public_member_api_docs

import 'package:service_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotRegistered;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart';

abstract interface class ServiceLocatorDescriptorRepository {
  void acquire<SRV extends ServiceClass, SD extends ServiceDescriptor<SRV>>(
    SD serviceDescriptor,
  );

  SD
  getDescriptor<SRV extends ServiceClass, SD extends ServiceDescriptor<SRV>>();
}

class DescriptorMapRepo<SRP extends ServiceClass>
    implements ServiceLocatorDescriptorRepository {
  final Map<String, ServiceDescriptor> _repo = {};

  @override
  void acquire<SRV extends ServiceClass, SD extends ServiceDescriptor<SRV>>(
    SD descriptor,
  ) {
    final name = descriptor.name;
    if (_repo[name] != null) throw DuplicateServiceEntry(name);

    descriptor.mode = .waiting;
    _repo[name] = descriptor;
  }

  @override
  SD
  getDescriptor<SRV extends ServiceClass, SD extends ServiceDescriptor<SRV>>() {
    final name = '$SRV';
    final descriptor = _repo[name];
    if (descriptor == null) throw ServiceNotRegistered(name);
    return descriptor as SD;
  }
}
