// app_preferences_service/lib/src/app_preferences_service_class.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;
import 'package:service_locator/service_locator.dart' show ServiceClass;

/// Service-locator handle for the app's preferences store.
///
/// Exposes a single [AbstractPreferencesInterface] handle. Other services that
/// need preferences access declare a dependency on this service class
/// and read [prefs] from the locator. The concrete backend (platform
/// or Hive) is selected by the descriptor used at registration time.
class AppPreferences implements ServiceClass {
  const AppPreferences(this.prefs);

  final AbstractPreferencesInterface prefs;
}
