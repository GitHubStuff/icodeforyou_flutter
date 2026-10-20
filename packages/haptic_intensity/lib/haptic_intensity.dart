// packages/haptic_intensity/lib/haptic_intensity.dart
import 'dart:async' show unawaited;

import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart' show ValueChanged, VoidCallback;

/// The strength of haptic feedback a control gives when the user acts on it.
///
/// Each value maps to exactly one [HapticFeedback] call, so a widget can
/// expose the feedback it gives as a single, declarative parameter instead
/// of hard-coding a platform call:
///
/// ```dart
/// class MyButton extends StatelessWidget {
///   const MyButton({required this.onTap, this.haptic = .light, super.key});
///
///   final VoidCallback? onTap;
///   final HapticIntensity haptic;
///
///   @override
///   Widget build(BuildContext context) =>
///     IconButton(icon: const Icon(Icons.add), onPressed: haptic.wrap(onTap));
/// }
/// ```
///
/// ## Firing
///
/// [trigger] fires the feedback directly. [wrap] and [wrapValue] decorate a
/// callback so the feedback fires immediately before it runs; both pass a
/// `null` callback straight through, which keeps a disabled control disabled
/// without any extra branching at the call site.
///
/// ## Platform behaviour
///
/// Every call is fire-and-forget. [HapticFeedback] resolves to a no-op on
/// platforms without a haptic engine (desktop, web, the simulator), and
/// iOS and Android each interpret the impact strengths in their own way,
/// so treat the levels as relative intent, not a guaranteed sensation.
///
/// Use [none] to silence feedback while keeping the same wiring; it is the
/// right default for controls that fire on every pointer move, such as a
/// continuous slider.
enum HapticIntensity {
  /// A light impact, as [HapticFeedback.lightImpact].
  ///
  /// Suits frequent, low-stakes actions: stepping a value, toggling a chip.
  light,

  /// A medium impact, as [HapticFeedback.mediumImpact].
  ///
  /// Suits deliberate actions: confirming a choice, submitting a form.
  medium,

  /// A heavy impact, as [HapticFeedback.heavyImpact].
  ///
  /// Suits rare, significant actions: completing a flow, a destructive step.
  heavy,

  /// A selection click, as [HapticFeedback.selectionClick].
  ///
  /// The subtle tick platforms use when the user moves through a picker or
  /// segmented control.
  selection,

  /// A plain vibration, as [HapticFeedback.vibrate].
  ///
  /// Longer and less refined than the impacts; reserved for alerts rather
  /// than acknowledgements.
  vibrate,

  /// No feedback at all.
  ///
  /// [trigger] returns immediately and [wrap] and [wrapValue] still decorate
  /// their callbacks, so a caller can switch feedback off without changing
  /// how it wires the control.
  none;

  /// Fires the feedback for this intensity.
  ///
  /// Returns at once; the platform call is not awaited. [none] does nothing.
  void trigger() {
    switch (this) {
      case .light:
        unawaited(HapticFeedback.lightImpact());
      case .medium:
        unawaited(HapticFeedback.mediumImpact());
      case .heavy:
        unawaited(HapticFeedback.heavyImpact());
      case .selection:
        unawaited(HapticFeedback.selectionClick());
      case .vibrate:
        unawaited(HapticFeedback.vibrate());
      case .none:
        return;
    }
  }

  /// Decorates [callback] so this feedback fires immediately before it.
  ///
  /// Returns `null` when [callback] is `null`, so a control that treats a
  /// `null` callback as "disabled" (every Material button, for instance)
  /// stays disabled and gives no feedback:
  ///
  /// ```dart
  /// IconButton(
  ///   icon: const Icon(Icons.add),
  ///   onPressed: HapticIntensity.light.wrap(onTap),
  /// )
  /// ```
  ///
  /// The feedback fires on every invocation of the returned closure, and
  /// fires even when this is [none] in the sense that the closure is still
  /// created; only the platform call is skipped.
  ///
  /// See also:
  ///
  /// * [wrapValue], the same decoration for callbacks that take a value.
  VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;

    return () {
      trigger();
      callback();
    };
  }

  /// Decorates [callback] so this feedback fires immediately before it,
  /// for callbacks that receive a value.
  ///
  /// The counterpart of [wrap] for [ValueChanged] signatures such as
  /// `Switch.onChanged`, `Slider.onChanged` or
  /// `SegmentedButton.onSelectionChanged`. [T] is inferred from the
  /// callback, so no type argument is needed at the call site:
  ///
  /// ```dart
  /// Switch(
  ///   value: isOn,
  ///   onChanged: HapticIntensity.selection.wrapValue(onToggled),
  /// )
  /// ```
  ///
  /// Returns `null` when [callback] is `null`, preserving the control's
  /// disabled state exactly as [wrap] does.
  ValueChanged<T>? wrapValue<T>(ValueChanged<T>? callback) {
    if (callback == null) return null;

    return (value) {
      trigger();
      callback(value);
    };
  }
}
