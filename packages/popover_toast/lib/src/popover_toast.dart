// packages/popover_toast/lib/src/popover_toast.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

/// A transient popover presented over a translucent barrier.
///
/// Present it with [show]. The returned future completes with the value
/// the [child] pops with, or with `null` when [duration] elapses or the
/// user taps the barrier while [barrierDismissible] is `true`.
///
/// The [child] is fully interactive: taps on it never dismiss the popover,
/// only taps on the barrier around it do. When [barrierDismissible] is
/// `false` the system back button and back gesture are blocked as well, so
/// nothing but [duration] (or the [child] itself) can dismiss it.
class PopoverToast<T> extends StatefulWidget {
  /// Creates the popover content; prefer [show] to present it.
  const PopoverToast({
    required this.child,
    this.duration = defaultDuration,
    this.barrierDismissible = true,
    this.alignment = Alignment.center,
    this.barrierColor = defaultBarrierColor,
    super.key,
  });

  /// How long the popover stays visible when not dismissed earlier.
  static const Duration defaultDuration = Duration(milliseconds: 750);

  /// Dark barrier that lets a little of the screen behind show through.
  static const Color defaultBarrierColor = Colors.black87;

  static const Duration _transitionDuration = Duration(milliseconds: 150);

  /// The widget displayed on top of the barrier.
  final Widget child;

  /// How long the popover stays visible.
  final Duration duration;

  /// When `true` a tap on the barrier, or the system back action,
  /// dismisses the popover immediately.
  final bool barrierDismissible;

  /// Where [child] sits within the barrier; `Alignment.center` by default.
  ///
  /// A [FractionalOffset] is accepted too, for 0…1 offsets from the
  /// top-left corner.
  final Alignment alignment;

  /// The color painted over the screen behind [child].
  final Color barrierColor;

  /// Presents a [PopoverToast] above the current route.
  ///
  /// Completes with the value [child] pops with, or `null` when dismissed
  /// by [duration], a barrier tap, or the system back action.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    Duration duration = defaultDuration,
    bool barrierDismissible = true,
    Alignment alignment = Alignment.center,
    Color barrierColor = defaultBarrierColor,
    HapticIntensity haptic = HapticIntensity.primary,
  }) {
    haptic.trigger();

    return showGeneralDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      transitionDuration: _transitionDuration,
      pageBuilder: (_, __, ___) => PopoverToast<T>(
        duration: duration,
        barrierDismissible: barrierDismissible,
        alignment: alignment,
        barrierColor: barrierColor,
        child: child,
      ),
    );
  }

  @override
  State<PopoverToast<T>> createState() => _PopoverToastState<T>();
}

class _PopoverToastState<T> extends State<PopoverToast<T>> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.barrierDismissible,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.barrierDismissible ? _dismiss : null,
            child: ColoredBox(color: widget.barrierColor),
          ),
          Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: widget.alignment,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
