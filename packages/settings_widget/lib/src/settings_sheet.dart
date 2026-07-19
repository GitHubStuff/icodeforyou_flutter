// packages/settings_widget/lib/src/settings_sheet.dart

import 'package:flutter/material.dart';
import 'package:settings_widget/src/app_settings_entry.dart';
import 'package:settings_widget/src/settings_content.dart';

/// The adaptive shell of the settings surface: chooses phone or tablet
/// presentation for a single shared [SettingsContent].
///
/// Reads the viewport width via [MediaQuery.sizeOf] each build and compares
/// it against [breakpoint]:
///
/// * **width < [breakpoint]** — phone presentation ([_PhoneSheet]): content
///   wrapped in [SafeArea] so it clears notches, home indicators, and
///   system UI on an edge-anchored sheet.
/// * **width ≥ [breakpoint]** — tablet presentation ([_TabletSheet]):
///   content centered inside generous fixed padding, reading as a floating
///   panel rather than a full-bleed sheet.
///
/// Because [MediaQuery.sizeOf] establishes a dependency, crossing the
/// breakpoint at runtime — rotation, window resize, foldable posture
/// change — rebuilds this widget and swaps presentations live, with the
/// same [SettingsContent] instance on both sides of the swap.
///
/// The class builds [SettingsContent] exactly once and hands it to whichever
/// shell wins, so the content composition is defined in one place and the
/// shells stay presentation-only.
class SettingsSheet extends StatelessWidget {
  /// Creates the adaptive settings shell.
  const SettingsSheet({
    required this.title,
    required this.entries,
    required this.onDismiss,
    required this.breakpoint,
    super.key,
  });

  /// The heading passed through to [SettingsContent], which styles it bold
  /// at 24pt; a plain [Text] suffices.
  final Widget title;

  /// The settings rows passed through to [SettingsContent], rendered in
  /// order with uniform spacing.
  final List<AppSettingsEntry> entries;

  /// Invoked when the user taps the close button inside [SettingsContent].
  ///
  /// Passed through untouched; typically pops the enclosing route or
  /// reverses the settings transition.
  final VoidCallback onDismiss;

  /// Viewport width, in logical pixels, at and above which the tablet
  /// presentation is used.
  ///
  /// Required rather than defaulted: the right value is a host-app design
  /// decision (Material guidance suggests 600 for the compact/medium
  /// boundary), and this package declines to guess it.
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= breakpoint;

    final content = SettingsContent(
      title: title,
      entries: entries,
      onDismiss: onDismiss,
    );

    if (isWide) return _TabletSheet(content: content);
    return _PhoneSheet(content: content);
  }
}

/// Phone presentation: [content] wrapped in [SafeArea].
///
/// On narrow viewports the sheet hugs a screen edge, so the [SafeArea]
/// keeps the dismiss button out of the status bar region and the last
/// entry clear of the home indicator. No padding is added — the sheet is
/// intentionally full-bleed at phone widths.
class _PhoneSheet extends StatelessWidget {
  /// Creates the phone shell around the shared settings content.
  const _PhoneSheet({required this.content});

  /// The [SettingsContent] built once by [SettingsSheet].
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: content);
  }
}

/// Tablet presentation: [content] centered within fixed padding.
///
/// [_padding] logical pixels on the left, right, and top, with the deeper
/// [_bottomPadding] below — the extra bottom inset lifts the panel's
/// optical center slightly above geometric center, where a centered
/// surface reads as balanced on large screens.
///
/// No [SafeArea] is used here: at tablet widths the padding alone exceeds
/// any system inset, so wrapping would be redundant nesting.
class _TabletSheet extends StatelessWidget {
  /// Creates the tablet shell around the shared settings content.
  const _TabletSheet({required this.content});

  /// The [SettingsContent] built once by [SettingsSheet].
  final Widget content;

  /// Inset, in logical pixels, on the left, right, and top edges.
  static const double _padding = 48;

  /// Inset, in logical pixels, on the bottom edge; deeper than [_padding]
  /// to raise the panel's optical center.
  static const double _bottomPadding = 96;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _padding,
        right: _padding,
        top: _padding,
        bottom: _bottomPadding,
      ),
      child: Center(child: content),
    );
  }
}
