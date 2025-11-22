// app_splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'loading_error.dart';
import 'splash_screen_cubit.dart';
import 'splash_screen_state.dart';

/// A full-screen splash screen widget that manages app initialization.
///
/// This widget displays a black screen with a fade-in animation for the
/// [animationWidget]. It coordinates with [SplashScreenCubit] to handle
/// async initialization, error states, and transitions to the main app.
class AppSplashScreen extends StatefulWidget {
  /// The widget to animate in (fades from 0.0 to 1.0 opacity).
  final Widget animationWidget;

  /// How long the fade-in animation should take.
  final Duration animationDuration;

  /// The main app widget to display after successful initialization.
  final Widget newRootWidget;

  /// Builder function that creates an error widget when errors occur.
  /// Receives the [LoadingError] with message and optional details.
  final Widget Function(LoadingError error) errorWidgetBuilder;

  /// Maximum time to wait for dismiss signal after animation completes.
  /// If exceeded, a timeout error is generated.
  final Duration timeoutDuration;

  /// Widget to display while waiting for dismiss signal after animation completes.
  final Widget spinnerWidget;

  /// Color of the barrier overlay between splash screen and spinner.
  final Color barrierColor;

  /// The animation curve for the fade-in effect.
  final Curve fadeInCurve;

  const AppSplashScreen({
    super.key,
    required this.animationWidget,
    required this.animationDuration,
    required this.newRootWidget,
    required this.errorWidgetBuilder,
    required this.timeoutDuration,
    required this.spinnerWidget,
    this.barrierColor = const Color(0x66FF9800),
    this.fadeInCurve = Curves.easeInOut,
  });

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _kCrossFadeDuration = Duration(milliseconds: 500);
  static const Duration _kErrorSlideDuration = Duration(milliseconds: 300);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _notifyAnimationStarted();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: widget.fadeInCurve,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        SplashScreenCubit.instance.notifyAnimationCompleted();
      }
    });

    _animationController.forward();
  }

  void _notifyAnimationStarted() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SplashScreenCubit.instance.notifyAnimationStarted();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: BlocBuilder<SplashScreenCubit, SplashScreenState>(
          bloc: SplashScreenCubit.instance,
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: _getTransitionDuration(state),
              transitionBuilder: (child, animation) {
                return _buildTransition(child, animation, state);
              },
              child: _buildContent(state),
            );
          },
        ),
      ),
    );
  }

  Duration _getTransitionDuration(SplashScreenState state) {
    if (state is SplashScreenShowError) {
      return _kErrorSlideDuration;
    }
    if (state is SplashScreenReadyToDismiss) {
      return _kCrossFadeDuration;
    }
    return Duration.zero;
  }

  Widget _buildTransition(
    Widget child,
    Animation<double> animation,
    SplashScreenState state,
  ) {
    if (state is SplashScreenShowError) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  Widget _buildContent(SplashScreenState state) {
    return switch (state) {
      SplashScreenInitial() ||
      SplashScreenAnimatingInProgress() =>
        _buildSplashContent(key: const ValueKey('splash')),
      SplashScreenShowingSpinner() =>
        _buildSpinnerContent(key: const ValueKey('spinner')),
      SplashScreenReadyToDismiss() =>
        _buildNewRootContent(key: const ValueKey('newRoot')),
      SplashScreenShowError() =>
        _buildErrorContent(state, key: const ValueKey('error')),
    };
  }

  Widget _buildSplashContent({required Key key}) {
    return Material(
      key: key,
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.animationWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildSpinnerContent({required Key key}) {
    return Material(
      key: key,
      color: Colors.black,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: widget.animationWidget,
              ),
            ),
            Container(
              color: widget.barrierColor,
              child: Center(
                child: widget.spinnerWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRootContent({required Key key}) {
    return KeyedSubtree(
      key: key,
      child: widget.newRootWidget,
    );
  }

  Widget _buildErrorContent(
    SplashScreenShowError state, {
    required Key key,
  }) {
    return KeyedSubtree(
      key: key,
      child: widget.errorWidgetBuilder(state.error),
    );
  }
}
