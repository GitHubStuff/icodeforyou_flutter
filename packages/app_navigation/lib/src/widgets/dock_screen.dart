// packages/app_navigation/lib/src/widgets/dock_screen.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot, NavigationCubit, NavigationState;
import 'package:app_navigation/src/utils/button_list_manager.dart'
    show ButtonListManager;
import 'package:app_navigation/src/widgets/dock_row.dart' show DockRow;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template dock_screen}
/// A screen whose bottom edge is a [DockRow] and whose body is the
/// current destination's view.
///
/// Owns the single [Scaffold]. The body is an [IndexedStack] over every
/// destination except [more], in [buttons] order; each `viewBuilder`
/// runs exactly once, so destinations keep their state when the user
/// switches between them.
///
/// The dock's width comes from a [LayoutBuilder]; [size] is the shared
/// footprint of ONE button, not the width of the bottom edge. On every
/// layout the buttons are run through [ButtonListManager.organize] and
/// split at [more]: what precedes it (and [more] itself) is the dock,
/// what follows is handed to the row as its overflow.
///
/// Selection is read from the nearest [NavigationCubit]. The cubit
/// stores an enum member *name*; it is resolved against [buttons] here,
/// and a name with no match — including the cubit's empty initial name
/// — resolves to [initial]. Taps report the tapped member's name back
/// to the cubit. The row receives the resolved destination and decides
/// for itself which button to highlight.
/// {@endtemplate}
class DockScreen<T extends NavButtonProperties> extends StatefulWidget {
  /// {@macro dock_screen}
  ///
  /// [more] must have [NavSlot.more]; [initial] must not. Both are
  /// checked when the state is created and throw [ArgumentError].
  const DockScreen({
    required this.buttons,
    required this.more,
    required this.initial,
    required this.size,
    super.key,
  });

  /// Every destination, in display order (e.g. `DockItems.order`).
  /// May or may not contain [more].
  final List<T> buttons;

  /// The `more` affordance (e.g. `DockItems.more`).
  final T more;

  /// Destination shown when the cubit's name matches nothing in
  /// [buttons] (e.g. `DockItems.initial`).
  final T initial;

  /// Footprint shared by every button (e.g. `DockItems.size`).
  final Size size;

  @override
  State<DockScreen<T>> createState() => _DockScreenState<T>();
}

class _DockScreenState<T extends NavButtonProperties>
    extends State<DockScreen<T>> {
  late final List<T> _destinations = widget.buttons
      .where((item) => item.slot != NavSlot.more)
      .toList(growable: false);

  late final List<Widget> _views = [
    for (final item in _destinations) item.viewBuilder(),
  ];

  late final ButtonListManager<T> _manager = ButtonListManager<T>(
    more: widget.more,
    buttonWidth: widget.size.width,
  );

  @override
  void initState() {
    super.initState();
    if (widget.more.slot != NavSlot.more) {
      throw ArgumentError.value(
        widget.more,
        'more',
        'must have NavSlot.more, has ${widget.more.slot}',
      );
    }
    if (widget.initial.slot == NavSlot.more) {
      throw ArgumentError.value(
        widget.initial,
        'initial',
        'must not have NavSlot.more',
      );
    }
  }

  T _resolve(NavigationState state) => _destinations.firstWhere(
    (item) => item.name == state.destinationName,
    orElse: () => widget.initial,
  );

  void _select(BuildContext context, T item) {
    if (item.slot == NavSlot.more) return;
    context.read<NavigationCubit>().select(item.name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final selected = _resolve(state);

        return LayoutBuilder(
          builder: (context, constraints) {
            final organized = _manager.organize(
              widget.buttons,
              constraints.maxWidth,
            );
            final cut = organized.indexOf(widget.more);
            final dock = cut < 0 ? organized : organized.sublist(0, cut + 1);
            final overflow = cut < 0
                ? const <Never>[]
                : organized.sublist(cut + 1);

            return Scaffold(
              body: IndexedStack(
                index: _destinations.indexOf(selected),
                children: _views,
              ),
              bottomNavigationBar: Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: DockRow<T>(
                  buttons: dock,
                  overflow: overflow,
                  size: widget.size,
                  onTap: (item) => _select(context, item),
                  selected: selected,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
