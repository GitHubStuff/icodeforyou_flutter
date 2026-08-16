// packages/custom_widgets/lib/src/stepper_theme/stepper_theme.dart

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _buttonSize = 48;
const Duration _crossFadeDuration = Duration(milliseconds: 1250);

/// {@template animated_widgets.cross_fade_theme}
/// Theme defaults for [StepperCrossfade].
///
/// A [ThemeExtension] that centralizes the visual and timing constants used
/// by [StepperCrossfade], allowing an application to override them once at
/// the [ThemeData] level rather than passing values through every widget
/// constructor.
/// {@endtemplate}
///
/// ## Registration
///
/// Register the extension on [ThemeData.extensions]:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const <ThemeExtension<dynamic>>[
///       StepperTheme(
///         crossFadeDuration: Duration(milliseconds: 800),
///         buttonSize: 56,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ## Resolution
///
/// Read the effective theme via [StepperTheme.of], which falls back to the
/// built-in defaults when the extension is not registered:
///
/// ```dart
/// final StepperTheme = StepperTheme.of(context);
/// final duration = StepperTheme.crossFadeDuration;
/// ```
///
/// ## Equality
///
/// Instances are value-comparable via [Equatable]: two instances with the
/// same [crossFadeDuration] and [buttonSize] are equal. This keeps theme
/// change detection cheap and prevents unnecessary rebuilds when an
/// identical theme is re-supplied.
///
/// See also:
///
///  * [ThemeExtension], the mechanism this class plugs into.
///  * [Theme.of], which surfaces registered extensions through
///    [ThemeData.extension].
@immutable
class StepperTheme extends ThemeExtension<StepperTheme> with Equatable {
  /// Creates a [StepperTheme].
  ///
  /// Both parameters are optional and default to the package's built-in
  /// values. Because every parameter has a const default, the entire theme
  /// can be constructed as a compile-time constant.
  ///
  /// {@macro animated_widgets.cross_fade_theme.cross_fade_duration}
  ///
  /// {@macro animated_widgets.cross_fade_theme.button_size}
  const StepperTheme({
    this.crossFadeDuration = _crossFadeDuration,
    this.buttonSize = _buttonSize,
  });

  /// {@template animated_widgets.cross_fade_theme.cross_fade_duration}
  /// Duration of the cross-fade between children.
  ///
  /// Applied to the fade-out of the outgoing child and the fade-in of the
  /// incoming child. Defaults to 1250 milliseconds.
  /// {@endtemplate}
  final Duration crossFadeDuration;

  /// {@template animated_widgets.cross_fade_theme.button_size}
  /// Diameter of the `(−)` / `(+)` stepper buttons, in logical pixels.
  ///
  /// Defaults to 48, matching the Material minimum touch-target size.
  /// Values below 48 may fail accessibility touch-target guidance.
  /// {@endtemplate}
  final double buttonSize;

  /// Resolves the [StepperTheme] from [context].
  ///
  /// {@template animated_widgets.cross_fade_theme.of}
  /// Looks up the extension registered on the ambient [ThemeData]. When no
  /// [StepperTheme] is registered, returns a const instance carrying the
  /// built-in defaults, so callers never need to null-check the result.
  ///
  /// This establishes an inherited-widget dependency on [Theme]; the calling
  /// widget rebuilds when the theme changes.
  /// {@endtemplate}
  // ignore: prefer_constructors_over_static_methods
  static StepperTheme of(BuildContext context) =>
      Theme.of(context).extension<StepperTheme>() ?? const StepperTheme();

  /// Creates a copy of this theme with the given fields replaced.
  ///
  /// Any parameter left null retains the value from this instance. Required
  /// by the [ThemeExtension] contract.
  ///
  /// {@macro animated_widgets.cross_fade_theme.cross_fade_duration}
  ///
  /// {@macro animated_widgets.cross_fade_theme.button_size}
  @override
  StepperTheme copyWith({Duration? crossFadeDuration, double? buttonSize}) {
    return StepperTheme(
      crossFadeDuration: crossFadeDuration ?? this.crossFadeDuration,
      buttonSize: buttonSize ?? this.buttonSize,
    );
  }

  /// Linearly interpolates between this theme and [other].
  ///
  /// Used by the framework during animated theme transitions (for example
  /// inside [AnimatedTheme]). Interpolates [crossFadeDuration] with
  /// [lerpDuration] and [buttonSize] with [lerpDouble], where `t` is the
  /// animation position: `t == 0.0` yields this theme, `t == 1.0` yields
  /// [other].
  ///
  /// Returns this instance unchanged when [other] is null.
  @override
  StepperTheme lerp(covariant StepperTheme? other, double t) {
    if (other == null) return this;
    return StepperTheme(
      crossFadeDuration: lerpDuration(
        crossFadeDuration,
        other.crossFadeDuration,
        t,
      ),
      buttonSize: lerpDouble(buttonSize, other.buttonSize, t) ?? buttonSize,
    );
  }

  /// The properties that participate in value equality: [crossFadeDuration]
  /// and [buttonSize].
  @override
  List<Object?> get props => [crossFadeDuration, buttonSize];
}
