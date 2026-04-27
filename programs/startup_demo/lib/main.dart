// lib/main.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show
        HapticIntensity,
        MenuIconSpacing,
        RailDirection,
        RailIcon,
        RailNavigationWidget,
        RailTransition;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_host/overlay_host.dart'
    show AnimatedOverlayCubit, OverlayHostCubit;
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:startup_demo/src/navigation/_nav_entries.dart';
import 'package:statusbar/statusbar.dart' show StatusBar;
import 'package:theme_manager/theme_manager.dart' show MaterialThemeCubit;
import 'package:theme_service/material_widget.dart' show MaterialWidget;
import 'package:theme_service/theme_service.dart'
    show ThemeDescriptor, ThemeService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //if (defaultTargetPlatform == TargetPlatform.iOS) {
  await StatusBar.setStatusBarHidden(hidden: true);
  //}

  ServiceRegistry.R.stage(ThemeDescriptor(name: 'Theme'));
  await ServiceRegistry.R.register('Theme');

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
    BlocProvider<OverlayHostCubit>(
      create: (_) => OverlayHostCubit(),
    ),
  ],
  child: const MaterialWidget(_homeScreen),
);

const _homeScreen = RailNavigationWidget(
  entries: navEntries,
  direction: RailDirection.adaptive,
  icon: RailIcon.phone,
  transition: RailTransition.slideDirectional,
  transitionDuration: Duration(milliseconds: 750),
  iconSpacing: MenuIconSpacing.collapsed,
  haptic: HapticIntensity.medium,
  limit: null,
);
