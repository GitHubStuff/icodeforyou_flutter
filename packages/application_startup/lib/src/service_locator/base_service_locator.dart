// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/src/private.dart' show ReportServiceState;
// import 'package:application_startup/src/public.dart';

// abstract interface class BaseServiceLocator {
//   //+ GET
//   Future<SRV> getServiceAsync<SRV extends ServiceClass>({
//     required String name,
//     required Duration timeout,
//   });

//   SRV getServiceSync<SRV extends ServiceClass>({required String name});

//   //+ REGISTER
//   void registerServiceLazyAsync<SRV extends ServiceClass>({
//     required String name,
//     required Future<SRV> Function() factory,
//     required ReportServiceState serviceState,
//   });

//   SRV registerServiceSync<SRV extends ServiceClass>({
//     required String name,
//     required SRV instance,
//   });

//   //+ START
//   Future<SRV> startServiceAsync<SRV extends ServiceClass>({
//     required String name,
//     required Duration timeout,
//   });
// }
