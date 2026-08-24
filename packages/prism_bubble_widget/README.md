<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# prism_bubble_widget(s)

## Design

### What `120` Means
The value `120` represents **120 elapsed seconds (2 minutes)** of real-world animation time.

* Flutter's `AnimationController.value` always returns a normalized progress value from `0.0` to `1.0`.
* Multiplying `_controller.value * 120.0` rescales the fractional progression into physical seconds:
  $$t \in [0.0, 120.0]$$
* This allows equations such as `math.sin(t * 0.45)` to accept angular velocity directly in **radians per second** rather than fractional controller cycles.

---

### Why 120 Seconds Specifically?

* **Common Multiple for Loop Synchronization:** The presets use fractional angular frequencies (such as $0.2$, $0.3$, $0.4$, $0.5$, and $0.6\text{ rad/s}$). A 120-second timeline provides integer or near-integer cycle completion across these frequencies.
* **Elimination of Visual Snapping:** When the controller resets from `1.0` back to `0.0`, a 2-minute cycle length makes phase discrepancies imperceptible compared to shorter 1- to 5-second loops.
* **Floating-Point Precision:** At 60 fps and 120 fps display refresh rates, scaling `[0.0, 1.0]` across 120 seconds yields delta steps of ~0.016s to ~0.008s per frame, preventing micro-stuttering or precision loss.
