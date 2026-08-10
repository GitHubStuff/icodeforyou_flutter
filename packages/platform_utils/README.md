# platform_utils

Platform, form-factor, orientation, spacing, and frame-pacing utilities for
Flutter apps. The package's organizing idea is separation of questions: each
type answers exactly one — *what OS?* (`AppPlatform`), *whose OS?*
(`PlatformVendor`), *which layout strategy?* (`FormFactor`), *which way is
the window facing?* (`OrientationFactor`), *how far apart?* (`DipScale`),
*how fast do frames tick?* (`FrameRefreshRate`, `PlatformOptimizer`).
Nothing here holds state a widget tree must provide; everything resolves
from the framework's own signals, with debug-only overrides for tests and
previews.

## Structure

```
lib/
├── platform_utils.dart              # Public barrel
└── src/
    ├── app_platform.dart            # AppPlatform enum — what OS?
    ├── platform_vendor.dart         # PlatformVendor enum — whose OS?
    ├── form_factor.dart             # FormFactor enum — which layout?
    ├── orientation_factor.dart      # OrientationFactor resolver
    ├── dip_scale.dart               # DipScale spacing constants
    ├── frame_refresh.dart           # FrameRefreshRate enum
    └── platform_optimizer.dart      # PlatformOptimizer tuning values
```

## AppPlatform — what OS?

Wraps `defaultTargetPlatform` and `kIsWeb` into one testable enum:
`android`, `fuchsia`, `iOS`, `linux`, `macOS`, `web`, `windows`.

- **`AppPlatform.current()`** resolves the active platform. Resolution
  order: a debug override, then `web` when `kIsWeb` (the browser wins over
  its host OS), then the `defaultTargetPlatform` mapping.
- **`AppPlatform.setPlatform({to})`** overrides `current()` for tests and
  previews. The body runs inside an `assert`, so it is stripped from
  release builds entirely. Call with no argument to clear.
- **`isMobile`** — true for `android` and `iOS`. **`isDesktop`** — true for
  `linux`, `macOS`, `windows`. `web` is false for both: the browser's host
  OS is invisible to the app, so desktop-ness on web is a `FormFactor`
  question (window geometry), not a platform one.
- **`fuchsia`** is recognized but unsupported: both capability getters
  throw `UnimplementedError` for it, deliberately, so adding real Fuchsia
  behavior is a conscious decision rather than a silent default.

```dart
if (AppPlatform.current().isMobile) {
  return const BottomNavLayout();
}
```

## PlatformVendor — whose OS?

Groups platforms by controlling company for vendor-wide decisions —
Cupertino vs Material styling, store links, sign-in providers — where the
individual OS is too fine a distinction: `apple` (iOS, macOS), `google`
(android, fuchsia), `microsoft` (windows), `other` (linux, web).

**`PlatformVendor.current()`** delegates to `AppPlatform.current()`. There
is deliberately no separate test override: overriding the platform via
`AppPlatform.setPlatform` overrides the vendor with it — one source of
truth, per DRY.

## FormFactor — which layout strategy?

Describes the *rendering target*, as opposed to the operating system:
`phone`, `tablet`, `desktop`, `web`.

- **`FormFactor.of(context)`** resolves from the ambient `MediaQuery`
  (via `MediaQuery.sizeOf`, so callers rebuild on resize and rotation).
