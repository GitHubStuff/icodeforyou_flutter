# // packages/place_holder_widget

## 1.0.0

Initial release.

### Added

- `PlaceHolderWidget`: a `const` stateless widget that centers the bundled
  `assets/placeholder512x512.png` inside its parent using `BoxFit.contain`.
- Decode-size cap of 256×256 physical pixels via `cacheWidth` /
  `cacheHeight` to limit the in-memory footprint.
- Generated `Assets` class (`lib/gen/assets.gen.dart`) via
  `flutter_gen_runner` for type-safe asset access.
- Barrel export `package:place_holder_widget/place_holder_widget.dart`
  exposing only `PlaceHolderWidget`.
- Widget tests under `test/src/` covering the public API for the 100% LCOV
  gate.
- Golden test under `test/golden/` (tagged `golden`, excluded from the
  normal run) producing `test/golden/goldens/place_holder_widget.png`.
