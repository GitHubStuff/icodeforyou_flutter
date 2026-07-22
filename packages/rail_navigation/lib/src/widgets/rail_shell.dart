// packages/rail_navigation/lib/src/widgets/rail_shell.dart

import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_widget.dart';

part 'rail_shell_choreographies.dart';
part 'rail_shell_stack.dart';

/// Mirrors `RailWidget`'s default main-axis spacing.
const double _kDefaultRailSpacing = 8;

/// Mirrors `RailWidget`'s default cross-axis extent.
const double _kDefaultRailExtent = 80;

/// The default duration of the screen-switch transition.
const Duration _kDefaultTransitionDuration = Duration(milliseconds: 750);

/// How screens transition when a [RailShell]'s current index changes.
///
/// All transitions are presentation only: the underlying stack keeps
/// every screen alive, and no screen is ever rebuilt or disposed by a
/// switch.
enum RailTransition {
  /// Screens switch instantly with no animation.
  none,

  /// The incoming screen fades and slightly scales in over the shell's
  /// surface; the outgoing screen is removed instantly.
  fadeIn,

  /// Material 3 fade-through: the outgoing screen fades out during the
  /// first part of the duration, then the incoming screen fades and
  /// scales in over the remainder. The two never overlap, so there is
  /// no muddy mid-transition frame. The Material-recommended
  /// transition for peer navigation destinations, and the default.
  fadeThrough,

  /// Material 3 shared axis: the outgoing screen slides and fades away
  /// while the incoming screen slides in from the opposite side.
  ///
  /// Direction follows index order — a higher index enters from the
  /// trailing side — and the slide axis follows the rail's placement:
  /// horizontal under a bottom rail, vertical beside a side rail, so
  /// the motion always mirrors the rail's own geometry.
  sharedAxis,
}

/// A shell that keeps a `RailWidget` fixed to a screen edge while
/// displaying one of [screens] in the remaining space.
///
/// The shell displays; it never decides. [currentIndex] selects which
/// screen is visible, and the shell has no callbacks and no knowledge
/// of taps: the parent owns selection, wiring each rail button's
/// `onPressed` to update its own state and rebuild the shell with the
/// new index — the same radio-group contract used everywhere in this
/// package.
///
/// Screens are held in a state-preserving stack: switching keeps every
/// screen alive (scroll positions, form input). Switches animate per
/// [transition] over [transitionDuration]; transitions are
/// presentation only and never rebuild or dispose screens. Switches
/// are instant when [transition] is [RailTransition.none], when
/// [transitionDuration] is [Duration.zero], or when the platform
/// requests reduced motion.
///
/// Conventions for [screens] — deliberately unenforced; any [Widget]
/// is a valid screen:
///
/// * A screen owns its whole vertical: its own [Scaffold], app bar,
///   actions, floating action button, drawer. The shell reads nothing
///   from it and supplies nothing to it. The shell paints a plain
///   theme surface behind the stack, so a screen with no chrome of its
///   own still sits on a sensible background.
/// * A screen should not supply its own bottom navigation bar under
///   [RailPlacement.bottom]; the rail already occupies that edge.
/// * A screen is a stack member, not a route: leaving it means the
///   parent changes [currentIndex], not `Navigator.pop`. Pushing
///   detail routes on top of the shell is fine.
/// * Every screen is built and kept alive: `initState` runs for all
///   screens up front, and off-screen screens retain their
///   subscriptions. Screens doing heavy work should gate it on
///   visibility.
/// * Screens receive dependencies through the app's usual injection,
///   never through shell plumbing.
///
/// The shell also prevents double consumption of safe-area insets: the
/// rail consumes the insets of the edge it hugs, so the shell strips
/// that edge's padding from the content region. For a left rail the
/// content no longer sees the left (notch) inset, and mirrored for a
/// right rail; for a bottom rail the [Scaffold.bottomNavigationBar]
/// slot handles this natively.
class RailShell extends StatelessWidget {
  /// Creates a [RailShell].
  RailShell({
    required this.railChildren,
    required this.screens,
    required this.currentIndex,
    super.key,
    this.placement = RailPlacement.bottom,
    this.transition = RailTransition.fadeThrough,
    this.transitionDuration = _kDefaultTransitionDuration,
    this.railAlignment,
    this.railSpacing = _kDefaultRailSpacing,
    this.railBackgroundColor,
    this.railExtent = _kDefaultRailExtent,
  }) : assert(
         currentIndex >= 0 && currentIndex < screens.length,
         'currentIndex must index into screens.',
       );

  /// The buttons (and any interleaved widgets) placed on the rail,
  /// fully wired by the parent. See `RailWidget.children`.
  final List<Widget> railChildren;

  /// The screens the shell can display. The screen for a destination
  /// reached through an overflow popover belongs here like any other;
  /// the stack does not care where its button lives.
  final List<Widget> screens;

  /// The index into [screens] of the screen currently displayed.
  final int currentIndex;

  /// Where the rail is anchored. See `RailWidget.placement`. Defaults
  /// to [RailPlacement.bottom].
  final RailPlacement placement;

  /// How screens animate when [currentIndex] changes.
  ///
  /// Defaults to [RailTransition.fadeThrough].
  final RailTransition transition;

  /// How long the screen-switch transition runs.
  ///
  /// Defaults to [_kDefaultTransitionDuration]. [Duration.zero] makes
  /// every transition instant.
  final Duration transitionDuration;

  /// See `RailWidget.alignment`.
  final MainAxisAlignment? railAlignment;

  /// See `RailWidget.spacing`.
  final double railSpacing;

  /// See `RailWidget.backgroundColor`.
  final Color? railBackgroundColor;

  /// See `RailWidget.extent`.
  final double railExtent;

  @override
  Widget build(BuildContext context) {
    final rail = RailWidget(
      placement: placement,
      alignment: railAlignment,
      spacing: railSpacing,
      backgroundColor: railBackgroundColor,
      extent: railExtent,
      children: railChildren,
    );
    final content = Material(
      color: Theme.of(context).colorScheme.surface,
      child: _TransitioningIndexedStack(
        index: currentIndex,
        transition: transition,
        duration: transitionDuration,
        slideAxis: placement == RailPlacement.bottom
            ? Axis.horizontal
            : Axis.vertical,
        children: screens,
      ),
    );

    return switch (placement) {
      RailPlacement.bottom => Scaffold(
        body: content,
        bottomNavigationBar: rail,
      ),
      RailPlacement.left => Row(
        children: [
          rail,
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              child: content,
            ),
          ),
        ],
      ),
      RailPlacement.right => Row(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeRight: true,
              child: content,
            ),
          ),
          rail,
        ],
      ),
    };
  }
}
