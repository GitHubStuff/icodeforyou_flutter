<!-- packages/status_bar_visibility/CHANGELOG.md -->
<!-- Version: 1.0.0 StatusBarVisibility -->

# Changelog

All notable changes to `status_bar_visibility` are documented here.

## 1.0.0

Initial release.

### Added

- `StatusBarVisibility` static facade for showing and hiding the system
  status bar on Android and iOS.
- `init({bool setHidden = true})` — sets `SystemUiMode.edgeToEdge` and
  applies the initial visibility. Resolves to `true` on supported
  platforms, `false` otherwise.
- `setVisibility({bool isHidden = true})` — dispatches on
  `OSPlatform.current` to `status_bar_android` or `status_bar_ios`.
  Returns `false` (no-op) on Fuchsia, Linux, macOS, Web and Windows.
- `isHidden` getter exposing the last requested state (`null` before
  `init`).
- `NotInitializedError` thrown by `setVisibility` when `init` has not
  been called.
- `@visibleForTesting reset()` to clear internal state between tests.
- Unit tests covering initialization, every `OSPlatform` branch, the
  not-initialized guard and `reset`.