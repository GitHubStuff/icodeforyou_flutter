// lib/src/navigation/app_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rail_menu/rail_menu.dart';
import 'package:startup_demo/src/navigation/app_route.dart';

/// The persistent shell rendered by [ShellRoute].
///
/// Owns the [RailMenuCubit] lifecycle. Builds [RailMenuItem]s directly
/// from [AppRoute.values] — no separate menu items class needed.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _dimensions = RailMenuDimensions(
    itemExtent: 64,
    iconSize: 24,
    barExtent: 64,
  );

  static const _railLimit = 4;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RailMenuCubit(),
      child: _AppShellView(child: child),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView({required this.child});

  final Widget child;

  List<RailMenuItem> _buildItems(BuildContext context) =>
      AppRoute.values.map((route) => _buildItem(context, route)).toList();

  RailMenuItem _buildItem(BuildContext context, AppRoute route) =>
      RailMenuItem(
        child: _RailIcon(route: route),
        transitionFromLeft: route.transitionFromLeft,
        transitionFromRight: route.transitionFromRight,
        onTap: () {
          final cubit = context.read<RailMenuCubit>();
          final transition = route.index > cubit.activeIndex
              ? route.transitionFromRight
              : route.transitionFromLeft;
          cubit.setActive(route.index, transition);
          context.go(route.path);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: RailMenu(
          direction: RailMenuDirection.bottom,
          dimensions: AppShell._dimensions,
          activeColor: Theme.of(context).colorScheme.primary,
          limit: AppShell._railLimit,
          items: _buildItems(context),
        ),
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  const _RailIcon({required this.route});

  final AppRoute route;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(route.icon),
        Text(route.label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
