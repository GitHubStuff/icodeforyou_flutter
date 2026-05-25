// startup_demo/lib/main.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show
        AnimatedRailMenu,
        MenuIconSpacing,
        RailDirection,
        RailIcon,
        RailTransition;
import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedOverlayCubit;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferencesDescriptor;
import 'package:extensions/haptics/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remind_me/remind_me.dart' show RemindMe;
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:since_when_service/since_when_service.dart'
    show SinceWhenDescriptor, SinceWhenServiceClass;
import 'package:startup_demo/src/navigation/nav_entries.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialWidget, ThemeDescriptor, ThemeService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemindMe.instance.init();
  await RemindMe.instance.requestPermissions();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  // Lets the user set the brightness to dark, light, system
  ServiceRegistry.R.stage(const AppPreferencesDescriptor.platform());
  ServiceRegistry.R.stage(ThemeDescriptor(name: 'Theme'));
  await ServiceRegistry.R.register('Theme');

  // Stage and force-resolve since_when so pages can fetch it synchronously.
  // SinceWhenDescriptor is lazy-async; register() leaves it in `starting`
  // status, so we drive the builder to completion via getAsync to land it
  // in `ready` before runApp.
  //
  // Using .inMemory() until the real `since_when` package ships a
  // DatabaseSetup adapter. Switch to:
  //   SinceWhenDescriptor.documents(
  //     dbName: 'since_when.db',
  //     setups: const [SinceWhenSetup()],
  //   )
  // once that adapter exists. Note: .documents() cannot be const because
  // its parameters aren't compile-time literals.
  ServiceRegistry.R.stage(const SinceWhenDescriptor.inMemory());
  await ServiceRegistry.R.getAsync<SinceWhenServiceClass>('SinceWhen');

  runApp(providers);
}

final providers = MultiBlocProvider(
  providers: [
    BlocProvider<MaterialThemeCubit>.value(
      value: ServiceRegistry.R.getSync<ThemeService>('Theme').themeCubit,
    ),
    BlocProvider<AnimatedOverlayCubit>(
      create: (_) => AnimatedOverlayCubit(),
    ),
  ],
  child: const MaterialWidget(_homeScreen),
);

const _homeScreen = AnimatedRailMenu(
  entries: navEntries,
  direction: RailDirection.adaptive,
  icon: RailIcon.phone,
  transition: RailTransition.slideDirectional,
  transitionDuration: Duration(milliseconds: 750),
  iconSpacing: MenuIconSpacing.collapsed,
  haptic: HapticIntensity.medium,
  limit: null,
);
