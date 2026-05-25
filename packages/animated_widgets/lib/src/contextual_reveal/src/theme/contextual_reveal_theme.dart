// animated_widgets/lib/src/contextual_reveal/contextual_reveal_theme.dart
import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart'
    show ContextualPosition, ContextualReveal;
import 'package:animated_widgets/src/contextual_reveal/src/theme/theme.dart'
    show ContextualRevealDark, ContextualRevealLight;
import 'package:flutter/material.dart';

/// Abstract [ThemeExtension] that defines the visual properties for
/// the [ContextualReveal] widget.
///
/// Use [ContextualRevealTheme.of] to resolve the theme from the current
/// [BuildContext], falling back to [ContextualRevealLight] or
/// [ContextualRevealDark] based on platform brightness.
abstract class ContextualRevealTheme
    extends ThemeExtension<ContextualRevealTheme> {
  /// Creates a [ContextualRevealTheme].
  const ContextualRevealTheme();

  /// Returns a [ContextualRevealTheme] using the dark colour scheme.
  factory ContextualRevealTheme.dark() => const ContextualRevealDark();

  /// Returns a [ContextualRevealTheme] using the light colour scheme.
  factory ContextualRevealTheme.light() => const ContextualRevealLight();

  /// The colour of the modal barrier behind the revealed content.
  Color get barrierColor;

  /// The background shade applied to the popover surface.
  Color get popoverBackgroundShade;

  /// The gap in logical pixels between the anchor widget and the popover.
  double get popoverGap;

  /// The duration of the popover fade-in animation.
  Duration get fadeInDuration;

  /// The duration of the popover fade-out animation.
  Duration get fadeOutDuration;

  /// How long the popover remains fully visible before dismissing.
  Duration get showDuration;

  /// Overrides the platform default back button for [ContextualPosition.push].
  ///
  /// If null the platform default [BackButton] is used.
  Widget? get backButton;

  /// Resolves the [ContextualRevealTheme] from the nearest [Theme].
  ///
  /// Falls back to [ContextualRevealDark] or [ContextualRevealLight]
  /// based on the current [Brightness] if no extension is registered.
  static ContextualRevealTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<ContextualRevealTheme>();
    if (theme != null) return theme;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const ContextualRevealDark()
        : const ContextualRevealLight();
  }
}
