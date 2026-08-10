# biometric_gate_service

A backend-agnostic biometric-gated secure storage contract: composable role
interfaces for user presence and gated key/value storage, a composed service
with an opt-in lifecycle, a hardware-capability enum, and a sealed failure
hierarchy. Pure contracts — no `local_auth`, no `flutter_secure_storage`, no
platform code. Programs depend on these interfaces; an implementation is
registered with the services broker at app startup. Part of the
`icodeforyou_flutter` monorepo (`packages/`).

## Features

- **`BiometricAuthenticator`** — the user-presence role. `capability()`
  reports the device's biometric modality (cheap, non-prompting, safe on
  every launch — drives "Use Face ID" vs "Use Touch ID" vs generic labels);
  `verify({reason})` runs the biometric prompt. Neither reads nor writes any
  stored value, so a launch-screen unlock can depend on this role alone.
- **`BiometricSecureStore`** — a secure key/value store whose reads are
  gated by biometric authentication. Values are opaque strings; the role
  does not interpret them, keeping it reusable for tokens, API keys, wallet
  seeds, and other non-auth secrets. `store` guarantees a later `retrieve`
  succeeds only after a successful biometric authentication; `clear` deletes
  without prompting and is idempotent.
- **`BiometricGateService`** — the composed handle: implements both roles
  and adds the opt-in lifecycle. `isEnabled()` is independent of
  `capability()` — a user may have enabled the gate on a device that has
  since lost its enrolled biometric, and callers reconcile the two.
  `enable()` is idempotent setup; `disable()` records the opt-out and, as a
  deliberate, documented side effect, **purges every value stored behind
  the gate** — callers that need the data must read it out first. The
  interface is domain-blind: it knows nothing about emails, passwords, or
  tokens.
- **`BiometricCapability`** — the modality enum, ordered by specificity:
  `none`, `notEnrolled`, `face`, `fingerprint`, `iris`, and `generic` (the
  platform hid the modality — common on Android, where the framework may
  surface only the security class; show a generic label).
- **`BiometricFailure`** — a sealed, `@immutable` hierarchy carried on the
  `Left` of every operation, each with a `message` and optional underlying
  `cause`: `BiometricUnavailable`, `BiometricNotEnrolled`,
  `BiometricCancelled` (typically a fall-back-to-password signal, not an
  error), `BiometricLockedOut`, `BiometricPermanentlyLockedOut`,
  `BiometricStorageFailure` (the prompt may have passed but storage
  rejected the operation), and `BiometricUnknownFailure` (catch-all
  carrying the original cause). Adding a failure is a compile-time event at
  every exhaustive `switch`.
- **No exceptions escape.** Every operation returns
  `Either<BiometricFailure, T>` (via `fpdart`), making every failure path
  visible at the call site and exhaustiveness-checked by the compiler.

## Getting started

This package lives in the monorepo's `packages/` directory and is consumed
via pub workspace resolution. Add it to a consumer's `pubspec.yaml`:

```yaml
dependencies:
  biometric_gate_service: ^0.1.0
```

Its only dependencies are `fpdart` (`Either`, `Unit`) and `meta`
(`@immutable`). An implementation package (for example, a `local_auth` +
`flutter_secure_storage` backend) is registered at the composition root;
registration with a dependency-injection mechanism is deliberately not
expressed in these contracts.

Import through the barrel:

```dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
```

## Usage

```dart
Future<void> unlock(BiometricGateService gate) async {
  if (!await gate.isEnabled()) return; // user never opted in

  final result = await gate.retrieve(
    key: 'session_token',
    reason: 'Unlock your session',
  );

  switch (result) {
    case Right(value: final token):
      // proceed with token
      break;
    case Left(value: final failure):
      switch (failure) {
        case BiometricCancelled():
          // fall back to password
          break;
        case BiometricLockedOut() || BiometricPermanentlyLockedOut():
          // direct the user to device passcode / re-enrollment
          break;
        case BiometricUnavailable() ||
            BiometricNotEnrolled() ||
            BiometricStorageFailure() ||
            BiometricUnknownFailure():
          // degrade to non-biometric auth
          break;
      }
  }
}
```

## Additional information

Part of the `icodeforyou_flutter` monorepo, managed with Melos (all
configuration in `pubspec.yaml`); internal dependencies resolve through the
pub workspace (`resolution: workspace`), never path dependencies. Not
intended for publication to pub.dev. File issues and contribute through the
monorepo's normal workflow.

The package follows the repo's standing conventions: one type per file,
curated barrel exports with a library-level dartdoc, dartdoc on all members,
`final class` failure implementations under a sealed base, and
`icodeforyou_lints` lint compliance. Design stances worth knowing before
implementing a backend: role interfaces over a monolith, contracts with no
platform bindings, typed failures over exceptions, and a destructive opt-out
that is part of the contract — no backend may make the purge a surprise.