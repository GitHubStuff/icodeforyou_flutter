// lib/packages/animated_rail_menu/animated_rail_menu.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:extensions/haptics/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Stub page
// ---------------------------------------------------------------------------

class _StubPage extends StatelessWidget {
  const _StubPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(label, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Host widgets
// ---------------------------------------------------------------------------

class _HorizontalHost extends StatelessWidget {
  const _HorizontalHost({
    required this.transition,
    required this.icon,
    required this.spacing,
    required this.duration,
  });

  final RailTransition transition;
  final RailIcon icon;
  final MenuIconSpacing spacing;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AnimatedRailMenu(
    direction: RailDirection.horizontal,
    entries: const [
      AnimatedRailMenuEntry(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: _StubPage(label: 'Home'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: _StubPage(label: 'Settings'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        page: _StubPage(label: 'Profile'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        page: _StubPage(label: 'Alerts'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Analytics',
        page: _StubPage(label: 'Analytics'),
      ),
    ],
    transition: transition,
    icon: icon,
    transitionDuration: duration,
    iconSpacing: spacing,
  );
}

class _VerticalHost extends StatelessWidget {
  const _VerticalHost({
    required this.transition,
    required this.icon,
    required this.spacing,
    required this.duration,
  });

  final RailTransition transition;
  final RailIcon icon;
  final MenuIconSpacing spacing;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AnimatedRailMenu(
    direction: RailDirection.vertical,
    entries: const [
      AnimatedRailMenuEntry(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: _StubPage(label: 'Home'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: _StubPage(label: 'Settings'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        page: _StubPage(label: 'Profile'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        page: _StubPage(label: 'Alerts'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Analytics',
        page: _StubPage(label: 'Analytics'),
      ),
    ],
    transition: transition,
    icon: icon,
    transitionDuration: duration,
    iconSpacing: spacing,
  );
}

class _OverflowHost extends StatelessWidget {
  const _OverflowHost({
    required this.direction,
    required this.limit,
    required this.transition,
    required this.spacing,
  });

  final RailDirection direction;
  final int limit;
  final RailTransition transition;
  final MenuIconSpacing spacing;

  @override
  Widget build(BuildContext context) => AnimatedRailMenu(
    direction: direction,
    entries: const [
      AnimatedRailMenuEntry(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: _StubPage(label: 'Home'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: _StubPage(label: 'Settings'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        page: _StubPage(label: 'Profile'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        page: _StubPage(label: 'Alerts'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Analytics',
        page: _StubPage(label: 'Analytics'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.help_outline,
        activeIcon: Icons.help,
        label: 'Help',
        page: _StubPage(label: 'Help'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.info_outline,
        activeIcon: Icons.info,
        label: 'About',
        page: _StubPage(label: 'About'),
      ),
    ],
    limit: limit,
    transition: transition,
    iconSpacing: spacing,
    transitionDuration: const Duration(milliseconds: 200),
  );
}

class _HapticHost extends StatelessWidget {
  const _HapticHost({
    required this.haptic,
    required this.transition,
    required this.spacing,
  });

  final HapticIntensity haptic;
  final RailTransition transition;
  final MenuIconSpacing spacing;

  @override
  Widget build(BuildContext context) => AnimatedRailMenu(
    direction: RailDirection.horizontal,
    entries: const [
      AnimatedRailMenuEntry(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: _StubPage(label: 'Home'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: _StubPage(label: 'Settings'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        page: _StubPage(label: 'Profile'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        page: _StubPage(label: 'Alerts'),
      ),
      AnimatedRailMenuEntry(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Analytics',
        page: _StubPage(label: 'Analytics'),
      ),
    ],
    haptic: haptic,
    transition: transition,
    iconSpacing: spacing,
    transitionDuration: const Duration(milliseconds: 200),
  );
}

// ---------------------------------------------------------------------------
// Knob maps
// ---------------------------------------------------------------------------

const Map<String, RailTransition> _transitions = {
  'crossFade': RailTransition.crossFade,
  'slideLeft': RailTransition.slideLeft,
  'slideRight': RailTransition.slideRight,
  'slideDirectional': RailTransition.slideDirectional,
  'scale': RailTransition.scale,
  'slideUp': RailTransition.slideUp,
  'slideDown': RailTransition.slideDown,
};

const Map<String, RailIcon> _icons = {
  'smallPhone': RailIcon.smallPhone,
  'phone': RailIcon.phone,
  'smallTablet': RailIcon.smallTablet,
  'tablet': RailIcon.tablet,
  'largeTablet': RailIcon.largeTablet,
  'desktop': RailIcon.desktop,
  'web': RailIcon.web,
};

const Map<String, HapticIntensity> _haptics = {
  'none': HapticIntensity.none,
  'light': HapticIntensity.light,
  'medium': HapticIntensity.medium,
  'heavy': HapticIntensity.heavy,
};

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Horizontal', type: AnimatedRailMenu)
Widget railNavigationHorizontal(BuildContext context) {
  final transitionName = context.knobs.object.dropdown<String>(
    label: 'Transition',
    options: _transitions.keys.toList(),
    initialOption: 'crossFade',
  );
  final iconName = context.knobs.object.dropdown<String>(
    label: 'Icon Size',
    options: _icons.keys.toList(),
    initialOption: 'phone',
  );
  final spacing = context.knobs.boolean(
    label: 'Expanded Spacing',
    initialValue: true,
  );
  final ms = context.knobs.double.slider(
    label: 'Transition Duration (ms)',
    initialValue: 200,
    min: 0,
    max: 800,
  );

  return _HorizontalHost(
    transition: _transitions[transitionName]!,
    icon: _icons[iconName]!,
    spacing: spacing ? MenuIconSpacing.expanded : MenuIconSpacing.collapsed,
    duration: Duration(milliseconds: ms.toInt()),
  );
}

@widgetbook.UseCase(name: 'Vertical', type: AnimatedRailMenu)
Widget railNavigationVertical(BuildContext context) {
  final transitionName = context.knobs.object.dropdown<String>(
    label: 'Transition',
    options: _transitions.keys.toList(),
    initialOption: 'crossFade',
  );
  final iconName = context.knobs.object.dropdown<String>(
    label: 'Icon Size',
    options: _icons.keys.toList(),
    initialOption: 'tablet',
  );
  final spacing = context.knobs.boolean(
    label: 'Expanded Spacing',
    initialValue: true,
  );
  final ms = context.knobs.double.slider(
    label: 'Transition Duration (ms)',
    initialValue: 200,
    min: 0,
    max: 800,
  );

  return _VerticalHost(
    transition: _transitions[transitionName]!,
    icon: _icons[iconName]!,
    spacing: spacing ? MenuIconSpacing.expanded : MenuIconSpacing.collapsed,
    duration: Duration(milliseconds: ms.toInt()),
  );
}

@widgetbook.UseCase(name: 'Overflow — More', type: AnimatedRailMenu)
Widget railNavigationOverflow(BuildContext context) {
  final limit = context.knobs.double.slider(
    label: 'Limit',
    initialValue: 4,
    min: 2,
    max: 7,
  );
  final horizontal = context.knobs.boolean(
    label: 'Horizontal',
    initialValue: true,
  );
  final transitionName = context.knobs.object.dropdown<String>(
    label: 'Transition',
    options: _transitions.keys.toList(),
    initialOption: 'crossFade',
  );
  final spacing = context.knobs.boolean(
    label: 'Expanded Spacing',
    initialValue: true,
  );

  return _OverflowHost(
    direction: horizontal ? RailDirection.horizontal : RailDirection.vertical,
    limit: limit.toInt(),
    transition: _transitions[transitionName]!,
    spacing: spacing ? MenuIconSpacing.expanded : MenuIconSpacing.collapsed,
  );
}

@widgetbook.UseCase(name: 'Haptic Feedback', type: AnimatedRailMenu)
Widget railNavigationHaptic(BuildContext context) {
  final hapticName = context.knobs.object.dropdown<String>(
    label: 'Haptic Intensity',
    options: _haptics.keys.toList(),
    initialOption: 'light',
  );
  final transitionName = context.knobs.object.dropdown<String>(
    label: 'Transition',
    options: _transitions.keys.toList(),
    initialOption: 'crossFade',
  );
  final spacing = context.knobs.boolean(
    label: 'Expanded Spacing',
    initialValue: true,
  );

  return _HapticHost(
    haptic: _haptics[hapticName]!,
    transition: _transitions[transitionName]!,
    spacing: spacing ? MenuIconSpacing.expanded : MenuIconSpacing.collapsed,
  );
}
