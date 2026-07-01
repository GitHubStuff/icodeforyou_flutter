// packages/animated_widgets/lib/src/stepper_cross_fade/cross_fade_theme.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _buttonSize = 48;
const Duration _crossFadeDuration = Duration(milliseconds: 1250);

/// Theme defaults for [StepperCrossfade].
///
/// Register on [ThemeData.extensions] and read via [CrossFadeTheme.of], which
/// falls back to the built-in defaults when the extension is not registered.
@immutable
class CrossFadeTheme extends ThemeExtension<CrossFadeTheme>
    with EquatableMixin {
  const CrossFadeTheme({
    this.crossFadeDuration = _crossFadeDuration,
    this.buttonSize = _buttonSize,
  });

  /// Duration of the cross-fade between children. Defaults to 1250ms.
  final Duration crossFadeDuration;

  /// Diameter of the `(−)` / `(+)` stepper buttons. Defaults to 48.
  final double buttonSize;

  /// Resolves the [CrossFadeTheme] from [context], falling back to the
  /// built-in defaults when no extension is registered.
  // ignore: prefer_constructors_over_static_methods
  static CrossFadeTheme of(BuildContext context) =>
      Theme.of(context).extension<CrossFadeTheme>() ?? const CrossFadeTheme();

  @override
  CrossFadeTheme copyWith({Duration? crossFadeDuration, double? buttonSize}) {
    return CrossFadeTheme(
      crossFadeDuration: crossFadeDuration ?? this.crossFadeDuration,
      buttonSize: buttonSize ?? this.buttonSize,
    );
  }

  @override
  CrossFadeTheme lerp(covariant CrossFadeTheme? other, double t) {
    if (other == null) return this;
    return CrossFadeTheme(
      crossFadeDuration: lerpDuration(
        crossFadeDuration,
        other.crossFadeDuration,
        t,
      ),
      buttonSize: lerpDouble(buttonSize, other.buttonSize, t) ?? buttonSize,
    );
  }

  @override
  List<Object?> get props => [crossFadeDuration, buttonSize];
}
