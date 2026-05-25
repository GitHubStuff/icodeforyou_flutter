// programs/creature_comforts/lib/descriptors/last_fed_reminder_descriptor.dart
// ignore_for_file: public_member_api_docs

import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:creature_comforts/src/reminders/last_fed_reminder_service.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart' show LastFedService;
import 'package:service_locator/service_locator.dart';

/// Service-locator descriptor for [LastFedReminderService].
///
/// Registers as a synchronous singleton. Declares hard dependencies on
/// [LastFedService] (the data source) and [AppPreferences] (the in-app
/// reminders-enabled toggle store). The registry resolves both
/// dependencies before this descriptor's builder fires.
///
/// Note: AppPreferences is registered as `LazyAsync`, so its builder is
/// staged but not fired by dependency resolution alone. The reminder
/// service materializes it via [ServiceRegistry.getAsync] from the
/// builder — this descriptor is fully sync, but its builder awaits the
/// lazy dep through the registry's async API.
class LastFedReminderDescriptor
    extends AsyncServiceDescriptor<LastFedReminderService> {
  const LastFedReminderDescriptor();

  /// Canonical name. Use this everywhere instead of the literal string.
  static const String kName = 'LastFedReminderService';

  @override
  String get name => kName;

  @override
  List<Type> get dependencies => const [LastFedService, AppPreferences];

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<LastFedReminderService> Function() get builder => () async {
    final lastFed = ServiceRegistry.R.getSync<LastFedService>(
      'LastFedService',
    );
    final appPrefs = await ServiceRegistry.R.getAsync<AppPreferences>(
      'AppPreferences',
    );
    return LastFedReminderService(
      lastFed: lastFed,
      appPrefs: appPrefs,
    );
  };
}
