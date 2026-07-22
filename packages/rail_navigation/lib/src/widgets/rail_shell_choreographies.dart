// packages/rail_navigation/lib/src/widgets/rail_shell_choreographies.dart

part of 'rail_shell.dart';

/// The role a stack layer plays during a transition.
enum _LayerRole {
  /// The layer animating out; pointer-blocked, tickers paused.
  outgoing,

  /// The layer animating in; the visible, interactive child.
  incoming,
}

/// The animation bundle driving one layer's constant wrapper chain.
typedef _LayerAnimations = ({
  Animation<double> opacity,
  Animation<double> scale,
  Animation<Offset> translation,
});

/// A constant fully-opaque opacity.
const Animation<double> _kOpaque = AlwaysStoppedAnimation<double>(1);

/// A constant fully-transparent opacity.
const Animation<double> _kTransparent = AlwaysStoppedAnimation<double>(0);

/// A constant identity scale.
const Animation<double> _kUnitScale = AlwaysStoppedAnimation<double>(1);

/// A constant zero translation.
const Animation<Offset> _kNoTranslation = AlwaysStoppedAnimation<Offset>(
  Offset.zero,
);

/// The identity bundle: visible, unscaled, untranslated. Used for
/// hidden layers (which are offstage anyway) and for
/// [RailTransition.none].
const _LayerAnimations _kIdentityLayerAnimations = (
  opacity: _kOpaque,
  scale: _kUnitScale,
  translation: _kNoTranslation,
);

/// The scale [RailTransition.fadeIn]'s incoming layer grows from.
const double _kFadeInBeginScale = 0.98;

/// The scale [RailTransition.fadeThrough]'s incoming layer grows from,
/// per the Material 3 fade-through spec.
const double _kFadeThroughBeginScale = 0.92;

/// The fraction of the duration spent fading the outgoing layer out;
/// the incoming layer animates over the remainder. Sequencing the two
/// is what keeps fade-through free of muddy mid-transition frames.
const double _kFadeThroughSplit = 0.3;

/// The distance, in logical pixels, [RailTransition.sharedAxis] layers
/// slide, per the Material 3 shared-axis spec.
const double _kSharedAxisDistance = 100;

/// The curve applied over the outgoing portion of the duration.
final CurveTween _kOutgoingCurve = CurveTween(
  curve: const Interval(0, _kFadeThroughSplit, curve: Curves.easeIn),
);

/// The curve applied over the incoming portion of the duration.
final CurveTween _kIncomingCurve = CurveTween(
  curve: const Interval(_kFadeThroughSplit, 1, curve: Curves.easeOutCubic),
);

/// The curve applied to shared-axis slides over the full duration.
final CurveTween _kSlideCurve = CurveTween(curve: Curves.easeInOutCubic);

/// Maps a [transition] and layer [role] to the animation bundle for
/// the layer's wrapper chain, all driven by [parent].
///
/// [axis] and [forward] apply only to [RailTransition.sharedAxis]:
/// slides run along [axis], and a switch toward a higher index
/// ([forward]) enters from the trailing side.
_LayerAnimations _layerAnimationsFor({
  required RailTransition transition,
  required _LayerRole role,
  required Animation<double> parent,
  required Axis axis,
  required bool forward,
}) {
  switch (transition) {
    case RailTransition.none:
      // The engine switches instantly for this transition; identity is
      // returned for completeness.
      return _kIdentityLayerAnimations;

    case RailTransition.fadeIn:
      return switch (role) {
        // The outgoing layer vanishes immediately but stays mounted.
        _LayerRole.outgoing => (
          opacity: _kTransparent,
          scale: _kUnitScale,
          translation: _kNoTranslation,
        ),
        _LayerRole.incoming => (
          opacity: parent.drive(CurveTween(curve: Curves.easeOut)),
          scale: parent.drive(
            Tween<double>(
              begin: _kFadeInBeginScale,
              end: 1,
            ).chain(CurveTween(curve: Curves.easeOut)),
          ),
          translation: _kNoTranslation,
        ),
      };

    case RailTransition.fadeThrough:
      return switch (role) {
        _LayerRole.outgoing => (
          opacity: parent.drive(
            Tween<double>(begin: 1, end: 0).chain(_kOutgoingCurve),
          ),
          scale: _kUnitScale,
          translation: _kNoTranslation,
        ),
        _LayerRole.incoming => (
          opacity: parent.drive(
            Tween<double>(begin: 0, end: 1).chain(_kIncomingCurve),
          ),
          scale: parent.drive(
            Tween<double>(
              begin: _kFadeThroughBeginScale,
              end: 1,
            ).chain(_kIncomingCurve),
          ),
          translation: _kNoTranslation,
        ),
      };

    case RailTransition.sharedAxis:
      final distance = _kSharedAxisDistance;
      final enterFrom = axis == Axis.horizontal
          ? Offset(forward ? distance : -distance, 0)
          : Offset(0, forward ? distance : -distance);
      final exitTo = axis == Axis.horizontal
          ? Offset(forward ? -distance : distance, 0)
          : Offset(0, forward ? -distance : distance);

      return switch (role) {
        _LayerRole.outgoing => (
          opacity: parent.drive(
            Tween<double>(begin: 1, end: 0).chain(_kOutgoingCurve),
          ),
          scale: _kUnitScale,
          translation: parent.drive(
            Tween<Offset>(begin: Offset.zero, end: exitTo).chain(_kSlideCurve),
          ),
        ),
        _LayerRole.incoming => (
          opacity: parent.drive(
            Tween<double>(begin: 0, end: 1).chain(_kIncomingCurve),
          ),
          scale: _kUnitScale,
          translation: parent.drive(
            Tween<Offset>(
              begin: enterFrom,
              end: Offset.zero,
            ).chain(_kSlideCurve),
          ),
        ),
      };
  }
}
