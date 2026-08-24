// packages/animated_widgets/lib/src/contextual_reveal/src/theme/_contextual_reveal_light_copy.dart

part of 'contextual_reveal_light.dart';

class _ContextualRevealLightCopy extends ContextualRevealLight {
  _ContextualRevealLightCopy({
    required this._barrierColor,
    required this._popoverBackgroundShade,
    required this._popoverGap,
    required this._fadeInDuration,
    required this._fadeOutDuration,
    required this._showDuration,
    required Widget? backButton,
  }) : _backbutton = backButton;

  final Color _barrierColor;
  final Color _popoverBackgroundShade;
  final double _popoverGap;
  final Duration _fadeInDuration;
  final Duration _fadeOutDuration;
  final Duration _showDuration;
  final Widget? _backbutton;

  @override
  Color get barrierColor => _barrierColor;

  @override
  Duration get fadeInDuration => _fadeInDuration;

  @override
  Duration get fadeOutDuration => _fadeOutDuration;

  @override
  Color get popoverBackgroundShade => _popoverBackgroundShade;

  @override
  double get popoverGap => _popoverGap;

  @override
  Duration get showDuration => _showDuration;

  @override
  Widget? get backButton => _backbutton;
}
