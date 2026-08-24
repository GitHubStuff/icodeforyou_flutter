// packages/animated_widgets/lib/src/fader_widget/src/fader_widget.dart

import 'package:animated_widgets/src/fader_widget/src/cubit/fader_cubit.dart'
    show FaderCubit, FaderState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Renders [FaderCubit]'s current string, fading on every change, and
/// reports the fade lifecycle back to the cubit.
///
/// The widget holds no traffic-control logic: it fades in whatever string
/// the cubit emits, tells the cubit when that fade starts
/// ([FaderCubit.fadeStarted]) and when it finishes
/// ([FaderCubit.fadeComplete]). The cubit decides what to emit next.
class FaderWidget extends StatelessWidget {
  /// Creates a [FaderWidget] driven by the provided [cubit].
  ///
  /// The [duration], [curve], and [style] dictate the visual presentation
  /// of the crossfade effect.
  const FaderWidget({
    required this.cubit,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
    this.style = const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    super.key,
  });

  /// The state management object controlling the strings to be displayed.
  final FaderCubit cubit;

  /// The length of time the crossfade transition takes to complete.
  final Duration duration;

  /// The easing curve applied to the crossfade animation.
  final Curve curve;

  /// The text style applied to the displayed string.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaderCubit, FaderState>(
      bloc: cubit,
      // React only to the displayed string changing — that is what triggers a
      // fade. isAnimating is the cubit's record of what we report, not a cue.
      listenWhen: (previous, current) => previous.current != current.current,
      listener: (context, state) {
        // A new string is about to fade in: report the fade has started.
        if (state.current != null) cubit.fadeStarted();
      },
      buildWhen: (previous, current) => previous.current != current.current,
      builder: (context, state) {
        final text = state.current ?? '';
        return AnimatedSwitcher(
          duration: duration,
          switchInCurve: curve,
          switchOutCurve: curve,
          // Overlap outgoing and incoming text so they truly crossfade.
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          ),
          // AnimatedSwitcher has no completion callback, so drive the fade
          // here and report completion when the incoming child settles.
          transitionBuilder: (child, animation) => _FadeReporter(
            animation: animation,
            onFadeIn: cubit.fadeComplete,
            child: child,
          ),
          child: Text(
            text,
            // Key on the text so AnimatedSwitcher fades on every change.
            key: ValueKey<String>(text),
            style: style,
          ),
        );
      },
    );
  }
}

/// Fades [child] using [animation] and calls [onFadeIn] once the incoming
/// fade has fully completed.
///
/// [AnimatedSwitcher] runs the incoming child's animation forward to enter,
/// so [AnimationStatus.completed] marks the moment the new string is fully
/// shown — the point at which the cubit should be told the fade is done.
/// The outgoing child animates in reverse and is ignored here.
class _FadeReporter extends StatefulWidget {
  /// Creates an internal fade reporter to track animation completion.
  const _FadeReporter({
    required this.animation,
    required this.onFadeIn,
    required this.child,
  });

  /// The animation driving the opacity of the child.
  final Animation<double> animation;

  /// Callback triggered exactly once when the animation completes.
  final VoidCallback onFadeIn;

  /// The widget being faded in or out.
  final Widget child;

  @override
  State<_FadeReporter> createState() => _FadeReporterState();
}

class _FadeReporterState extends State<_FadeReporter> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus status) {
    // completed == the incoming child has finished fading in.
    if (!_reported && status == AnimationStatus.completed) {
      _reported = true;
      widget.onFadeIn();
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: widget.animation, child: widget.child);
}
