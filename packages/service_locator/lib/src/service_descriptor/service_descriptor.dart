// ignore_for_file: public_member_api_docs

enum ServiceDescriptorRegisterType { lazyAsync, eagerSync }

enum ServiceDescriptorMode {
  cataloged,
  ready,
  registered,
  registering,
  starting,
  waiting,

  // ServicesManagerState toState(String name) => switch (this) {
  //   cataloged => ServicesManagerCataloged(name),
  //   ready => ServicesManagerReady(name),
  //   registered => ServicesManagerRegistered(name),
  //   registering => ServicesManagerRegistering(name),
  //   starting => ServicesManagerStarting(name),
  //   waiting => ServicesManagerWaiting(name),
  // };
}

abstract interface class ServiceClass {}

abstract class ServiceDescriptor<SRV extends ServiceClass> {
  final String name = '$SRV';

  List<String> get dependencies => [];

  ServiceDescriptorMode mode = .waiting;

  ServiceDescriptorRegisterType get registerType;

  @override
  String toString() =>
      'Name: $name {$SRV} status: .${mode.name} '
      'type: $registerType';
}
