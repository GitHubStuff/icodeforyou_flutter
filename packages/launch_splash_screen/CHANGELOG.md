# // packages/launch_splash_screen

## 1.0.9

- **BREAKING**: `LaunchFailureCallback` now receives a `StackTrace` as its
  third parameter: `(BuildContext context, Object error,
StackTrace stackTrace)`. Update every `onFailure` handler.
- **BREAKING**: `LaunchSplashFailed` now carries a `stackTrace` and is
  constructed as `LaunchSplashFailed(error, stackTrace)`.
- A task failure forwards the trace captured at the throw; a timeout
  forwards the trace of the timer firing. Both are suitable for crash
  reporting as-is.

## 1.0.0

- Initial version.
