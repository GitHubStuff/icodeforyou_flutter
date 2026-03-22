// animated_widgets/lib/src/contextual_reveal/contextual_reveal.dart

import 'dart:async';

import 'package:animated_widgets/src/contextual_reveal/contextual_position.dart';
import 'package:animated_widgets/src/contextual_reveal/contextual_reveal_theme.dart';
import 'package:flutter/material.dart';

part '_contextual_reveal_state.dart';
part '_dismiss_wrapper.dart';
part '_popover_overlay.dart';
part '_push_route.dart';

class ContextualReveal extends StatefulWidget {
  const ContextualReveal({
    required this.parent,
    required this.child,
    required this.longChild,
    required this.doubleChild,
    this.doublePosition = ContextualPosition.modal,
    super.key,
  });

  factory ContextualReveal.simple({
    required Widget parent,
    required Widget child,
    Key? key,
  }) => ContextualReveal(
    parent: parent,
    longChild: child,
    doubleChild: child,
    doublePosition: ContextualPosition.modal,
    key: key,
    child: child,
  );

  final Widget parent;

  /// Displayed on tap — non-interactive, dismissed after timer or on tap.
  final Widget child;

  /// Displayed while parent is held — non-interactive, dismissed on release.
  final Widget longChild;

  /// Displayed on double tap — always interactive.
  final Widget doubleChild;

  final ContextualPosition doublePosition;

  @override
  State<ContextualReveal> createState() => _ContextualRevealState();
}
