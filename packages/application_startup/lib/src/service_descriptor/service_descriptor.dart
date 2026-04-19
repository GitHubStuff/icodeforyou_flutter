// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/src/private.dart';
// import 'package:application_startup/src/public.dart';

// sealed class ServiceDescriptor<SRV extends ServiceClass>
//     implements ServiceClass {
//   String get name;

//   ServiceDescriptorStatus get status => .waiting;
//   set status(ServiceDescriptorStatus value);

//   Duration get timeout => const Duration(seconds: 10_000);

//   List<String> get dependencies => [];

//   void acquire();
//   Future<void> register();
//   Future<SRV> start();
//   Future<SRV> resolve(BaseServiceLocator locator);

//   @override
//   String toString() => 'Name: "$name" Status: ${status.name}';
// }

// //+
// abstract class LazyAsyncServiceDescriptor<SRV extends ServiceClass>
//     extends ServiceDescriptor<SRV> {
//   Future<SRV> Function() get factory;

//   @override
//   Future<SRV> resolve(BaseServiceLocator locator) =>
//       locator.getServiceAsync<SRV>(name: name, timeout: timeout);
// }

// //+
// abstract class SyncServiceDescriptor<SRV extends ServiceClass>
//     extends ServiceDescriptor<SRV> {
//   SRV get instance;

//   @override
//   Future<SRV> resolve(BaseServiceLocator locator) async => instance;
// }