- **`FormFactor.from(size)`** is the pure-geometry core, unit-testable
  without a widget tree. Resolution order: debug override → `web` when
  compiled for the browser → `desktop` for native desktop OSes → `desktop`
  for any native window ≥ 1024 logical pixels wide (the Material 3
  "expanded" boundary) → `tablet` when the shortest side is ≥ 600 logical
  pixels (Android's `sw600dp` convention) → `phone`.
- **`setFormFactor({to})`** — debug-only override, assert-stripped in
  release. It beats every runtime signal *including* `kIsWeb`, so the
  phone/tablet/desktop paths can be previewed inside a debug web build.
- Convenience getters: `isPhone`, `isTablet`, `isDesktop`, `isWeb`.

`web` is its own factor: browser deployments get one rendering path
regardless of window geometry; the breakpoints apply only to native
platforms.

```dart
if (FormFactor.of(context).isTablet) {
  return const TwoPaneLayout();
}
```

## OrientationFactor — which way is the window facing?

Resolves Flutter's own `Orientation` enum rather than defining a parallel
one, so results plug directly into `OrientationBuilder`, `MediaQuery`, and
every other framework API without conversion. Because `Orientation` is a
framework type, the resolver statics live on this holder class instead of
the enum itself — otherwise the same shape as the package's other
resolvers.

- **`OrientationFactor.of(context)`** — from the ambient `MediaQuery`.
- **`OrientationFactor.from(size)`** — pure geometry: landscape iff the
  window is wider than it is tall; a square window is portrait, matching
  `MediaQueryData.orientation`. Reflects the *window*, not the device
  sensor — a tall desktop window is portrait.
- **`setOrientation({to})`** — debug-only override, assert-stripped in
  release.

## DipScale — how far apart?

The app's spacing scale in logical pixels, on an 8pt grid with 4pt
half-steps and a 12pt comfortable mid-step for the common "8 is tight, 16
is loose" case:

| Constant | Value | Use |
| --- | --- | --- |
| `none` | 0 | No space |
| `xs` | 4 | Hairline / tight nudges |
| `sm` | 8 | Compact spacing |
| `smd` | 12 | Comfortable mid-step |
| `md` | 16 | Standard spacing |
| `lg` | 24 | Group separation |
| `xl` | 32 | Section separation |
| `xxl` | 48 | Large section separation |

Every value is divisible by 4, so spacing stays whole across 1.5x/2x/3x
display densities with no subpixel rounding. Use these instead of literal
numbers so the whole app's rhythm can be retuned from one place. The
`Spacing` typedef (an alias of `double`) documents intent at call sites.

## FrameRefreshRate — how long is a frame?

Common display refresh rates paired with precomputed per-frame budgets, so
animation code never divides per frame: `fps24` (~41.667 ms), `fps60`
(~16.667 ms), `fps90` (~11.111 ms), `fps120` (~8.333 ms). Each value
carries `fps`, `microseconds` (`1e6 ~/ fps`, rounded), and a `duration`
getter. `FrameRefreshRate.preset` is the default 60fps interval.

```dart
Timer.periodic(FrameRefreshRate.fps120.duration, (_) => advanceFrame());
```

## PlatformOptimizer — platform-aware animation tuning

Centralizes the per-platform decisions that affect rendering cost. Instance
methods operate against an injectable `AppPlatform` for deterministic unit
tests; static counterparts (`getOptimalFrameRate`,
`getOptimalParticleCount`, `getParticleStep`,
`shouldUseHighPerformanceMode`, `getPlatformName`) delegate to a shared
default instance that resolves the platform at call time — which means the
statics also honor `AppPlatform.setPlatform`.

**Frame pacing** is two-phase: call `resolveFrameRate(context)` once the
tree is attached to a view (`didChangeDependencies` is the canonical site)
to read and cache the display's actual refresh rate; until then,
`calculateOptimalFrameRate()` falls back to `FrameRefreshRate.fps60`.

**Particle tuning** scales with rendering headroom:

| Platform | Particle count | Step (px/frame) |
| --- | --- | --- |
| Desktop (native) | 1.2 × width | 1.5 (finest) |
| Web | 0.8 × width | 2.5 (coarsest) |
| Mobile | 0.6 × width | 2.0 |

**`isHighPerformanceModeEnabled()`** is true only for native desktop —
web is excluded even when the browser runs on a desktop OS.

Fuchsia propagates the `UnimplementedError` from the `AppPlatform`
capability getters through every calculation, by design.

## Testing conventions

All three resolvers hold static override state, so every test file clears
it in `tearDown` — `AppPlatform.setPlatform()`, `FormFactor.setFormFactor()`,
`OrientationFactor.setOrientation()`, and
`debugDefaultTargetPlatformOverride = null`. Setting
`debugDefaultTargetPlatformOverride` directly is safe only in plain
`test()` bodies; `testWidgets` bodies must use
`variant: TargetPlatformVariant.only(...)` instead, because the binding
verifies all foundation debug variables are null when the test body ends —
before `tearDown` runs.

Four lines carry `// coverage:ignore-line`: the two `kIsWeb` early returns
(const-false in VM test runs; real code on web builds) and the two `_ =>`
default arms in `PlatformOptimizer`'s switches (required by the compiler
because guarded cases don't count toward exhaustiveness, but unreachable —
every platform is consumed by an earlier arm or throws in the first
guard). With those markers honored by the coverage tooling, the test suite
reports a genuine 100%.

## Dependencies

Flutter only (`foundation` and `widgets`). No third-party dependencies.