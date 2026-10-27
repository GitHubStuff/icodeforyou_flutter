// packages/app_navigation/lib/src/widgets/more_nav_button.dart

import 'package:app_navigation/app_navigation.dart' show NavButtonProperties;
import 'package:app_navigation/src/widgets/nav_button.dart' show NavButton;
import 'package:flutter/material.dart';

/// {@template more_nav_button}
/// The `more` button of a dock: a [NavButton] for [item] that, when
/// tapped, opens a popover above itself listing [overflow].
///
/// Each popover row is `[icon if any] [caption if any]`, at least one
/// button [size] tall. The row for [selected] is filled with the theme's
/// primary colour with "on primary" content and a bold caption — the
/// same treatment [NavButton] gives a selected dock button. Picking a
/// row fires the row's haptic, closes the popover, and reports the
/// row's destination through [onSelect]. Tapping outside the popover
/// closes it and reports nothing — the user cancelled.
///
/// The button draws itself selected when [selected] is one of the
/// [overflow] destinations, since that destination has no button of its
/// own on the dock. The button never reports [item] itself; `more` is
/// chrome, not a destination.
///
/// A null [onSelect] or an empty [overflow] disables the button.
///
/// Built on [MenuAnchor], which is confined to this file: the popover
/// rises above the anchor because the dock sits at the bottom edge and
/// [MenuAnchor] flips to whichever side has room, it is clamped inside
/// the screen horizontally, and it scrolls when taller than the screen
/// allows. Every row is at least [popoverWidthFactor] button widths
/// wide, so the popover is too.
/// {@endtemplate}
class MoreNavButton<T extends NavButtonProperties> extends StatelessWidget {
  /// {@macro more_nav_button}
  const MoreNavButton({
    required this.item,
    required this.size,
    required this.overflow,
    required this.onSelect,
    this.selected,
    super.key,
  });

  /// Minimum popover row width, in multiples of [size]'s width.
  static const double popoverWidthFactor = 2.5;

  /// The `more` destination this button represents.
  final T item;

  /// Footprint of the button; shared with every button on the dock.
  final Size size;

  /// Destinations listed in the popover, in display order.
  final List<T> overflow;

  /// Invoked with the destination picked from the popover. `null`
  /// disables the button.
  final ValueChanged<T>? onSelect;

  /// The current destination, or `null` for none.
  final T? selected;

  bool get _enabled => onSelect != null && overflow.isNotEmpty;

  bool get _selected => selected != null && overflow.contains(selected);

  Size get _rowMinimumSize =>
      Size(size.width * popoverWidthFactor, size.height);

  void _toggle(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
      return;
    }
    controller.open();
  }

  void _pick(T destination) {
    destination.haptic.trigger();
    onSelect!(destination);
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      consumeOutsideTap: true,
      menuChildren: [
        for (final destination in overflow)
          _OverflowRow<T>(
            key: ValueKey<T>(destination),
            destination: destination,
            minimumSize: _rowMinimumSize,
            selected: destination == selected,
            onPressed: _enabled ? () => _pick(destination) : null,
          ),
      ],
      builder: (context, controller, child) => NavButton<T>(
        item: item,
        size: size,
        selected: _selected,
        onTap: _enabled ? (_) => _toggle(controller) : null,
      ),
    );
  }
}

/// One row of the `more` popover: the destination's icon, if any,
/// followed by its caption, if any. Filled with the primary colour when
/// [selected]. Never smaller than [minimumSize].
class _OverflowRow<T extends NavButtonProperties> extends StatelessWidget {
  const _OverflowRow({
    required this.destination,
    required this.minimumSize,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final T destination;
  final Size minimumSize;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    final background = selected ? scheme.primary : Colors.transparent;

    final iconData = destination.iconData;
    final caption = destination.caption;

    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        minimumSize: minimumSize,
        foregroundColor: foreground,
        backgroundColor: background,
      ),
      leadingIcon: iconData == null ? null : Icon(iconData, color: foreground),
      child: caption == null
          ? const SizedBox.shrink()
          : Text(
              caption,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
    );
  }
}
