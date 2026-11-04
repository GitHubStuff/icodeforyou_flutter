# launch_splash_screen

Shows a splash widget while launch tasks run, then hands off to the app.

`LaunchSplashScreen` keeps your splash on screen for a minimum duration,
runs a list of start-up tasks concurrently behind it, overlays a spinner if
the tasks outlast the splash, and calls exactly one of two callbacks when
it is done: `onCompleted` or `onFailure`. It knows nothing about routes;
where the app goes next is the caller's decision inside those callbacks.

## Features

- **Minimum splash time.** `child` is visible for at least `splashDuration`
  (default 750 ms), even if every task finishes instantly.
- **Concurrent launch tasks.** `backgroundTasks` is a list of
  `LaunchTask` (`Future<void> Function()`); all start together when the
  splash starts, not when the widget tree is built.
- **Spinner on demand.** If tasks are still running when `splashDuration`
  elapses, `spinner` is shown centred over `child`.
- **Timeout.** If the tasks have not finished by `timeoutDuration`,
  `onFailure` is called with a `TimeoutException`.
- **Failure with a stack trace.** `onFailure` receives
  `(BuildContext, Object error, StackTrace stackTrace)`. For a task that
  threw, the trace is the one captured at the throw; for a timeout it marks
  the timer firing. Both can be forwarded to crash reporting as-is.
- **Exactly-once callbacks.** `onCompleted` and `onFailure` are terminal;
  late task completions and late errors are ignored.
- **Testable core.** The timing logic lives in `LaunchSplashCubit`
  (`flutter_bloc`), driven entirely by timers and futures, so it is tested
  with `fake_async` and no widget tree.

## Getting started

This package is not published; it lives in the `icodeforyou_flutter`
monorepo and is resolved through the pub workspace.

```yaml
dependencies:
  launch_splash_screen:
    path: ../launch_splash_screen
```

Constraint: `timeoutDuration` must be at least
`splashDuration + minimumTimeoutMargin` (250 ms). Violating it is an
assertion error in debug builds.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LaunchSplashScreen(
        timeoutDuration: const Duration(seconds: 5),
        backgroundTasks: [
          () => warmUpDatabase(),
          () => loadRemoteConfig(),
        ],
        spinner: const CircularProgressIndicator(),
        onCompleted: (context) =>
            Navigator.of(context).pushReplacementNamed('/home'),
        onFailure: (context, error, stackTrace) {
          crashReporter.recordError(error, stackTrace, fatal: true);
          Navigator.of(context).pushReplacementNamed('/launch-failed');
        },
        child: const Center(child: FlutterLogo(size: 128)),
      ),
    );
  }
}
```

### Task rules

Tasks run concurrently and must be independent: a task may not rely on
another task having completed. Any error thrown by any task fails the
splash immediately, regardless of timing; only the first error is reported.

### State machine

If you need the states directly (for example to drive a custom UI from
`LaunchSplashCubit`), they are exported:

```text
Showing ──(splash elapsed, tasks done)──────────────▶ Completed
   │
   └──(splash elapsed, tasks pending)──▶ Waiting ──(tasks done)──▶ Completed
                                            │
                                            └──(timeout)──▶ Failed

Showing / Waiting ──(a task threw)──▶ Failed
```

`LaunchSplashFailed` carries `error` and `stackTrace`.

## Additional information

### Tests

Behaviour tests live in `test/src/` and feed the 100 % LCOV target. Golden
renders are tagged `golden` and excluded from the coverage run; see
`test/golden/GOLDEN.md`.

```sh
# Behaviour tests with coverage, goldens excluded
fvm flutter test --exclude-tags golden --coverage
```

```sh
# Regenerate goldens (macOS)
fvm flutter test --update-goldens --tags golden
```

### Changes

See `CHANGELOG.md`. Breaking changes to the callback signatures are
recorded there with the migration required.
