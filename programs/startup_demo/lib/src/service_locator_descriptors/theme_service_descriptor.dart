// // ignore_for_file: public_member_api_docs

// import 'package:application_startup/application_startup.dart'
//     show
//         ServiceClass,
//         ServiceDescriptorStatus,
//         ServicesLocator,
//         SyncServiceDescriptor;
// import 'package:my_logger/my_logger.dart';

// class ThemeServiceDescriptor extends SyncServiceDescriptor<MyTheme> {
//   @override
//   final name = 'MyTheme';

//   @override
//   ServiceDescriptorStatus status = .waiting;

//   @override
//   final MyTheme instance = MyTheme();

//   @override
//   void acquire() => ServicesLocator.R.acquire(this);

//   @override
//   Future<void> register() => ServicesLocator.R.register(this);

//   @override
//   Future<MyTheme> start() async => ServicesLocator.R.start(serviceEntry: this);
// }

// class MyTheme implements ServiceClass {
//   MyTheme() {
//     MyLogger.i('Created ThemeServiceDescriptor');
//   }
// }
