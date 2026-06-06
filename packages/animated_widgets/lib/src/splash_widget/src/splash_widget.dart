// packages/animated_widgets/lib/src/splash_widget/splash_widget.dart

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';

/// Signature for the callback invoked when [SplashWidget]'s display duration
/// elapses.
///
/// Return `true` to transition to [SplashWidget.indeterminate], or `false` to
/// keep displaying [SplashWidget.splash].
typedef CompletedCallback = bool Function();

@deprecated
class SplashWidget extends StatefulWidget {
  @deprecated
  const SplashWidget({
    required this.splash,
    required this.displayDuration,
    required this.onDisplayComplete,
    super.key,
    this.indeterminate = const CircularProgressIndicator.adaptive(),
    this.transitionDuration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  });

  final Widget splash;
  final Widget indeterminate;
  final Duration displayDuration;
  final Duration transitionDuration;
  final CompletedCallback onDisplayComplete;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  static const _kInderminateKey = ValueKey<String>('indeterminate');
  static const _kChildKey = ValueKey<String>('child');

  late final Timer _timer;
  var _showIndeterminate = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.displayDuration, _onComplete);
  }

  void _onComplete() {
    final shouldShowSpinner = widget.onDisplayComplete();
    if (shouldShowSpinner && mounted) {
      setState(() => _showIndeterminate = true);
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
      child: _showIndeterminate
          ? KeyedSubtree(
              key: _kInderminateKey,
              child: widget.indeterminate,
            )
          : KeyedSubtree(
              key: _kChildKey,
              child: widget.splash,
            ),
    );
  }
}
