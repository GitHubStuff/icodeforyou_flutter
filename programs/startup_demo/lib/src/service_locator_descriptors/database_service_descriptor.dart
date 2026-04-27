// ignore_for_file: public_member_api_docs

import 'package:service_locator/service_locator.dart' show ServiceClass;

class Database implements ServiceClass {
  static Future<Database> create() async => Database();
}

// class DatabaseServiceDescriptor extends LazyAsyncServiceDescriptor<Database> {
//   @override
//   final name = 'Database';

//   @override
//   ServiceDescriptorStatus status = .waiting;

//   @override
//   final List<String> dependencies = ['MyTheme'];

//   @override
//   Future<Database> Function() get factory => Database.create;

//   @override
//   void acquire() => ServicesLocator.R.acquire(this);

//   @override
//   Future<void> register() => ServicesLocator.R.register(this);

//   @override
//   Future<Database> start() async => ServicesLocator.R.start(serviceEntry: this);
// }
