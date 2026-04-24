# `ServiceDescriptor` — Test Coverage Map

This document maps every branch and line of
`packages/services_locator/lib/src/service_descriptor/service_descriptor.dart`
to the test(s) that exercise it, as implemented in
`packages/services_locator/test/src/service_descriptor/service_descriptor_test.dart`.

Target: **100% LCOV line coverage**.

---

## Coverage Matrix

| Branch / Line | Covered By |
|---|---|
| `ServiceDescriptor()` const constructor | Every descriptor instantiation across all tests |
| `ServiceDescriptor.dependencies` default (`const []`) | *dependencies defaults to empty list* |
| `ServiceDescriptor.dependencies` override | *dependencies can be overridden* |
| `ServiceDescriptor.timeout` default (`Duration(seconds: 30)`) | *timeout defaults to 30 seconds* |
| `ServiceDescriptor.timeout` override | *timeout can be overridden* |
| `ServiceDescriptor.toString()` | *toString with defaults*, *toString with overrides*, *toString for lazy descriptor uses same format* |
| `SyncServiceDescriptor()` const constructor | Every sync descriptor instantiation |
| `SyncServiceDescriptor.registerWith` — builder invocation | *invokes builder and forwards to registerServiceSync*, *invokes builder exactly once per registerWith call* |
| `SyncServiceDescriptor.registerWith` — `registerServiceSync` call | *invokes builder and forwards to registerServiceSync*, *uses overridden name when registering* |
| `SyncServiceDescriptor.registerWith` — `ready` emission | *emits LocatorStatus.ready with the built instance* |
| `LazyAsyncServiceDescriptor()` const constructor | Every lazy descriptor instantiation |
| `LazyAsyncServiceDescriptor.registerWith` — forwards to `registerServiceLazyAsync` | *forwards to registerServiceLazyAsync without running builder*, *uses overridden name when registering* |
| `LazyAsyncServiceDescriptor.registerWith` — forwards `builder` reference | *forwards the builder reference so the locator can run it later* |
| `LazyAsyncServiceDescriptor.registerWith` — forwards `serviceState` callback | *forwards the serviceState callback verbatim* |
| Sealed hierarchy — sync branch reachable as base type | *sync descriptor is a ServiceDescriptor* |
| Sealed hierarchy — lazy branch reachable as base type | *lazy descriptor is a ServiceDescriptor* |

---

## Running Coverage Locally

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

If any line reports as uncovered, cross-reference this map to identify which
test should be hitting it, and verify the test is actually running (not
skipped by a `solo:` or `skip:` flag).

---

## Test Strategy Notes

### Recording fake over `MockServiceLocator`

The test suite uses a hand-rolled `_RecordingLocator` fake rather than
pulling in `MockServiceLocator`. This keeps the descriptor contract tests
isolated from locator behavior — if `MockServiceLocator` ever changes,
these tests will not be affected. The fake records every
`registerServiceSync` and `registerServiceLazyAsync` call into
`_SyncCall` and `_LazyCall` records so each `registerWith` delegation can
be asserted directly. The fake's `getServiceSync` / `getServiceAsync`
methods throw `UnimplementedError` — they should never be reached during
descriptor tests, and throwing surfaces any accidental future call that
shouldn't be there.

### Builder-not-run contract for lazy descriptors

The test *forwards to registerServiceLazyAsync without running builder*
is load-bearing. The entire purpose of `LazyAsyncServiceDescriptor` is to
defer construction until first access, so `registerWith` must **not**
invoke the builder. A `_CountingLazyDescriptor` with a build counter
locks this contract down — if a future refactor accidentally eagerly
invokes the builder during registration, this test fails. The paired
test *forwards the builder reference so the locator can run it later*
then extracts the forwarded builder and invokes it directly, proving
the function reference was passed through unmodified.

### Callback forwarding verification

The test *forwards the serviceState callback verbatim* does not just
check that registration happens — it extracts the forwarded callback
from the recorded `_LazyCall`, invokes it with two state transitions
(`starting` then `ready`), and asserts the events land in the original
`_StateRecorder`. This proves the descriptor passes the same function
reference through to the locator rather than wrapping or adapting it.

### Default vs. override coverage

Two descriptors per category are needed to cover both branches of the
virtual dispatch on `dependencies` and `timeout`:

- `_DefaultSyncAuthDescriptor` / `_DefaultLazyAuthDescriptor` — accept
  every base-class default.
- `_CustomSyncAuthDescriptor` / `_CustomLazyLogDescriptor` — override
  every default.

Without both, LCOV will either miss the base getter bodies (if only
overrides exist) or miss the overridden paths (if only defaults exist).

### Instrumented descriptors for build-count assertions

`_CountingSyncDescriptor` and `_CountingLazyDescriptor` live at the
bottom of the test file and exist solely to expose a build-count hook
via an injected `onBuild` callback. These are used by the
*invokes builder exactly once per registerWith call* and
*forwards the builder reference so the locator can run it later* tests
to assert builder invocation counts without relying on side effects
visible through the returned instance.

---

## Adding New Branches

When adding a branch to any descriptor class:

1. Add a row to the **Coverage Matrix** above naming the branch and the
   test that covers it.
2. If the branch introduces new contract behavior (e.g. a new lifecycle
   emission, a new delegation), document it under **Test Strategy Notes**.
3. Run `flutter test --coverage` and confirm the new line is green in
   the HTML report before merging.
