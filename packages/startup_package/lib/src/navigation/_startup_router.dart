// lib/src/navigation/_startup_router.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

const Duration _duration = Duration(milliseconds: 3500);

class StartupRouter {
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
    unawaited(Navigator.of(context).pushReplacement(_fadeRoute(landingPage)));
  }
}
