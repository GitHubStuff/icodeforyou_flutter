// programs/creature_comfort/lib/main.dart

import 'package:animated_widgets/animated_widgets.dart'
    show PulseWidget, SplashConfig, SplashCubit, SplashScreen;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferencesDescriptor;
import 'package:creature_comfort/firebase_options.dart';
import 'package:creature_comfort/src/state/general_cubit.dart'
    show GeneralCubit;
import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;

/// Demonstrates how the three Navigator layers coexist with the rail:
///
///   Layer 1 (root navigator)   -> full-screen routes that COVER the rail.
///   Layer 2 (the rail shell)   -> AnimatedRailMenu, switches body by index.
///   Layer 3 (branch navigator) -> per-tab pushes that KEEP the rail visible.
///
/// Home    tab -> Layer 3: push a detail page, the rail stays on screen.
/// Library tab -> Layer 1: push a full-screen editor, the rail disappears.
///
/// State-preservation note: AnimatedRailMenu swaps pages with an
/// AnimatedSwitcher, so an inactive tab is DISPOSED on switch. The tap
/// counters survive a push/pop, but reset when you leave and re-enter a
/// tab. That reset is exactly what go_router's
/// StatefulShellRoute.indexedStack removes -- the trade-off to weigh
/// before adopting it.

// programs/creature_comfort/lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Lets the user set the brightness to dark, light, system
  ServiceRegistry.R.stage(const AppPreferencesDescriptor.platform());

  runApp(providers);
}

final providers = MultiBlocProvider(
  providers: [
    BlocProvider<GeneralCubit>.value(
      value: GeneralCubit(),
    ),

    BlocProvider.value(
      value: SplashCubit(
        splashConfig: const SplashConfig(
          splashDuration: Duration(milliseconds: 1500),
          crossfadeDuration: Duration(milliseconds: 250),
        ),
      ),
    ),
  ],
  child: splashWidget,
);

Widget get splashWidget {
  return SplashScreen(
    splashWidget: pulse,
    intermediateWidget: const SizedSpinner(size: 60),
    landingPage: const Text('Dont use in current form'),
    tasks: const [],
  );
  // unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
  // return const FullScreenColor();
}

Widget get pulse {
  return const PulseWidget(
    child: FlutterLogo(size: 200),
  );
}
