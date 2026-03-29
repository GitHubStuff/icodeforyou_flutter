part of 'contextual_reveal_dark.dart';

class _ContextualRevealDarkCopy extends ContextualRevealDark {
  _ContextualRevealDarkCopy({
    required Color barrierColor,
    required Color popoverBackgroundShade,
    required double popoverGap,
    required Duration fadeInDuration,
    required Duration fadeOutDuration,
    required Duration showDuration,
    required Widget? backButton,
  }) : _barrierColor = barrierColor,
       _popoverBackgroundShade = popoverBackgroundShade,
       _popoverGap = popoverGap,
       _fadeInDuration = fadeInDuration,
       _fadeOutDuration = fadeOutDuration,
       _showDuration = showDuration,
       _backbutton = backButton;

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
