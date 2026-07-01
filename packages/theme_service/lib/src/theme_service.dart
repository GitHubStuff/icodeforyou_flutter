// ignore_for_file: document_ignores, public_member_api_docs

import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:theme_manager/theme_manager.dart' show MaterialThemeCubit;

class ThemeService implements ServiceClass {
  ThemeService(this.themeCubit);
  final MaterialThemeCubit themeCubit;
}
