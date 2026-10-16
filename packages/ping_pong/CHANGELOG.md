## 0.1.1

### Fixed

- **Coverage Runner Segmentation Fault (`SIGSEGV`) During Engine Teardown**
  - **The Problem:** Running `flutter test --coverage` triggered native C++
    `flutter_tester` engine crashes (`TestDeviceException: Shell subprocess
    crashed with segmentation fault`) during teardown inside
    `FlutterTesterTestDevice.finished`. The issue occurred when pure model
    classes importing `dart:ui` primitives (`Offset`) executed in isolated,
    non-widget test processes under active VM Service coverage collection.
    When multiple test files finished, race conditions in the macOS engine
    finalizer crashed the subprocesses. Additionally, `PingPongBall` was missing
    test coverage on invalid `exitDuration` assertion branches.
  - **The Solution:**
    1. Consolidated test execution under a single discoverable runner
       (`test/ping_pong_test.dart`) by renaming individual test files to
       `*_suite.dart`. This forces `flutter test` to discover exactly one test
       file, running all tests sequentially inside a single engine lifecycle
       and avoiding isolate teardown collisions.
    2. Added a boundary widget test asserting negative `exitDuration` values in
       `PingPongBall`, bringing the package to 100% LCOV coverage (290/290
       lines).
  - **Why Standalone Worked vs. Mono-Repo Failed:**
    Running `flutter test --coverage test/all_tests.dart` explicitly targeted a
    single file, bypassing file discovery. The mono-repo script
    (`./melos_tool/coverage_run`) uses standard file globbing for `*_test.dart`,
    which re-discovered all 8 individual files and spawned separate engine
    processes, re-triggering the crash.
  - **File Changes:**
    - `test/ping_pong_test.dart`: Updated to act as the single aggregated runner
      grouping all package test suites.
    - `test/src/*_suite.dart`: Renamed from `*_test.dart` to prevent automatic
      multi-process discovery by `flutter test`.
    - `test/src/ping_pong_ball_suite.dart`: Added widget tests targeting
      `exitDuration < Duration.zero` assertion validation.

> **Note for Future Maintainers / Tooling:**
> Do NOT create files ending with `*_test.dart` inside `test/src/` for this
> package. All new test suites must be named `*_suite.dart` and registered
> inside `test/ping_pong_test.dart`. This architecture guarantees compatibility
> with workspace-wide coverage scripts (`./melos_tool/coverage_run`) by forcing
> Flutter's test runner to execute within a single engine process.