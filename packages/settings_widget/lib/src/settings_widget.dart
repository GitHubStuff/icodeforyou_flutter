// packages/settings_widget/lib/src/settings_widget.dart
import 'package:flutter/material.dart';
import 'package:settings_widget/src/app_settings_entry.dart';
import 'package:settings_widget/src/settings_direction.dart';
import 'package:settings_widget/src/settings_layout.dart';
import 'package:settings_widget/src/settings_sheet.dart';
import 'package:settings_widget/src/settings_transition.dart';

/// Default viewport width, in logical pixels, at and above which
/// [SettingsWidget.show] uses the tablet presentation.
///
/// 600 is Material Design's boundary between the **compact** and **medium**
/// window size classes: below it, virtually every phone in portrait gets
/// the full-bleed, [SafeArea]-wrapped phone sheet; at 600 and above —
/// tablets, foldables opened flat, phones in landscape, desktop windows —
/// the surface becomes a centered, padded floating panel.
///
/// Passed to `SettingsSheet.breakpoint` when the caller does not supply
/// their own; override per call to align with the host app's layout grid.
const double kSettingsBreakpoint = 600;

/// The package's single entry point: presents the settings surface as a
/// modal overlay via [show].
///
/// Declared `abstract final` — it cannot be instantiated, extended, or
/// implemented; it exists purely as a namespace for [show]. All
/// composition happens there:
///
/// * [showGeneralDialog] hosts the overlay (dimmed [Colors.black54]
///   barrier, 300 ms transition).
/// * `SettingsLayout` anchors and dresses the surface per direction.
/// * `SettingsSheet` adapts phone/tablet presentation at the breakpoint.
/// * `SettingsTransition` slides the surface in from its anchor edge.
///
/// The barrier is **not** dismissible — [barrierDismissible] is false by
/// design, so the close button inside the sheet is the only way out,
/// consistent with the package's single-dismissal-affordance contract.
abstract final class SettingsWidget {
  /// Default inset, in logical pixels, between the surface and its anchor
  /// edge when the caller does not supply `edgeGap`.
  static const double _defaultEdgeGap = 16;

  /// Presents the settings surface as a modal overlay.
  ///
  /// Composes the full stack — layout, adaptive sheet, slide transition —
  /// over a dimmed, non-dismissible barrier, and returns the [Future] from
  /// [showGeneralDialog], which completes when the surface is popped.
  ///
  /// ## Parameters
  ///
  /// * [entries] — the settings rows, in display order. Required.
  /// * [title] — heading widget; defaults to a bold 24pt `'Settings...'`
  ///   [Text]. `SettingsContent` applies the same bold-24 style to any
  ///   title via [DefaultTextStyle.merge], so a plain unstyled [Text] is
  ///   sufficient here.
  /// * [breakpoint] — viewport width, in logical pixels, at which the
  ///   tablet presentation engages ([SettingsSheet] compares with `>=`).
  ///   Defaults to [kSettingsBreakpoint] (600), the Material
  ///   compact/medium boundary: phones in portrait fall below it and get
  ///   the full-bleed phone sheet; tablets, unfolded foldables, landscape
  ///   phones, and desktop windows meet it and get the centered floating
  ///   panel. Because the width is re-read every build, rotating or
  ///   resizing across this value swaps presentations live.
  /// * [direction] — the anchor edge and slide-in origin; defaults to
  ///   [SettingsDirection.bottom], the conventional sheet entrance.
  /// * [edgeGap] — inset from the anchor edge; defaults to
  ///   [_defaultEdgeGap] (16). Pass `0` for a flush sheet.
  /// * [useRootNavigator] — when `true`, the dialog route is pushed on the
  ///   root [Navigator] and the dismiss pop targets that same root, letting
  ///   the surface cover nested-navigator chrome such as bottom tabs.
  ///   Defaults to `false` (nearest navigator). The push and the pop
  ///   resolve this flag identically — keep them in lockstep if this
  ///   method is ever refactored, or dismissal will pop the wrong route.
  ///
  /// ## Dismissal
  ///
  /// Only the sheet's close button dismisses: it pops the navigator
  /// selected by [useRootNavigator], resolved from the *caller's* [context]
  /// captured at show-time. The barrier ignores taps and there is no
  /// implicit back-gesture handling beyond what the route provides.
  static Future<void> show(
    BuildContext context, {
    required List<AppSettingsEntry> entries,
    Widget title = const Text(
      'Settings...',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    double breakpoint = kSettingsBreakpoint,
    SettingsDirection direction = SettingsDirection.bottom,
    double edgeGap = _defaultEdgeGap,
    bool useRootNavigator = false,
  }) {
    return showGeneralDialog<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      barrierLabel: 'Settings',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => SettingsLayout(
        direction: direction,
        edgeGap: edgeGap,
        child: SettingsSheet(
          title: title,
          entries: entries,
          onDismiss: () => Navigator.of(
            context,
            rootNavigator: useRootNavigator,
          ).pop(),
          breakpoint: breakpoint,
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SettingsTransition(
        animation: animation,
        direction: direction,
        child: child,
      ),
    );
  }
}
