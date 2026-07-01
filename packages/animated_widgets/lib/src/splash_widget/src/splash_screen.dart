// packages/animated_widgets/lib/src/splash_widget/src/splash_screen.dart
// ignore_for_file: always_use_package_imports

import 'package:custom_widgets/custom_widgets.dart' show UninheritedText;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'splash_cubit.dart' show SplashCubit;
import 'splash_state.dart'
    show
        BackgroundTaskFailed,
        IndeterminateShowing,
        LandingShowing,
        SplashShowing,
        SplashState,
        TimedOut;

/// A splash flow that renders [splashWidget], then an optional
/// [intermediateWidget] while host background tasks complete, then
/// [landingPage].
///
/// The flow is one-shot: once [landingPage] is reached, the cubit is
/// terminal and the splash, intermediate, and timeout widgets will never be
/// shown again for the lifetime of this [SplashScreen].
///
/// If any background task fails, [backgroundTaskFailedWidgetBuilder] is shown.
/// If the indeterminate phase exceeds the configured timeout, [timeoutWidget]
/// is shown.
///
/// The host application is responsible for providing a [SplashCubit] above
/// this widget via [BlocProvider] and for supplying the [tasks] that gate
/// the transition to [landingPage].
///
/// All non-landing phases are rendered full-screen and centered. Callers do
/// not need to wrap [splashWidget], [intermediateWidget], or [timeoutWidget]
/// in [Center] or [SizedBox.expand]; [SplashScreen] owns that layout
/// contract.
class SplashScreen extends StatefulWidget {
  /// Creates a splash flow.
  const SplashScreen({
    required this.splashWidget,
    required this.landingPage,
    required this.tasks,
    this.intermediateWidget,
    this.timeoutWidget,
    this.backgroundTaskFailedWidgetBuilder,
    super.key,
  });

  /// The widget shown during the initial splash phase. Rendered full-screen
  /// and centered.
  final Widget splashWidget;

  /// The widget shown after the splash duration elapses and all background
  /// tasks complete successfully. Rendered as-is (occupies the full screen
  /// and is responsible for its own layout).
  final Widget landingPage;

  /// The background tasks gating the transition to [landingPage].
  ///
  /// These futures must already be running when passed in; [SplashScreen]
  /// observes them but does not start them. The list is consumed once in
  /// `initState` and changes to it on subsequent rebuilds are ignored.
  final List<Future<void>> tasks;

  /// The widget shown during the indeterminate phase. Defaults to an
  /// adaptive circular progress indicator. Rendered full-screen and
  /// centered.
  final Widget? intermediateWidget;

  /// The widget shown when the indeterminate phase exceeds the configured
  /// timeout. Defaults to a plain `Time Out` text. Rendered full-screen and
  /// centered.
  final Widget? timeoutWidget;

  /// Builder for the widget shown when any background task fails.
  ///
  /// Receives the first error and its stack trace. Defaults to a plain text
  /// message. Rendered full-screen and centered.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )?
  backgroundTaskFailedWidgetBuilder;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final String timeoutText;
  late final String backgroundFailText;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SplashCubit>();
    timeoutText = cubit.config.timeoutText;
    backgroundFailText = cubit.config.backgroundTaskFailedText;
    cubit.start(tasks: widget.tasks);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (context, state) {
        final config = context.read<SplashCubit>().config;
        return AnimatedSwitcher(
          duration: config.crossfadeDuration,
          layoutBuilder: _centeredLayoutBuilder,
          child: KeyedSubtree(
            key: ValueKey<Type>(state.runtimeType),
            child: _childFor(state),
          ),
        );
      },
    );
  }

  /// A layout builder that stacks the outgoing and incoming children
  /// centered and filling the available space, instead of the default
  /// top-start alignment used by [AnimatedSwitcher.defaultLayoutBuilder].
  static Widget _centeredLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  Widget _childFor(SplashState state) {
    return switch (state) {
      SplashShowing() => _centered(widget.splashWidget),
      IndeterminateShowing() => _centered(
        widget.intermediateWidget ?? const CircularProgressIndicator.adaptive(),
      ),
      LandingShowing() => widget.landingPage,
      TimedOut() => _centered(
        widget.timeoutWidget ?? UninheritedText(timeoutText),
      ),
      BackgroundTaskFailed(:final error, :final stackTrace) => _centered(
        widget.backgroundTaskFailedWidgetBuilder?.call(
              context,
              error,
              stackTrace,
            ) ??
            UninheritedText(backgroundFailText),
      ),
    };
  }

  /// Wraps [child] in a centered, full-screen container so callers do not
  /// have to know that [AnimatedSwitcher] stacks its children.
  Widget _centered(Widget child) {
    return SizedBox.expand(child: Center(child: child));
  }
}
