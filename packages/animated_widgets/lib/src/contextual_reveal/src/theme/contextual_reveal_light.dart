// animated_widgets/lib/src/contextual_reveal/src/theme/contextual_reveal_light.dart
import 'dart:ui' show lerpDouble;

import 'package:animated_widgets/src/contextual_reveal/src/theme/_contextual_reveal_defaults.dart';
import 'package:animated_widgets/src/contextual_reveal/src/theme/contextual_reveal_theme.dart';
import 'package:flutter/material.dart';

part '_contextual_reveal_light_copy.dart';

/// The default light-mode implementation of [ContextualRevealTheme].
class ContextualRevealLight extends ContextualRevealTheme {
  /// Creates a [ContextualRevealLight] theme.
  const ContextualRevealLight();

  @override
  Widget? get backButton => null;

  @override
  Color get barrierColor => kLightBarrierColor;

  @override
  Duration get fadeInDuration => kFadeInDuration;

  @override
  Duration get fadeOutDuration => kFadeOutDuration;

  @override
  Color get popoverBackgroundShade => kLightPopoverBackground;

  @override
  double get popoverGap => kPopoverGap;

  @override
  Duration get showDuration => kShowDuration;

  @override
  ContextualRevealLight copyWith({
    Color? barrierColor,
    Color? popoverBackgroundShade,
    double? popoverGap,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    Duration? showDuration,
    Widget? backButton,
  }) => _ContextualRevealLightCopy(
    barrierColor: barrierColor ?? this.barrierColor,
    popoverBackgroundShade:
        popoverBackgroundShade ?? this.popoverBackgroundShade,
    popoverGap: popoverGap ?? this.popoverGap,
    fadeInDuration: fadeInDuration ?? this.fadeInDuration,
    fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
    showDuration: showDuration ?? this.showDuration,
    backButton: backButton ?? this.backButton,
  );

  @override
  ContextualRevealTheme lerp(
    ContextualRevealTheme? other,
    double t,
  ) {
    if (other is! ContextualRevealTheme) return this;
    return _ContextualRevealLightCopy(
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t)!,
      popoverBackgroundShade: Color.lerp(
        popoverBackgroundShade,
        other.popoverBackgroundShade,
        t,
      )!,
      popoverGap: lerpDouble(popoverGap, other.popoverGap, t) ?? popoverGap,
      fadeInDuration: t < 0.5 ? fadeInDuration : other.fadeInDuration,
      fadeOutDuration: t < 0.5 ? fadeOutDuration : other.fadeOutDuration,
      showDuration: t < 0.5 ? showDuration : other.showDuration,
      backButton: t < 0.5 ? backButton : other.backButton,
    );
  }
}
