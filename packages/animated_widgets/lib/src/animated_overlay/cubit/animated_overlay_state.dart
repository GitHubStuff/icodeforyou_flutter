// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

class AnimatedOverlayState {
  const AnimatedOverlayState({this.child, this.opacity = 1.0});

  const AnimatedOverlayState.hidden() : child = null, opacity = 1.0;

  final Widget? child;
  final double opacity;

  AnimatedOverlayState copyWith({Widget? child, double? opacity}) =>
      AnimatedOverlayState(
        child: child ?? this.child,
        opacity: opacity ?? this.opacity,
      );
}
