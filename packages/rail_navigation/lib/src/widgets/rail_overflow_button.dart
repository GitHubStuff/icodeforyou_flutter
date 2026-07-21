// packages/rail_navigation/lib/src/widgets/rail_overflow_button.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button_more.dart';
import 'package:rail_navigation/src/widgets/rail_popover.dart';

/// The default caption label, mirroring `MoreRailButton`.
const String _kMoreLabel = 'More';

/// A self-contained overflow button for a `RailWidget`.
///
/// Drops into a `RailWidget`'s children like any other button — put it
/// last by convention. Visually it is a `MoreRailButton`; behaviorally
/// it anchors a `showRailPopover<T>` to itself when tapped, then
/// adapts the popover's `Future<T?>` contract to callback form:
/// a selection invokes [onSelected] with the tile's value, and every
/// dismissal path (barrier tap, back button, escape) invokes
/// [onCanceled], which defaults to a no-op.
///
/// The popover opens away from whichever screen edge the button is
/// nearest to, so no placement parameter is needed; anchoring derives
/// it from geometry. [popoverChildren] are typically
/// `RailPopoverTile<T>`s whose type parameter matches this widget's.
///
/// Callers wanting custom triggering can ignore this widget and wire a
/// plain `MoreRailButton` to `showRailPopover` themselves; this widget
/// is the batteries-included composition of the two.
class RailOverflowButton<T> extends StatelessWidget {
  /// Creates a [RailOverflowButton].
  const RailOverflowButton({
    required this.popoverChildren,
    required this.onSelected,
    super.key,
    this.onCanceled,
    this.initialScrollIndex = 0,
    this.caption = const Text(_kMoreLabel),
    this.size = const Size(48, 48),
    this.isSelected = false,
    this.tint,
    this.hapticIntensity = HapticIntensity.light,
    this.scrollHaptic = HapticIntensity.light,
  });

  /// The rows shown in the popover, typically `RailPopoverTile<T>`s.
  final List<Widget> popoverChildren;

  /// Called with the selected tile's value when the user picks one.
  final ValueChanged<T> onSelected;

  /// Called when the popover is dismissed without a selection.
  ///
  /// Covers every dismissal path: barrier tap, back button, escape.
  /// When `null`, cancellation is a no-op.
  final VoidCallback? onCanceled;

  /// The index into [popoverChildren] scrolled into view when the
  /// popover opens. See `showRailPopover.initialScrollIndex`.
  ///
  /// Pass the currently selected tile's index so its highlight is on
  /// screen from the first frame. Self-clamping; defaults to opening
  /// at the top.
  final int initialScrollIndex;

  /// See `MoreRailButton.caption`. Defaults to `Text('More')`; pass
  /// `null` for an icon-only button.
  final Widget? caption;

  /// See `RailButton.size`.
  final Size size;

  /// See `RailButton.isSelected`. Usually stays `false`: this button
  /// reveals overflow rather than navigating.
  final bool isSelected;

  /// See `RailButton.tint`.
  final Color? tint;

  /// The haptic feedback triggered when the button itself is tapped,
  /// immediately before the popover opens.
  ///
  /// Defaults to [HapticIntensity.light].
  final HapticIntensity hapticIntensity;

  /// The haptic feedback ticked as the popover list scrolls. See
  /// `showRailPopover.scrollHaptic`.
  ///
  /// Defaults to [HapticIntensity.light];
  /// [HapticIntensity.selection] is the subtlest, platform-intended
  /// scroll tick; [HapticIntensity.none] disables ticking.
  final HapticIntensity scrollHaptic;

  Future<void> _openPopover(BuildContext context) async {
    final result = await showRailPopover<T>(
      anchorContext: context,
      initialScrollIndex: initialScrollIndex,
      scrollHaptic: scrollHaptic,
      children: popoverChildren,
    );

    if (!context.mounted) return;

    if (result == null) {
      onCanceled?.call();
    } else {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MoreRailButton(
      onPressed: () => _openPopover(context),
      caption: caption,
      size: size,
      isSelected: isSelected,
      tint: tint,
      hapticIntensity: hapticIntensity,
    );
  }
}
