// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/src/cubit/services_state_manager_state.dart';
// import 'package:application_startup/src/public.dart' show ServiceClass;
// import 'package:application_startup/src/service_descriptor/service_descriptor.dart'
//     show ServiceDescriptor;
// import 'package:application_startup/src/services_registery/service_locator_registry.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ServicesStateManagerCubit extends Cubit<ServicesManagerState> {
//   ServicesStateManagerCubit(ServiceLocatorRegistry registry)
//     : _registry = registry,
//       super(const ServicesManagerWaiting(''));

//   final ServiceLocatorRegistry _registry;
//   //-
//   void acquire<SRV extends ServiceClass, SE extends ServiceDescriptor<SRV>>(
//     SE serviceItem,
//   ) {
//     _registry.catalog(serviceItem);
//     emit(ServicesManagerCataloged(serviceItem.name)..debugLog());
//   }

//   //-
//   Future<void>
//   register<SRV extends ServiceClass, SE extends ServiceDescriptor<SRV>>(
//     SE serviceEntry,
//   ) async {
//     await _registry.register(
//       descriptor: serviceEntry,
//       newState: (state) {
//         emit(state..debugLog());
//       },
//     );
//   }

//   //-
//   Future<SRV> start<SRV extends ServiceClass>({
//     required ServiceDescriptor<SRV> serviceEntry,
//   }) async {
//     return _registry.start(
//       descriptor: serviceEntry,
//       newState: (state) {
//         emit(state..debugLog());
//       },
//     );
//   }
// }
