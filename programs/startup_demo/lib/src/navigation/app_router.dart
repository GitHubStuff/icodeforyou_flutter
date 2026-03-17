// lib/src/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rail_menu/rail_menu.dart';
import 'package:startup_demo/src/navigation/app_route.dart';
import 'package:startup_demo/src/navigation/app_shell.dart';
import 'package:startup_demo/src/pages/about_page.dart';
import 'package:startup_demo/src/pages/analytics_page.dart';
import 'package:startup_demo/src/pages/help_page.dart';
import 'package:startup_demo/src/pages/landing_page.dart';
import 'package:startup_demo/src/pages/notifications_page.dart';
import 'package:startup_demo/src/pages/profile_page.dart';
import 'package:startup_demo/src/pages/settings_page.dart';

/// The app-level [GoRouter] configuration.
///
/// All routes are nested under a [ShellRoute] so the [AppShell]
/// (with its [RailMenu]) persists across navigation.
final appRouter = GoRouter(
  initialLocation: AppRoute.landing.path,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoute.landing.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const LandingPage(),
          ),
        ),
        GoRoute(
          path: AppRoute.settings.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const SettingsPage(),
          ),
        ),
        GoRoute(
          path: AppRoute.profile.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const ProfilePage(),
          ),
        ),
        GoRoute(
          path: AppRoute.notifications.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const NotificationsPage(),
          ),
        ),
        GoRoute(
          path: AppRoute.analytics.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const AnalyticsPage(),
          ),
        ),
        GoRoute(
          path: AppRoute.help.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const HelpPage(),
          ),
        ),
        GoRoute(
          path: AppRoute.about.path,
          pageBuilder: (context, state) => _buildPage(
            context: context,
            state: state,
            child: const AboutPage(),
          ),
        ),
      ],
    ),
  ],
);

Page<void> _buildPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final transition = context.read<RailMenuCubit>().transition;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        _buildTransition(transition, animation, child),
  );
}

Widget _buildTransition(
  RailMenuTransition transition,
  Animation<double> animation,
  Widget child,
) {
  switch (transition) {
    case RailMenuTransition.slideFromLeft:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case RailMenuTransition.slideFromRight:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    case RailMenuTransition.fade:
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    case RailMenuTransition.none:
      return child;
  }
}
