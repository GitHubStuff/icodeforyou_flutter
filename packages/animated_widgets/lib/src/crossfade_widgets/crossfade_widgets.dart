// packages/animated_widgets/lib/src/crossfade_widgets/crossfade_widgets.dart

import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalController, DirectionalSliderAndButtons, StepperTheme;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'crossfade_axis.dart';
import 'crossfade_widgets_cubit.dart' show CrossFadeWidgetsCubit;

/// {@template animated_widgets.cross_fade_widgets}
/// A stepper-driven cross-fade carousel.
///
/// Displays one of [children] at a time and animates between them with an
/// [AnimatedSwitcher] cross-fade whenever the active index changes. Below the
/// active child it renders a [DirectionalSliderAndButtons] — `(−)` / `(+)`
/// stepper buttons with a slider — through which the user drives the index.
/// {@endtemplate}
///
/// ## Degenerate cases
///
/// With fewer than two children there is nothing to fade between, so no
/// stepper, controller, or cubit is created:
///
///  * An empty [children] list renders [SizedBox.shrink].
///  * A single child renders that child directly, unwrapped.
///
/// ## Theming
///
/// [duration] and [buttonSize] each override the theme when non-null; when
/// null they resolve via [StepperTheme.of], which itself falls back to the
/// package defaults when no [StepperTheme] is registered on
/// [ThemeData.extensions]. Precedence, highest first: constructor argument
/// → registered [StepperTheme] → built-in defaults. See [StepperTheme] for
/// the defaults and how to register an override.
///
/// ## Orientation
///
/// [direction] mirrors the stepper row: with [CrossFadeAxis.left] the first
/// child sits at the left end of the slider and `(+)` steps rightward; with
/// [CrossFadeAxis.right] the row is mirrored. The cross-fade itself is
/// unaffected — only the stepper layout flips.
///
/// ## State
///
/// The active index is owned by an internal [CrossFadeWidgetsCubit] created
/// per widget instance; it is not externally settable and always starts at
/// the first child. Observe changes through [onIndexChanged].
///
/// ## Example
///
/// ```dart
/// CrossFadeWidgets(
///   onIndexChanged: (index) => debugPrint('now showing $index'),
///   children: const [
///     Text('First'),
///     Text('Second'),
///     Text('Third'),
///   ],
/// )
/// ```
///
/// See also:
///
///  * [StepperTheme], the [ThemeExtension] supplying the default duration
///    and button size.
///  * [AnimatedSwitcher], which performs the cross-fade itself.
class CrossFadeWidgets extends StatelessWidget {
  /// Creates a [CrossFadeWidgets].
  ///
  /// [children] is required but may be empty; see the class documentation
  /// for degenerate-case behavior. All other parameters are optional.
  ///
  /// {@macro animated_widgets.cross_fade_widgets.button_size}
  ///
  /// {@macro animated_widgets.cross_fade_widgets.duration}
  ///
  /// {@macro animated_widgets.cross_fade_widgets.direction}
  ///
  /// {@macro animated_widgets.cross_fade_widgets.on_index_changed}
  const CrossFadeWidgets({
    required this.children,
    super.key,
    this.buttonSize,
    this.duration,
    this.direction = CrossFadeAxis.left,
    this.onIndexChanged,
  });

  /// {@template animated_widgets.cross_fade_widgets.children}
  /// The widgets to cross-fade between, in stepper order.
  ///
  /// Index 0 is shown first. Each child is keyed internally by its index
  /// (via [KeyedSubtree] and [ValueKey]) so [AnimatedSwitcher] treats every
  /// index change as a child swap — including between children of the same
  /// runtime type.
  /// {@endtemplate}
  final List<Widget> children;

  /// {@template animated_widgets.cross_fade_widgets.button_size}
  /// Diameter of the `(−)` / `(+)` stepper buttons, in logical pixels.
  ///
  /// When null, resolves from [StepperTheme.buttonSize].
  /// {@endtemplate}
  final double? buttonSize;

  /// {@template animated_widgets.cross_fade_widgets.duration}
  /// Duration of the cross-fade between children.
  ///
  /// When null, resolves from [StepperTheme.crossFadeDuration].
  /// {@endtemplate}
  final Duration? duration;

  /// {@template animated_widgets.cross_fade_widgets.direction}
  /// Which horizontal end of the stepper is "forward".
  ///
  /// [CrossFadeAxis.left] (the default) places the minimum — the first
  /// child — at the left end of the slider, so `(+)` steps rightward.
  /// [CrossFadeAxis.right] mirrors the row. Affects only the stepper
  /// layout, never the cross-fade animation.
  /// {@endtemplate}
  final CrossFadeAxis direction;

