# `GetItServiceLocator` — Test Coverage Map

This document maps every branch and line of
`packages/services_locator/lib/src/service_locator/getit_service_locator.dart`
to the test(s) that exercise it, as implemented in
`packages/services_locator/test/src/service_locator/get_it_service_locator_test.dart`.

Target: **100% LCOV line coverage**.

---

## Coverage Matrix

| Branch / Line | Covered By |
|---|---|
| Constructor — `getIt ?? GetIt.I` fallback path | *defaults to GetIt.I when no instance provided* |
| Constructor — explicit `getIt` injection | *uses the injected GetIt instance* + every other test |
| `getServiceAsync` — `_assertRegistered` throw | *getServiceAsync throws ServiceNotRegistered* |
| `getServiceAsync` — `isReady` + `get` happy path (sync-registered) | *makes service immediately available via getServiceAsync* |
| `getServiceAsync` — `isReady` + `get` happy path (lazy-async builder) | *builder runs on first getServiceAsync and emits ready*, *getServiceSync after builder completes returns instance* |
| `getServiceAsync` — `isReady` timeout pass-through | *getServiceAsync throws on timeout when builder never completes* |
| `getServiceSync` — `_assertRegistered` throw | *getServiceSync throws ServiceNotRegistered* |
| `getServiceSync` — `_getOrThrowNotReady` success | *makes service immediately available via getServiceSync*, *getServiceSync after builder completes returns instance* |
| `getServiceSync` — `_getOrThrowNotReady` `on Error` catch → `ServiceNotReady` | *getServiceSync before ready throws ServiceNotReady* |
| `registerServiceLazyAsync` — `MyLogger.d` call | Every lazy registration test |
| `registerServiceLazyAsync` — duplicate throw | *throws DuplicateServiceEntry (lazy)* |
| `registerServiceLazyAsync` — `registerLazySingletonAsync` + `onCreated` fires `ready` | *builder runs on first getServiceAsync and emits ready* |
| `registerServiceLazyAsync` — `starting` emission | *emits LocatorStatus.starting synchronously* |
| `registerServiceSync` — duplicate throw | *throws DuplicateServiceEntry (sync)* |
| `registerServiceSync` — `registerSingleton` call + `signalReady` | *registers and returns the instance* + every sync-registration test |
| `_assertRegistered` — registered branch (early return) | Every test that successfully retrieves a service |
| `_assertRegistered` — unregistered branch (throw) | All three *unregistered access* tests |
| `_getOrThrowNotReady` — success path | *getServiceSync after builder completes returns instance* |
| `_getOrThrowNotReady` — `on Error` catch | *getServiceSync before ready throws ServiceNotReady* |
| Type-keying in `_assertRegistered` (type-aware lookup) | *type mismatch under same name is treated as unregistered*, *allows same name under a different type*, *allows same type under a different name* |

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

### Per-test `GetIt.asNewInstance()`

Every test gets a fresh `GetIt` registry via `GetIt.asNewInstance()` in
`setUp`, and `getIt.reset()` in `tearDown`. This disconnects every test
from the global `GetIt.I` singleton, making the suite parallel-safe and
eliminating cross-test state leakage. The *uses the injected GetIt
instance* test explicitly asserts this isolation by registering on the
test's private `GetIt` and confirming the registration does not leak
into `GetIt.I`.

### The one test that touches `GetIt.I`

The *defaults to GetIt.I when no instance provided* test exists solely
to cover the null-coalescing branch in the constructor. It never
registers anything on `GetIt.I` — it only proves the object builds. If
you ever see flaky behavior around this test, wrap it in
`addTearDown(() => GetIt.I.reset())` for defense in depth.

### Sync-registered services and `isReady`

The `registerServiceSync` method passes `signalsReady: true` to
`GetIt.registerSingleton` and then immediately calls
`_getIt.signalReady(instance)`. This makes sync-registered instances
participate in GetIt's readiness machinery as immediately-ready, so
`getServiceAsync` can call `_getIt.isReady` uniformly for both sync and
lazy-async registrations without special-casing either path. The test
*makes service immediately available via getServiceAsync* locks this
contract down — if the `signalsReady: true` or the immediate
`signalReady` call are ever removed, `isReady` will time out and this
test will fail.

### Timeout pass-through contract

The *getServiceAsync throws on timeout when builder never completes*
test uses `throwsA(anything)` rather than a specific matcher. This is
deliberate: `GetItServiceLocator` does **not** wrap GetIt's internal
`WaitingTimeOutException` into its own `ServiceNotReady`. The adapter
lets GetIt's exception type propagate. If you want a tighter assertion,
change to `throwsA(isA<TimeoutException>())` and import `dart:async` —
but be aware this couples the test to GetIt's internal exception
choice.

### Type-keyed registration

Three tests exercise GetIt's type-aware registration:
*allows same name under a different type*, *allows same type under a
different name*, and *type mismatch under same name is treated as
unregistered*. Together they prove that `(Type, name)` is the effective
registration key, which is what `_assertRegistered` relies on.

### `_getOrThrowNotReady`'s `on Error` catch

GetIt throws a raw Dart `Error` (not an `Exception`) when a singleton
is registered but not yet ready — this is documented GetIt behavior.
The `_getOrThrowNotReady` helper catches that `Error` and converts it
to `ServiceNotReady`. The `// ignore: avoid_catching_errors` lint
suppression is intentional and necessary here. The test
*getServiceSync before ready throws ServiceNotReady* registers a lazy
async service with a never-completing `Completer` as the builder, then
calls `getServiceSync` before the builder has a chance to run — forcing
the `on Error` branch.

---

## Adding New Branches

When adding a branch to `GetItServiceLocator`:

1. Add a row to the **Coverage Matrix** above naming the branch and the
   test that covers it.
2. If the branch interacts with GetIt's readiness or signal machinery in
   a non-obvious way, document the interaction under
   **Test Strategy Notes**.
3. Run `flutter test --coverage` and confirm the new line is green in
   the HTML report before merging.
