// packages/app_navigation/lib/src/widgets/button_widget.dart

import 'package:app_navigation/app_navigation.dart' show NavButtonProperties;
import 'package:flutter/material.dart';

/// {@template nav_button}
/// A tappable rendering of a single [NavButtonProperties] destination:
/// the item's [NavButtonProperties.iconData] above its
/// [NavButtonProperties.caption], inside an [InkWell] sized to [size].
///
/// Pure presentation. The button does not know which destination is
/// selected (the parent passes [selected]) and never calls
/// [NavButtonProperties.viewBuilder]; updating the screen body belongs
/// to whichever widget owns selection. On tap it fires the item's
/// [NavButtonProperties.haptic] and then reports the item through
/// [onTap].
///
/// A null [onTap] disables the button: no ink, no haptic, no callback.
/// {@endtemplate}
class NavButton<T extends NavButtonProperties> extends StatelessWidget {
  /// {@macro nav_button}
  const NavButton({
    required this.item,
    required this.size,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  /// The destination this button represents.
  final T item;

  /// Fixed footprint of the button. Every button on a surface shares
  /// one size; the caller supplies it (e.g. `DockItems.size`).
  final Size size;

  /// Invoked with [item] after the haptic fires. `null` disables the
  /// button.
  final ValueChanged<T>? onTap;

  /// Whether this destination is the one currently shown.
  final bool selected;

  bool get _enabled => onTap != null;

  void _handleTap() {
    item.haptic.trigger();
    onTap!(item);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = selected ? scheme.primary : scheme.onSurfaceVariant;
    final iconData = item.iconData;
    final caption = item.caption;

    return Semantics(
      button: true,
      selected: selected,
      enabled: _enabled,
      label: caption,
      child: SizedBox.fromSize(
        size: size,
        child: InkWell(
          onTap: _enabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(size.shortestSide / 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null) Icon(iconData, color: tint),
              if (caption != null)
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: tint),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
