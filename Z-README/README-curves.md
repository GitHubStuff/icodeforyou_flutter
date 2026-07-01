# Flutter `Curves` constants

## Basic
- `Curves.linear` — Constant speed, no easing. Mechanical, even motion.
- `Curves.decelerate` — Starts fast, slows to a stop. Like coasting to rest.

## Standard eases
- `Curves.ease` — Gentle speed-up then slow-down. The default, slightly out-weighted.
- `Curves.easeIn` — Starts slow, accelerates into the finish. Ramp up.
- `Curves.easeOut` — Starts fast, decelerates to the end. Ramp down.
- `Curves.easeInOut` — Slow at both ends, fast in the middle. The all-rounder.

## Sine (softest of the families)
- `Curves.easeInSine` — Very gentle acceleration from rest.
- `Curves.easeOutSine` — Very gentle deceleration to rest.
- `Curves.easeInOutSine` — Soft, subtle ease on both ends.

## Quad (mild)
- `Curves.easeInQuad` — Mild acceleration (squared ramp-up).
- `Curves.easeOutQuad` — Mild deceleration.
- `Curves.easeInOutQuad` — Mild ease both ends, a touch sharper than Sine.

## Cubic (moderate)
- `Curves.easeInCubic` — Moderate acceleration, noticeably slow start.
- `Curves.easeOutCubic` — Moderate deceleration, snappy start then settles.
- `Curves.easeInOutCubic` — Moderate ease both ends. Common UI choice.

## Quart (strong)
- `Curves.easeInQuart` — Strong acceleration, very slow start.
- `Curves.easeOutQuart` — Strong deceleration, very fast start.
- `Curves.easeInOutQuart` — Strong ease both ends, pronounced mid-rush.

## Quint (very strong)
- `Curves.easeInQuint` — Very slow start, then a hard rush.
- `Curves.easeOutQuint` — Hard launch, long glide to stop.
- `Curves.easeInOutQuint` — Dramatic ease, long flat ends.

## Expo (most extreme of the eases)
- `Curves.easeInExpo` — Near-still start, explosive finish.
- `Curves.easeOutExpo` — Explosive launch, long slow tail.
- `Curves.easeInOutExpo` — Extreme ease, almost-stopped at both ends.

## Circ (circular arc)
- `Curves.easeInCirc` — Acceleration following a circle's edge; abrupt finish.
- `Curves.easeOutCirc` — Sharp start, circular slow-down.
- `Curves.easeInOutCirc` — Circular ease both ends, crisp.

## Back (overshoot)
- `Curves.easeInBack` — Backs up slightly before moving forward. Wind-up.
- `Curves.easeOutBack` — Overshoots past the target, then settles back. Snappy.
- `Curves.easeInOutBack` — Wind-up at start and overshoot at end.

## Bounce
- `Curves.bounceIn` — Bounces against the start before taking off.
- `Curves.bounceOut` — Lands and bounces a few times like a dropped ball.
- `Curves.bounceInOut` — Bounces at both ends.

## Elastic (springy)
- `Curves.elasticIn` — Winds up with spring oscillation, then launches.
- `Curves.elasticOut` — Overshoots and wobbles like a spring before settling.
- `Curves.elasticInOut` — Spring oscillation at both ends.

## Material / specialized
- `Curves.fastOutSlowIn` — Material's signature curve: quick start, gentle stop.
- `Curves.slowMiddle` — Fast ends, deliberately slow through the middle.
- `Curves.fastLinearToSlowEaseIn` — Brisk linear opening, then a long soft ease-in.
- `Curves.fastEaseInToSlowEaseOut` — Quick ease-in, drawn-out ease-out.
- `Curves.easeInToLinear` — Eases in, then finishes at constant speed.
- `Curves.linearToEaseOut` — Constant speed, then eases out to stop.

## Not constants — constructible Curve types
- `Cubic(a, b, c, d)` — Custom cubic bézier; define your own easing shape.
- `Interval(begin, end, curve:)` — Runs a curve over only a sub-range of the timeline (delays/staggers).
- `FlippedCurve(curve)` — Plays any curve in reverse.
- `SawTooth(count)` — Repeats a linear ramp N times (resets to 0 each cycle).
- `Threshold(threshold)` — Jumps from 0 to 1 once progress passes the threshold. Step function.
- `ElasticInCurve(period)` — Elastic-in with a tunable oscillation period.
- `ElasticOutCurve(period)` — Elastic-out with a tunable oscillation period.
- `ElasticInOutCurve(period)` — Elastic-in-out with a tunable period.
