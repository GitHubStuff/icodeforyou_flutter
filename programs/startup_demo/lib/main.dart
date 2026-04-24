// lib/main.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, Cubit;
import 'package:startup_demo/src/_startup_tasks.dart' show StartupTasks;
import 'package:startup_demo/src/cubit_demo.dart' show CubitDemo;
import 'package:startup_demo/src/navigation/_nav_entries.dart';
import 'package:startup_demo/src/pages/landing_page.dart';

class ServicesLocator extends Cubit<int> {
  ServicesLocator() : super(3);
}

final cubit = ServicesLocator();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        home: CubitDemo(),
      ),
    ),
  );
}

/*

ApplicationStartupRunner(
  splashConfig: _splashConfig,
  homeScreen: _homeyScreen,
  tasks: StartupTasks.all,
  darkTheme: ThemeData.dark().copyWith(
    extensions: [
      RailMenuTheme.dark(),
      ContextualRevealTheme.dark(),
    ],
  ),
  lightTheme: ThemeData.light().copyWith(
    extensions: [
      RailMenuTheme.light(),
      ContextualRevealTheme.light(),
    ],
  ),
).run();

const _splashConfig = SplashScreenConfiguration(
  splashWidget: _splashWidget,
  splashDuration: Duration(seconds: 2),
  transition: SplashTransitions.crossFade,
  transitionDuration: Duration(milliseconds: 400),
);

const _splashWidget = GrowAndFadeWidgetView(
  duration: Duration(milliseconds: 1900),
  child: FlutterLogo(size: 300),
);

const _homeyScreen = RailNavigationWidget(
  direction: RailDirection.adaptive,
  icon: RailIcon.phone,
  transition: RailTransition.slideDirectional,
  iconSpacing: MenuIconSpacing.collapsed,
  transitionDuration: Duration(milliseconds: 750),
  entries: navEntries,
);
*/
