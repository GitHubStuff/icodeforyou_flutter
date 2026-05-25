// animated_widgets/lib/src/contextual_reveal/contextual_reveal.dart
import 'dart:async';

import 'package:animated_widgets/src/contextual_reveal/src/contextual_position.dart';
import 'package:animated_widgets/src/contextual_reveal/src/theme/contextual_reveal_theme.dart';
import 'package:flutter/material.dart';

part '_contextual_reveal_state.dart';
part '_dismiss_wrapper.dart';
part '_popover_overlay.dart';
part '_push_route.dart';

/// A widget that reveals contextual child widgets in response to
/// tap, long-press, and double-tap gestures.
///
/// Each gesture type displays a different child widget, with placement
/// and dismissal behaviour controlled per gesture.
class ContextualReveal extends StatefulWidget {
  /// Creates a [ContextualReveal] with distinct children per gesture type.
  const ContextualReveal({
    required this.body,
    required this.tapChild,
    required this.longChild,
    required this.doubleChild,
    this.doublePosition = ContextualPosition.modal,
    super.key,
  });

  /// Creates a [ContextualReveal] where all three gestures share
  /// a single child.
  factory ContextualReveal.simple({
    required Widget body,
    required Widget sharedChild,
    Key? key,
  }) => ContextualReveal(
    body: body,
    longChild: sharedChild,
    doubleChild: sharedChild,
    doublePosition: ContextualPosition.modal,
    key: key,
    tapChild: sharedChild,
  );

  /// The primary content displayed beneath the gesture detector.
  final Widget body;

  /// Displayed on tap — non-interactive, dismissed after a timer or on tap.
  final Widget tapChild;

  /// Displayed while the widget is held — non-interactive,
  /// dismissed on release.
  final Widget longChild;

  /// Displayed on double-tap — always interactive.
  final Widget doubleChild;

  /// Controls the placement of [doubleChild] when revealed.
  ///
  /// Defaults to [ContextualPosition.modal].
  final ContextualPosition doublePosition;

  @override
  State<ContextualReveal> createState() => _ContextualRevealState();
}
