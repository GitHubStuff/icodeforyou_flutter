<!-- plugins/status_bar_android/CHANGELOG.md -->
<!-- Version: 0.0.1-a StatusBarAndroid -->

# Changelog

All notable changes to `status_bar_android` are recorded here. The
format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the package follows [Semantic Versioning](https://semver.org/).

## [0.0.1-a] — 2026-10-29

Initial pre-release.

### Added

- `StatusBar.setVisibility({bool isHidden = true})` — shows or hides the
  Android status bar with no system transition, via
  `WindowInsetsController.controlWindowInsetsAnimation` finished
  immediately in `onReady`.
- Transient reveal on swipe from the top edge while hidden
  (`BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE`).
- Fallback to the animated `show()`/`hide()` when the system refuses
  animation control.
- Error codes surfaced to Dart as `PlatformException`: `NO_ACTIVITY`,
  `NO_INSETS_CONTROLLER`, `INVALID_ARGUMENT`.
- Dart: facade → platform interface → method channel, with the platform
  instance replaceable for testing. 12 tests, 100% line coverage.
- Kotlin: `StatusBarAndroidPlugin` (channel + `ActivityAware`
  lifecycle) and `StatusBarController` (window work), with an
  injectable controller factory. 8 JVM unit tests.
- Example app: single toggle button, status bar hidden before the first
  frame, solid-colour icon-less launch screen (Android theming, not a
  plugin feature).
- Docs: `README.md`, `README-plugin-test.md`, `example/README.md`,
  `example/README-change-splash.md`.

### Constraints

- Android only; `minSdk = 30` (Android 11). Other platforms throw
  `MissingPluginException`.
- Standalone plugin, not a federated implementation.