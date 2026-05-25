// animated_widgets/lib/src/contextual_reveal/src/theme/contextual_reveal_dark.dart
import 'dart:ui' show lerpDouble;

import 'package:animated_widgets/src/contextual_reveal/src/theme/_contextual_reveal_defaults.dart';
import 'package:animated_widgets/src/contextual_reveal/src/theme/contextual_reveal_theme.dart';
import 'package:flutter/material.dart';

part '_contextual_reveal_dark_copy.dart';

/// The default dark [ContextualRevealTheme] implementation.
class ContextualRevealDark extends ContextualRevealTheme {
  /// Creates a [ContextualRevealDark] theme with default dark values.
  const ContextualRevealDark();

  @override
  Widget? get backButton => null;

  @override
  Color get barrierColor => kDarkBarrierColor;

  @override
  Duration get fadeInDuration => kFadeInDuration;

  @override
  Duration get fadeOutDuration => kFadeOutDuration;

  @override
  Color get popoverBackgroundShade => kDarkPopoverBackground;

  @override
  double get popoverGap => kPopoverGap;

  @override
  Duration get showDuration => kShowDuration;

  @override
  ContextualRevealDark copyWith({
    Color? barrierColor,
    Color? popoverBackgroundShade,
    double? popoverGap,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    Duration? showDuration,
    Widget? backButton,
  }) => _ContextualRevealDarkCopy(
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
    return _ContextualRevealDarkCopy(
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
