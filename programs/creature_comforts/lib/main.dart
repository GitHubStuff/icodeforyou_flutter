// programs/creature_comforts/lib/main.dart
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:remind_me/remind_me.dart';
import 'package:service_locator/service_locator.dart';
import 'package:theme_manager/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-level initialization — must complete before any service the
  // app stages can run, since Firebase services depend on a live SDK and
  // RemindMe wires platform notification channels at init time.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await RemindMe.instance.init();

  // Stage every service the app uses up front. Staging is cheap (just
  // registers descriptors with the registry); actual builders fire when
  // `register` resolves the dependency graph.
  //
  // AppPreferences must be staged before ThemeDescriptor and any other
  // descriptor that depends on it — the registry resolves dependencies
  // by name, so all of them must already be staged when register fires.
  final registry = ServiceRegistry.R
    ..stage(const AppPreferencesDescriptor.platform())
    ..stage(ThemeDescriptor(name: 'Theme'))
    ..stage(const AuthServiceDescriptor())
    ..stage(const BiometricGateDescriptor())
    ..stage(const LastFedServiceDescriptor())
    ..stage(const LastFedReminderDescriptor());

  // Register top-level services. Dependencies are pulled in transitively
  // by the registry, so registering the reminder service alone would also
  // bring in LastFedService — but listing them explicitly makes startup
  // intent obvious to anyone reading this file.
  await registry.register('AppPreferences');
  await registry.register('Theme');
  await registry.register(AuthServiceDescriptor.kName);
  await registry.register(BiometricGateDescriptor.kName);
  await registry.register(LastFedServiceDescriptor.kName);
  await registry.register(LastFedReminderDescriptor.kName);

  runApp(const CreatureComfortsApp());
}
