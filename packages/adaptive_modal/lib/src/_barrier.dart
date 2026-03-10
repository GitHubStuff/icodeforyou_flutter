// lib/src/_barrier.dart
// ---------------------------------------------------------------------------
// _barrier.dart — the full-screen barrier rendered behind the modal.
//
// Single responsibility: render a colored, optionally tappable full-screen
// layer beneath the modal OverlayEntry.
//
// Only inserted into the Overlay when barrierDismissible is true.
// When background interaction is required no barrier is inserted at all —
// this widget is never instantiated in that case.
// ---------------------------------------------------------------------------

// ignore_for_file: document_ignores, comment_references

import 'package:adaptive_modal/src/_overlay_manager.dart' show OverlayManager;
import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// _BarrierWidget
// ---------------------------------------------------------------------------

/// Full-screen barrier rendered beneath the modal.
///
/// Fades in and out in sync with the modal animation via [opacity].
///
/// When [onDismiss] is provided, tapping anywhere on the barrier calls it.
/// The [OverlayManager] supplies [onDismiss] only when [barrierDismissible]
/// is true — which is always the case when this widget is used, since the
/// barrier is never inserted otherwise.
class BarrierWidget extends StatelessWidget {
  /// Constructor
  const BarrierWidget({
    required this.color,
    required this.opacity,
    required this.onDismiss,
    super.key,
  });

  /// The barrier color at full opacity.
  final Color color;

  /// Current animation opacity — driven by the modal's [AnimationController].
  final Animation<double> opacity;

  /// Called when the barrier is tapped.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: SizedBox.expand(
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}
