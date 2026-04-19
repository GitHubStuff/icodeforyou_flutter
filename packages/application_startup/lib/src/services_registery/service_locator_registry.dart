// // ignore_for_file: public_member_api_docs

// import 'dart:async' show TimeoutException;

// import 'package:application_startup/src/private.dart';
// import 'package:application_startup/src/public.dart'
//     show
//         DuplicateServiceEntry,
//         InvalidLocatorState,
//         ServiceClass,
//         ServiceDescriptorStatus,
//         ServiceItemTimeout,
//         ServiceNotRegistered,
//         ServicesManagerReady,
//         ServicesManagerRegistered,
//         ServicesManagerRegistering,
//         ServicesManagerStarting,
//         UnknownServiceEntry;
// import 'package:application_startup/src/service_descriptor/service_descriptor.dart';
// import 'package:my_logger/my_logger.dart' show MyLogger;

// class ServiceLocatorRegistry {
//   ServiceLocatorRegistry({required BaseServiceLocator locator})
//     : _locator = locator;

//   final BaseServiceLocator _locator;

//   final ServicesLocatorStore _store = ServicesLocatorStore();

//   //+
//   void catalog<SD extends ServiceDescriptor<SRV>, SRV extends ServiceClass>(
//     SD entry,
//   ) => _store.catalogServiceDescriptor(entry);

//   //+

//   SD getServiceDescriptor<SD extends ServiceDescriptor>() =>
//       _store.getServiceDescriptor();

//   SD getServiceDescriptorBy<SD extends ServiceDescriptor>({
//     required String name,
//   }) => _store.getServiceDescriptorBy<SD>(name: name);

//   //+
//   Future<void>
//   register<SD extends ServiceDescriptor<SRV>, SRV extends ServiceClass>({
//     required SD descriptor,
//     required ReportServiceState newState,
//   }) async {
//     switch (descriptor.status) {
//       case .cataloged:
//         _store.setStatus<SD>(newStatus: .registering);
//         newState(ServicesManagerRegistering(descriptor.name));

//       case .ready:
//         newState(ServicesManagerReady(descriptor.name));
//         return;

//       case .registered:
//         newState(ServicesManagerRegistered(descriptor.name));
//         return;

//       case .registering:
//         newState(ServicesManagerRegistering(descriptor.name));
//         return;

//       case .starting:
//       case .waiting:
//         throw InvalidLocatorState(
//           descriptor.status.name,
//           onServiceLocator: descriptor.toString(),
//         );
//     }

//     await _registerDependencies(
//       serviceDescriptor: descriptor,
//       newState: newState,
//     );

//     switch (descriptor) {
//       case final LazyAsyncServiceDescriptor e:
//         _locator.registerServiceLazyAsync(
//           name: e.name,
//           factory: e.factory,
//           serviceState: (state) {
//             descriptor.status = state.status;
//             newState(state);
//           },
//         );

//       case final SyncServiceDescriptor e:
//         _locator.registerServiceSync<SRV>(
//           name: e.name,
//           instance: e.instance as SRV,
//         );
//         descriptor.status = .ready;
//         newState(ServicesManagerReady(descriptor.name));
//     }
//   }

//   Future<void> _registerDependencies<
//     SD extends ServiceDescriptor<SRV>,
//     SRV extends ServiceClass
//   >({
//     required SD serviceDescriptor,
//     required ReportServiceState newState,
//   }) async {
//     try {
//       await Future.wait(
//         serviceDescriptor.dependencies.map((dependant) async {
//           final descriptor = getServiceDescriptorBy(name: dependant);
//           MyLogger.t('Registering dependency: $descriptor');

//           if (descriptor.status == .cataloged) {
//             newState(
//               ServicesManagerRegistering(
//                 'Dependency ${descriptor.name}',
//               ),
//             );
//             await descriptor.register();
//           }
//         }),
//       ).timeout(serviceDescriptor.timeout);
//     } on TimeoutException {
//       throw ServiceItemTimeout(
//         serviceDescriptor.name,
//         serviceDescriptor.timeout,
//       );
//     }
//   }

//   //+ Start
//   Future<SRV>
//   start<SD extends ServiceDescriptor<SRV>, SRV extends ServiceClass>({
//     required SD descriptor,
//     required ReportServiceState newState,
//   }) async {
//     newState(ServicesManagerStarting(descriptor.name));

//     switch (descriptor.status) {
//       case .cataloged:
//         throw ServiceNotRegistered(descriptor.name);

//       case .ready:
//         final service = await descriptor.resolve(_locator);
//         newState(ServicesManagerReady(descriptor.name));
//         return service;

//       case .registered:
//       case .registering:
//         break;

//       case .starting:
//       case .waiting:
//         throw InvalidLocatorState(
//           descriptor.status.name,
//           onServiceLocator: descriptor.toString(),
//         );
//     }

//     await _startDependencies(
//       serviceDescriptor: descriptor,
//       newState: newState,
//     );

//     final service = await descriptor.resolve(_locator);

//     descriptor.status = .ready;

//     return service;
//   }

//   Future<void> _startDependencies<SRV extends ServiceClass>({
//     required ServiceDescriptor<SRV> serviceDescriptor,
//     required ReportServiceState newState,
//   }) async {
//     try {
//       await Future.wait(
//         serviceDescriptor.dependencies.map((dependant) async {
//           final descriptor = getServiceDescriptorBy(name: dependant);
//           MyLogger.t('Starting dependency: $descriptor');
//           if (descriptor.status != .ready) {
//             newState(
//               ServicesManagerStarting('Dependency ${descriptor.name}'),
//             );
//             await descriptor.start();
//           }
//         }),
//       ).timeout(serviceDescriptor.timeout);
//     } on TimeoutException {
//       throw ServiceItemTimeout(
//         serviceDescriptor.name,
//         serviceDescriptor.timeout,
//       );
//     }
//   }
// }

// //------------------------------------------------------------------------------
// class ServicesLocatorStore {
//   ServicesLocatorStore();

//   final Map<String, ServiceDescriptor> _serviceStore = {};
//   final Map<Type, String> _typeStore = {};

//   void catalogServiceDescriptor<
//     SD extends ServiceDescriptor<SRV>,
//     SRV extends ServiceClass
//   >(
//     SD entry,
//   ) {
//     if (_serviceStore[entry.name] != null) {
//       throw DuplicateServiceEntry(entry.name);
//     }
//     _serviceStore[entry.name] = entry;
//     _typeStore[SD] = entry.name;
//     entry.status = .cataloged;
//   }

//   //+
//   SD getServiceDescriptor<SD extends ServiceDescriptor>() {
//     final name = _typeStore[SD];
//     if (name == null) throw UnknownServiceEntry(SD.toString());
//     return _serviceStore[name]! as SD;
//   }

//   SD getServiceDescriptorBy<SD extends ServiceDescriptor>({
//     required String name,
//   }) {
//     final entry = _serviceStore[name];
//     if (entry == null) throw UnknownServiceEntry(name);
//     return entry as SD;
//   }

//   /// Updates the [ServiceDescriptorStatus] of the [ServiceDescriptor] identified by
//   /// type [SD].
//   ///
//   /// A setter cannot be used here as Dart setters do not support
//   /// type parameters.
//   // ignore: use_setters_to_change_properties
//   void setStatus<SD extends ServiceDescriptor>({
//     required ServiceDescriptorStatus newStatus,
//   }) => getServiceDescriptor<SD>().status = newStatus;
// }