  /// {@template animated_widgets.cross_fade_widgets.on_index_changed}
  /// Invoked with the index of the child now being displayed, each time the
  /// active child changes. Not called for the initial child.
  /// {@endtemplate}
  final void Function(int index)? onIndexChanged;

  @override
  Widget build(BuildContext context) {
    // Nothing to fade to/from with fewer than two children: show the only
    // child (or nothing) without a slider, controller, or cubit.
    if (children.length < 2) {
      return children.isEmpty ? const SizedBox.shrink() : children.first;
    }

    return _StepperCrossFade(
      duration: duration ?? StepperTheme.of(context).crossFadeDuration,
      direction: direction,
      onIndexChanged: onIndexChanged,
      buttonSize: buttonSize,
      children: children,
    );
  }
}

/// Stateful interior used only when there are >= 2 children.
///
/// Owns the [DirectionalController] lifecycle and provides the
/// [CrossFadeWidgetsCubit] to the subtree. Split out of [CrossFadeWidgets]
/// so the public widget stays stateless and the degenerate cases never pay
/// for a controller or cubit they cannot use.
class _StepperCrossFade extends StatefulWidget {
  const _StepperCrossFade({
    required this.children,
    required this.duration,
    required this.direction,
    required this.onIndexChanged,
    this.buttonSize,
  });

  /// See [CrossFadeWidgets.children].
  final List<Widget> children;

  /// The effective cross-fade duration, already resolved against
  /// [StepperTheme] by [CrossFadeWidgets.build]; never null here.
  final Duration duration;

  /// See [CrossFadeWidgets.direction].
  final CrossFadeAxis direction;

  /// See [CrossFadeWidgets.onIndexChanged].
  final void Function(int index)? onIndexChanged;

  /// Unresolved button size; null defers to [StepperTheme.buttonSize] at
  /// the point of use in [_StepperCrossFadeBody].
  final double? buttonSize;

  @override
  State<_StepperCrossFade> createState() => _StepperCrossFadeState();
}

/// State for [_StepperCrossFade].
///
/// Creates the [DirectionalController] in [initState] and disposes it in
/// [dispose], guaranteeing exactly one controller per widget lifetime.
class _StepperCrossFadeState extends State<_StepperCrossFade> {
  late final DirectionalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DirectionalController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrossFadeWidgetsCubit(
        controller: _controller,
        length: widget.children.length,
        onIndexChanged: widget.onIndexChanged,
      ),
      child: _StepperCrossFadeBody(
        controller: _controller,
        duration: widget.duration,
        direction: widget.direction,
        buttonSize: widget.buttonSize,
        children: widget.children,
      ),
    );
  }
}

/// Layout body below the [BlocProvider].
///
/// Split from [_StepperCrossFadeState.build] so [BuildContext] lookups of
/// [CrossFadeWidgetsCubit] occur under the provider, and so the
/// [BlocBuilder] rebuild scope is limited to the [AnimatedSwitcher] — the
/// stepper row does not rebuild on index changes.
class _StepperCrossFadeBody extends StatelessWidget {
  const _StepperCrossFadeBody({
    required this.controller,
    required this.children,
    required this.duration,
    required this.direction,
    required this.buttonSize,
  });

  /// The controller shared between the cubit (which listens to it) and the
  /// [DirectionalSliderAndButtons] (which drives it).
  final DirectionalController controller;

  /// See [CrossFadeWidgets.children].
  final List<Widget> children;

  /// The effective cross-fade duration; already theme-resolved.
  final Duration duration;

  /// Stepper orientation, translated to
  /// [DirectionalSliderAndButtons.minValueFirst]: [CrossFadeAxis.left] puts
  /// the minimum (first child) on the left; [CrossFadeAxis.right] mirrors
  /// the row.
  final CrossFadeAxis direction;

  /// Unresolved button size; falls back to [StepperTheme.buttonSize] when
  /// null.
  final double? buttonSize;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CrossFadeWidgetsCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CrossFadeWidgetsCubit, int>(
          builder: (context, index) {
            return AnimatedSwitcher(
              duration: duration,
              child: KeyedSubtree(
                key: ValueKey(index),
                child: children[index],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        DirectionalSliderAndButtons(
          controller: controller,
          buttonSize: buttonSize ?? StepperTheme.of(context).buttonSize,
          minValueFirst: direction == CrossFadeAxis.left,
          min: cubit.min,
          max: cubit.max,
          step: cubit.step,
        ),
      ],
    );
  }
}
