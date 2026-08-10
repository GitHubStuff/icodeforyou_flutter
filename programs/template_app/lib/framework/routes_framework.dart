// programs/template_app/lib/framework/routes.dart

import 'dart:async' show unawaited;

import 'package:custom_widgets/custom_widgets.dart'
    show CrashScreen, CrashScreenArgs;
import 'package:go_router/go_router.dart';
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/defaults/default_splash_screen.dart';
import 'package:template_app/screens/rail/rail_destination_enum.dart'
    show RailDestinationEnum;

part 'routes.goroute.dart';

class RoutesFramework {
  static const app = '/app';
  static const crash = '/crash';
  static const splash = '/splash';

  static GoRouter builtRoutes() {
    return GoRouter(
      initialLocation: splash,
      routes: <RouteBase>[
        _appRoute(),
        _crashRoute(),
        _splashRoute(),
      ],
    );
  }
}
