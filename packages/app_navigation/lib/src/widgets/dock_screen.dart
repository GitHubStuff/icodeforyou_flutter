// packages/app_navigation/lib/src/widgets/dock_screen.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/utils/button_list_manager.dart'
    show ButtonListManager;

import 'package:app_navigation/src/widgets/dock_row.dart' show DockRow;
import 'package:flutter/material.dart';

/// {@template dock_screen}
/// A screen whose bottom edge is a [DockRow] and whose body is the
/// current destination's view.
///
/// Owns the single [Scaffold]. The body is an [IndexedStack] over every
/// destination except `more`, in [buttons] order; each `viewBuilder`
/// runs exactly once, so destinations keep their state when the user
/// switches between them.
///
/// The dock's width comes from a [LayoutBuilder]; [size] is the shared
/// footprint of ONE button, not the width of the bottom edge.
///
/// Selection is plain widget state and starts at [initial].
/// {@endtemplate}
class DockScreen<T extends NavButtonProperties> extends StatefulWidget {
  /// {@macro dock_screen}
  const DockScreen({
    required this.buttons,
    required this.initial,
    required this.size,
    super.key,
  });

  /// Every destination, in display order (e.g. `DockItems.order`).
  final List<T> buttons;

  /// Destination shown first (e.g. `DockItems.initial`).
  final T initial;

  /// Footprint shared by every button (e.g. `DockItems.size`).
  final Size size;

  @override
  State<DockScreen<T>> createState() => _DockScreenState<T>();
}

class _DockScreenState<T extends NavButtonProperties>
    extends State<DockScreen<T>> {
  late T _selected = widget.initial;

  late final List<T> _destinations = widget.buttons
      .where((item) => item.slot != NavSlot.more)
      .toList(growable: false);

  late final List<Widget> _views = [
    for (final item in _destinations) item.viewBuilder(),
  ];

  void _select(T item) => setState(() => _selected = item);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = ButtonListManager<T>(
          buttons: widget.buttons,
          width: constraints.maxWidth,
          buttonWidth: widget.size.width,
        ).fitted();

        return Scaffold(
          body: IndexedStack(
            index: _destinations.indexOf(_selected),
            children: _views,
          ),
          bottomNavigationBar: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: DockRow<T>(
              buttons: fitted,
              size: widget.size,
              onTap: _select,
              highlighted: _selected,
            ),
          ),
        );
      },
    );
  }
}
