// startup_demo/lib/main.dart
// ignore_for_file: public_member_api_docs
import 'dart:async';

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show
        AnimatedRailMenu,
        MenuIconSpacing,
        RailDirection,
        RailIcon,
        RailTransition;
import 'package:animated_widgets/animated_widgets.dart'
    show PulseConfig, PulseWidget, SplashConfig, SplashCubit, SplashFlow;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferencesDescriptor;
import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
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

/// A task that succeeds after [delay].
Future<void> succeedsAfter(Duration delay) async {
  await Future<void>.delayed(delay);
}

/// A task that throws [error] after [delay].
Future<void> failsAfter(
  Duration delay, {
  Object error = 'task failed',
}) async {
  await Future<void>.delayed(delay);
  throw error;
}

/// A task that never completes. Useful for forcing the timeout path.
Future<void> neverCompletes() {
  return Completer<void>().future;
}

/// A task that completes synchronously (already-done future).
Future<void> alreadyDone() async {}

//+
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
    BlocProvider.value(
      value: SplashCubit(
        splashConfig: const SplashConfig(
          crossfadeDuration: Duration(milliseconds: 250),
        ),
      ),
    ),
  ],
  child: MaterialWidget(splashWidget),
);

Widget get splashWidget {
  return SplashFlow(
    splashWidget: pulse,
    intermediateWidget: const SizedSpinner(size: 60),
    landingPage: _homeScreen,
    tasks: [
      succeedsAfter(const Duration(seconds: 7)),
      succeedsAfter(const Duration(seconds: 3)),
      //failsAfter(const Duration(seconds: 5)),
      //neverCompletes(),
    ],
  );
  // unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
  // return const FullScreenColor();
}

Widget get pulse {
  return const PulseWidget(
    config: PulseConfig(
      pulseRestScale: 1,
      pulsePeakScale: 1.9,
      pulseStartScale: 0.15,
      // growDuration: Duration(milliseconds: 500),
      // holdDuration: Duration(seconds: 1),
      // shrinkDuration: Duration(milliseconds: 750),
      // shrinkCurve: Curves.easeOut,
    ),
    child: FlutterLogo(size: 200),
  );
}

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
