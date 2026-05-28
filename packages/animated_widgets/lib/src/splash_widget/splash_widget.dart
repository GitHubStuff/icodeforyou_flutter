// packages/animated_widgets/lib/src/splash_widget/splash_widget.dart

import 'dart:async';

import 'package:flutter/material.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({
    required this.child,
    required this.displayDuration,
    required this.onDisplayComplete,
    super.key,
    this.spinner = const CircularProgressIndicator.adaptive(),
    this.transitionDuration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  });

  final Widget child;
  final Widget spinner;
  final Duration displayDuration;
  final Duration transitionDuration;
  final VoidCallback onDisplayComplete;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  late final Timer _timer;
  var _showSpinner = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.displayDuration, _onComplete);
  }

  void _onComplete() {
    widget.onDisplayComplete();
    if (mounted) {
      setState(() => _showSpinner = true);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      transitionBuilder: widget.transitionBuilder,
      child: _showSpinner
          ? KeyedSubtree(
              key: const ValueKey('spinner'),
              child: widget.spinner,
            )
          : KeyedSubtree(
              key: const ValueKey('child'),
              child: widget.child,
            ),
    );
  }
}
