// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/src/private.dart' show ReportServiceState;
// import 'package:application_startup/src/public.dart'
//     show
//         DuplicateServiceEntry,
//         ServiceClass,
//         ServiceNotReady,
//         ServiceNotRegistered,
//         ServicesManagerRegistered,
//         ServicesManagerRegistering;
// import 'package:application_startup/src/service_locator/base_service_locator.dart'
//     show BaseServiceLocator;
// import 'package:get_it/get_it.dart';
// import 'package:my_logger/my_logger.dart' show MyLogger;

// class GetItServiceLocator implements BaseServiceLocator {
//   // ---------------------------------------------------------------------------
//   // Construction
//   // ---------------------------------------------------------------------------

//   const GetItServiceLocator();

//   // ---------------------------------------------------------------------------
//   // GET
//   // ---------------------------------------------------------------------------

//   @override
//   Future<SRV> getServiceAsync<SRV extends ServiceClass>({
//     required String name,
//     required Duration timeout,
//   }) async {
//     _assertRegistered<SRV>(name);
//     await GetIt.I.isReady<SRV>(instanceName: name, timeout: timeout);
//     return GetIt.I.get<SRV>(instanceName: name);
//   }

//   @override
//   SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
//     _assertRegistered<SRV>(name);
//     return _getOrThrowNotReady<SRV>(name);
//   }

//   // ---------------------------------------------------------------------------
//   // REGISTER
//   // ---------------------------------------------------------------------------

//   @override
//   void registerServiceLazyAsync<SRV extends ServiceClass>({
//     required String name,
//     required Future<SRV> Function() factory,
//     required ReportServiceState serviceState,
//   }) {
//     if (GetIt.I.isRegistered<SRV>(instanceName: name)) {
//       throw DuplicateServiceEntry(name);
//     }

//     GetIt.I.registerLazySingletonAsync<SRV>(
//       factory,
//       instanceName: name,
//       onCreated: (service) {
//         MyLogger.t('Async created $name');
//         serviceState(ServicesManagerRegistered(name));
//       },
//     );
//     MyLogger.t('Async registering $name');
//     serviceState(ServicesManagerRegistering(name));
//     _assertRegistered<SRV>(name);
//     MyLogger.t('Looking up type: ${SRV.toString()} name: $name', tag: 'Reg');
//     MyLogger.t('All registered: ${GetIt.I.toString()}', tag: 'Reg');
//   }

//   @override
//   SRV registerServiceSync<SRV extends ServiceClass>({
//     required String name,
//     required SRV instance,
//   }) {
//     if (GetIt.I.isRegistered<SRV>(instanceName: name)) {
//       throw DuplicateServiceEntry(name);
//     }

//     return GetIt.I.registerSingleton<SRV>(
//       instance,
//       instanceName: name,
//       signalsReady: true,
//     );
//   }

//   //+
//   @override
//   Future<SRV> startServiceAsync<SRV extends ServiceClass>({
//     required String name,
//     required Duration timeout,
//   }) {
//     MyLogger.t('Looking up type: ${SRV.toString()} name: $name', tag: 'SRT');
//     MyLogger.t('All registered: ${GetIt.I.toString()}', tag: 'SRT');
//     _assertRegistered<SRV>(name);
//     return GetIt.I.getAsync<SRV>(instanceName: name).timeout(timeout);
//   }

//   // ---------------------------------------------------------------------------
//   // Private helpers
//   // ---------------------------------------------------------------------------

//   void _assertRegistered<SRV extends ServiceClass>(String name) {
//     if (GetIt.I.isRegistered<SRV>(instanceName: name)) return;
//     throw ServiceNotRegistered(name);
//   }

//   SRV _getOrThrowNotReady<SRV extends ServiceClass>(String name) {
//     try {
//       return GetIt.I.get<SRV>(instanceName: name);
//       // ignore: avoid_catching_errors
//     } on Error {
//       // GetIt throws an Error (not Exception) when a singleton is not yet ready.
//       // This is documented behaviour in the GetIt API.
//       throw ServiceNotReady(name);
//     }
//   }
// }
