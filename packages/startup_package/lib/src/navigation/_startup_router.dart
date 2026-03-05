// lib/src/navigation/_startup_router.dart

import 'package:flutter/material.dart';

const Duration _duration = Duration(milliseconds: 3500);

class StartupRouter {
  const StartupRouter._();

  static Route<void> _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: _duration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static void navigateToLanding(BuildContext context, Widget landingPage) {
    Navigator.of(context).pushReplacement(_fadeRoute(landingPage));
  }
}
