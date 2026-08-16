// programs/startup_demo/lib/src/service_locator_descriptors/database_service_descriptor.dart

// ignore_for_file: public_member_api_docs

import 'package:service_locator/service_locator.dart' show ServiceClass;

class Database implements ServiceClass {
  static Future<Database> create() async => Database();
}
