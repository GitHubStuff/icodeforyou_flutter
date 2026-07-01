// // packages/animated_widgets/lib/src/combination_animation/widgets/combination_animation_single.dart
// // ignore_for_file: public_member_api_docs

// import 'package:animated_widgets/src/combination_animation/constants/combination_animation_constants.dart'
//     show
//         kCombinationAnimationDefaultCurve,
//         kCombinationAnimationDefaultDuration;
// import 'package:animated_widgets/src/combination_animation/steps/combination_animation_frame_builder.dart'
//     show buildCombinationAnimationFrame;
// import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
//     show AnimationTween;
// import 'package:flutter/widgets.dart';

// /// Animates [child] through a [scale] [AnimationTween], and optionally through
// /// an [opacity] [AnimationTween], over the given [duration] using [curve].
// ///
// /// The [Opacity] widget is omitted from the tree entirely when [opacity]
// /// is `null`, avoiding an unnecessary compositing layer.
// class CombinationAnimationX extends StatelessWidget {
//   const CombinationAnimationX({
//     required this.scale,
//     required this.child,
//     this.opacity,
//     this.curve = kCombinationAnimationDefaultCurve,
//     this.duration = kCombinationAnimationDefaultDuration,
//     this.onComplete,
//     super.key,
//   });

//   final AnimationTween scale;
//   final AnimationTween? opacity;
//   final Curve curve;
//   final Duration duration;
//   final Widget child;
//   final VoidCallback? onComplete;

//   @override
//   Widget build(BuildContext context) {
//     assert(
//       opacity == null || opacity!.isValidOpacity,
//       opacity!.invalidTweenMessage,
//     );
//     return TweenAnimationBuilder<double>(
//       tween: Tween<double>(begin: 0, end: 1),
//       duration: duration,
//       onEnd: onComplete,
//       curve: curve,
//       child: child,
//       builder: (context, t, child) => buildCombinationAnimationFrame(
//         t: t,
//         scale: scale,
//         opacity: opacity,
//         child: child!,
//       ),
//     );
//   }
// }
