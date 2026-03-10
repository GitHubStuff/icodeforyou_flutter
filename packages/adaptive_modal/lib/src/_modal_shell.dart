// lib/src/_modal_shell.dart
// ---------------------------------------------------------------------------
// _modal_shell.dart — the floating modal widget rendered in the Overlay.
//
// Single responsibility: given a placement, animation, and config, render
// the visible modal container with the close button and caller-supplied child.
//
// Knows nothing about OverlayEntry management, barrier, or the controller.
// ---------------------------------------------------------------------------

import 'package:adaptive_modal/src/_overlay_manager.dart' show OverlayManager;
import 'package:adaptive_modal/src/_platform_detector.dart';
import 'package:adaptive_modal/src/_position_resolver.dart';
import 'package:adaptive_modal/src/types.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// _ModalShell
// ---------------------------------------------------------------------------

/// The visible modal container rendered inside an [OverlayEntry].
///
/// Handles:
/// - Full-screen layout on phone
/// - Constrained, anchored layout on large surfaces
/// - Fade + scale animation with origin derived from [ModalPlacement.position]
/// - Close button in the top-right corner
class ModalShell extends StatelessWidget {
  /// Constructor
  const ModalShell({
    required this.child,
    required this.placement,
    required this.config,
    required this.animation,
    required this.onClose,
    required this.isPhone,
    super.key,
  });

  /// Caller-supplied modal content.
  final Widget child;

  /// Resolved screen-space position and side.
  final ModalPlacement placement;

  /// Modal configuration (sizes, close icon, animation curve).
  final AdaptiveModalConfig config;

  /// Animation driving opacity and scale — provided by [OverlayManager].
  final Animation<double> animation;

  /// Called when the close button is tapped.
  final VoidCallback onClose;

  /// True when the current form factor is [FormFactor.phone].
  final bool isPhone;

  // ---------------------------------------------------------------------------
  // Scale alignment
  // ---------------------------------------------------------------------------

  /// Derives the [Alignment] for the scale animation origin.
  ///
  /// On phone the modal grows from the bottom-center (slide-up feel).
  /// When placed below the anchor it grows from the top-center.
  /// When placed above the anchor it grows from the bottom-center.
  Alignment get _scaleAlignment {
    switch (placement.position) {
      case AdaptiveModalPosition.fullScreen:
        return Alignment.bottomCenter;
      case AdaptiveModalPosition.below:
        return Alignment.topCenter;
      case AdaptiveModalPosition.above:
        return Alignment.bottomCenter;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return isPhone ? _buildPhone(context) : _buildLarge(context);
  }

  // ---------------------------------------------------------------------------
  // Phone layout — fills the screen
  // ---------------------------------------------------------------------------

  Widget _buildPhone(BuildContext context) {
    return _AnimatedShell(
      animation: animation,
      scaleAlignment: _scaleAlignment,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                top: 8,
                right: 8,
                child: _CloseButton(
                  icon: config.closeIcon,
                  onClose: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Large layout — constrained and positioned near anchor
  // ---------------------------------------------------------------------------

  Widget _buildLarge(BuildContext context) {
    return Positioned(
      left: placement.left,
      top: placement.top,
      child: _AnimatedShell(
        animation: animation,
        scaleAlignment: _scaleAlignment,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: config.maxWidth,
              height: config.maxHeight,
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _CloseButton(
                      icon: config.closeIcon,
                      onClose: onClose,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AnimatedShell
// ---------------------------------------------------------------------------

/// Applies the fade + scale animation to its [child].
class _AnimatedShell extends StatelessWidget {
  const _AnimatedShell({
    required this.animation,
    required this.scaleAlignment,
    required this.child,
  });

  final Animation<double> animation;
  final Alignment scaleAlignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.85, end: 1).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: scale,
        alignment: scaleAlignment,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CloseButton
// ---------------------------------------------------------------------------

/// Tappable close button rendered in the top-right corner of the modal.
///
// ignore: comment_references
/// Uses [config.closeIcon] when provided, otherwise defaults to [Icons.close].
class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.icon,
    required this.onClose,
  });

  final Widget? icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: icon ?? const Icon(Icons.close),
      ),
    );
  }
}
