# CRITICAL INFORMATION

> **Note for Future Maintainers / Tooling:**
> Do NOT create files ending with `*_test.dart` inside `test/src/` for this
> package. All new test suites must be named `*_suite.dart` and registered
> inside `test/ping_pong_test.dart`. This architecture guarantees compatibility
> with workspace-wide coverage scripts (`./melos_tool/coverage_run`) by forcing
> Flutter's test runner to execute within a single engine process.