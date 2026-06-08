// lib/packages/animated_rail_menu/lib/src/widget/animated_rail_menu_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnimatedRailMenu)
Widget animatedRailMenuUseCase(BuildContext context) {
  final direction = context.knobs.object.dropdown<RailDirection>(
    label: 'direction',
    options: RailDirection.values,
    initialOption: RailDirection.adaptive,
    labelBuilder: (d) => d.name,
  );

  final icon = context.knobs.object.dropdown<RailIcon>(
    label: 'icon size',
    options: RailIcon.values,
    initialOption: RailIcon.phone,
    labelBuilder: (i) => i.name,
  );

  final transition = context.knobs.object.dropdown<RailTransition>(
    label: 'transition',
    options: RailTransition.values,
    initialOption: RailTransition.crossFade,
    labelBuilder: (t) => t.name,
  );

  final iconSpacing = context.knobs.object.dropdown<MenuIconSpacing>(
    label: 'iconSpacing',
    options: MenuIconSpacing.values,
    initialOption: MenuIconSpacing.expanded,
    labelBuilder: (s) => s.name,
  );

  final transitionMs = context.knobs.int.slider(
    label: 'transition duration (ms)',
    initialValue: 200,
    min: 60,
    max: 1200,
  );

  final useLimit = context.knobs.boolean(
    label: 'enable item limit',
    initialValue: false,
  );

  final limit = context.knobs.int.slider(
    label: 'limit (when enabled)',
    initialValue: 4,
    min: 2,
    max: 8,
  );

  final entries = const [
    AnimatedRailMenuEntry(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      page: _Page(icon: Icons.home, label: 'Home', color: Colors.blue),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Search',
      page: _Page(icon: Icons.search, label: 'Search', color: Colors.teal),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favorites',
      page: _Page(icon: Icons.favorite, label: 'Favorites', color: Colors.pink),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
      page: _Page(icon: Icons.notifications, label: 'Alerts', color: Colors.orange),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      page: _Page(icon: Icons.settings, label: 'Settings', color: Colors.purple),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      page: _Page(icon: Icons.person, label: 'Profile', color: Colors.indigo),
    ),
  ];

  return AnimatedRailMenu(
    entries: entries,
    direction: direction,
    icon: icon,
    transition: transition,
    transitionDuration: Duration(milliseconds: transitionMs),
    iconSpacing: iconSpacing,
    haptic: HapticIntensity.light,
    limit: useLimit ? limit : null,
  );
}

class _Page extends StatelessWidget {
  const _Page({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withValues(alpha: 0.12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96, color: color),
            const Gap(16),
            Text(
              label,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
