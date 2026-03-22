// animated_widgets/lib/src/contextual_reveal/contextual_reveal_theme.dart

import 'dart:ui';

import 'package:flutter/material.dart';

const _kFadeInDuration = Duration(milliseconds: 200);
const _kFadeOutDuration = Duration(milliseconds: 250);
const _kShowDuration = Duration(milliseconds: 750);
const _kPopoverGap = 8.0;

const _kLightBarrierColor = Color.fromARGB(175, 255, 255, 255);
const _kLightPopoverBackground = Color(0x00000000);

const _kDarkBarrierColor = Color.fromARGB(175, 0, 0, 0);
const _kDarkPopoverBackground = Color(0x00000000);

class ContextualRevealTheme extends ThemeExtension<ContextualRevealTheme> {
  const ContextualRevealTheme({
    required this.barrierColor,
    required this.popoverBackgroundShade,
    required this.popoverGap,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    required this.showDuration,
    this.backButton,
  });

  factory ContextualRevealTheme.light() => const ContextualRevealTheme(
    barrierColor: _kLightBarrierColor,
    popoverBackgroundShade: _kLightPopoverBackground,
    popoverGap: _kPopoverGap,
    fadeInDuration: _kFadeInDuration,
    fadeOutDuration: _kFadeOutDuration,
    showDuration: _kShowDuration,
  );

  factory ContextualRevealTheme.dark() => const ContextualRevealTheme(
    barrierColor: _kDarkBarrierColor,
    popoverBackgroundShade: _kDarkPopoverBackground,
    popoverGap: _kPopoverGap,
    fadeInDuration: _kFadeInDuration,
    fadeOutDuration: _kFadeOutDuration,
    showDuration: _kShowDuration,
  );

  static ContextualRevealTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<ContextualRevealTheme>();
    if (theme == null) {
      throw FlutterError(
        'ContextualRevealTheme not found in Theme.\n'
        'Add ContextualRevealTheme to ThemeData.extensions for both '
        'light and dark themes.\n'
        'Example:\n'
        '  theme: ThemeData(extensions: [ContextualRevealTheme.light()])\n'
        // ignore: missing_whitespace_between_adjacent_strings
        '  darkTheme: ThemeData.dark().copyWith('
        'extensions: [ContextualRevealTheme.dark()])',
      );
    }
    return theme;
  }

  final Color barrierColor;
  final Color popoverBackgroundShade;
  final double popoverGap;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration showDuration;

  /// Override the platform default back button for [ContextualPosition.push].
  /// If null the platform default [BackButton] is used.
  final Widget? backButton;

  @override
  ContextualRevealTheme copyWith({
    Color? barrierColor,
    Color? popoverBackgroundShade,
    double? popoverGap,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    Duration? showDuration,
    Widget? backButton,
  }) => ContextualRevealTheme(
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
    if (other == null) return this;
    return ContextualRevealTheme(
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
