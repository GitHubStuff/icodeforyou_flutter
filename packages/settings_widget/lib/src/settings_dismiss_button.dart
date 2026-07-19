// packages/settings_widget/lib/src/settings_dismiss_button.dart
import 'package:flutter/material.dart';

/// The close affordance for the settings surface: a top-right-aligned
/// [IconButton] bearing [Icons.close].
///
/// This is the **only** dismissal control the settings surface provides —
/// the package deliberately ships no confirmation dialogs and no undo, so
/// tapping this button dismisses immediately and unconditionally. Any
/// "are you sure?" logic a host app wants must live in its own [onDismiss]
/// callback, not here.
///
/// ## Layout
///
/// The button wraps itself in an [Align] pinned to [Alignment.topRight],
/// which means:
///
/// * Inside a stretched [Column] (as in `SettingsContent`, where
///   `crossAxisAlignment: CrossAxisAlignment.stretch` is in force), the
///   [Align] absorbs the full width and parks the button at the trailing
///   edge — no `Row` + `Spacer` scaffolding required at the call site.
/// * The alignment is physical top-**right**, not text-direction-aware
///   top-end; it does not mirror under RTL locales.
///
/// [IconButton] supplies the Material touch target (48×48 minimum),
/// ripple, and focus/hover treatment; this widget adds no styling of its
/// own, so it inherits [IconTheme] and [Theme] from context and adapts to
/// light/dark automatically.
///
/// ## Responsibilities
///
/// Presentation only. This widget owns no state, performs no navigation,
/// and never decides *how* dismissal happens — it merely reports the tap
/// through [onDismiss]. The caller pops the route, hides the overlay, or
/// collapses the sheet as appropriate. One widget, one job.
///
/// ## Example
///
/// ```dart
/// SettingsDismissButton(
///   onDismiss: () => Navigator.of(context).pop(),
/// )
/// ```
class SettingsDismissButton extends StatelessWidget {
  /// Creates the settings surface's close button.
  const SettingsDismissButton({required this.onDismiss, super.key});

  /// Invoked immediately when the close icon is tapped.
  ///
  /// Required and non-nullable: a dismiss button that cannot dismiss is a
  /// contradiction, so a disabled state is intentionally unrepresentable.
  /// Typically pops the enclosing route or reverses the settings
  /// transition; fires on every tap with no debounce or confirmation.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(icon: const Icon(Icons.close), onPressed: onDismiss),
    );
  }
}
