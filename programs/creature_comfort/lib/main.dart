// programs/creature_comfort/lib/main.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs

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
import 'package:creature_comfort/firebase_options.dart';
import 'package:creature_comfort/src/state/general_cubit.dart'
    show GeneralCubit;
import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
import 'package:extensions/haptics/haptic_intensity.dart' show HapticIntensity;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialWidget, ThemeDescriptor, ThemeService;

import 'src/nav_entries.dart' show navEntries;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Lets the user set the brightness to dark, light, system
  ServiceRegistry.R.stage(const AppPreferencesDescriptor.platform());
  ServiceRegistry.R.stage(ThemeDescriptor(name: 'Theme'));
  await ServiceRegistry.R.register('Theme');

  runApp(providers);
}

final providers = MultiBlocProvider(
  providers: [
    BlocProvider<GeneralCubit>.value(
      value: GeneralCubit(),
    ),
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
    tasks: const [],
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
  transition: RailTransition.crossFade,
  transitionDuration: Duration(milliseconds: 700),
  iconSpacing: MenuIconSpacing.collapsed,
  haptic: HapticIntensity.medium,
  limit: null,
);
