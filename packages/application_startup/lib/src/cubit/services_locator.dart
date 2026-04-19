// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/src/cubit/cubit.dart'
//     show ServicesStateManagerCubit;
// import 'package:application_startup/src/private.dart';
// import 'package:application_startup/src/service_locator/getit_service_locator.dart'
//     show GetItServiceLocator;
// import 'package:get_it/get_it.dart';

// class ServicesLocator {
//   static const String _name = 'ServicesStateManagerLocator';

//   static final ServiceLocatorRegistry _servicesRegistry =
//       ServiceLocatorRegistry(
//         locator: const GetItServiceLocator(),
//       );

//   /// [_name] is easier to change at the top of the class
//   // ignore: sort_constructors_first
//   ServicesLocator() {
//     final cubit = ServicesStateManagerCubit(_servicesRegistry);
//     GetIt.I.registerSingleton<ServicesStateManagerCubit>(
//       cubit,
//       instanceName: _name,
//       signalsReady: true,
//     );
//   }

//   static ServicesStateManagerCubit get R {
//     if (!GetIt.I.isRegistered<ServicesStateManagerCubit>(instanceName: _name)) {
//       ServicesLocator();
//     }
//     return GetIt.I.get<ServicesStateManagerCubit>(instanceName: _name);
//   }
// }
