// programs/since_when_dev/lib/splash/default_splash_art.dart
import 'package:flutter/widgets.dart';
import 'package:sequenced_animations/sequenced_animations.dart'
    show AnimationRange, SequencedGrow, SequencedOpacity, SequencedRotation;
import 'package:since_when_dev/gen/assets.gen.dart' show Assets;

class DefaultSplashArt extends StatelessWidget {
  /// {@macro default_splash_screen_child}
  const DefaultSplashArt({
    super.key,
  });

  @override
  Widget build(BuildContext context) => SequencedOpacity(
    ranges: _fadeRanges,
    child: SequencedRotation(
      ranges: _rotateRanges,
      child: SequencedGrow(
        ranges: _growRanges,
        child: Center(
          child: SizedBox.square(
            dimension: 240,
            child: ClipOval(child: Assets.iconer.image(fit: BoxFit.cover)),
          ),
        ),
      ),
    ),
  );
}

List<AnimationRange> _fadeRanges = [
  const AnimationRange(0.3, 0.5, duration: Duration(milliseconds: 950)),
  const AnimationRange(0.5, 1, duration: Duration(milliseconds: 100)),
];

List<AnimationRange> _growRanges = [
  const AnimationRange(0, 1.5, duration: Duration(milliseconds: 950)),
  const AnimationRange(1.5, 1, duration: Duration(milliseconds: 100)),
];

List<AnimationRange> _rotateRanges = [
  const AnimationRange(0.3, 0.85, duration: Duration(milliseconds: 850)),
  const AnimationRange(0.85, 1, duration: Duration(milliseconds: 200)),
];
