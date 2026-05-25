# biometric_gate_service

Backend-agnostic interface for biometric-gated secure storage.

A small Flutter package that defines the `BiometricGateService` contract:
opaque key/value storage protected by the device's biometric authentication
(Face ID, Touch ID, Android BiometricPrompt). The interface knows nothing
about emails, passwords, refresh tokens, or any other domain concept —
callers decide what to store.

## Features

- `BiometricGateService` interface returning `Either<BiometricFailure, T>`
  (no exceptions escape the service)
- Sealed `BiometricFailure` hierarchy for exhaustive error handling at call
  sites: `BiometricUnavailable`, `BiometricNotEnrolled`, `BiometricCancelled`,
  `BiometricLockedOut`, `BiometricPermanentlyLockedOut`,
  `BiometricStorageFailure`, `BiometricUnknownFailure`
- `BiometricCapability` enum reporting available hardware: `none`,
  `notEnrolled`, `face`, `fingerprint`, `iris`, `generic`
- Three concern groups in one interface:
  - **Capability inspection** (`capability()`) — non-prompting
  - **Preference toggle** (`isEnabled()`, `enable()`, `disable()`)
  - **Gated storage** (`store()`, `retrieve()`, `clear()`)
- Implementation-agnostic: the interface package has no dependency on
  `local_auth`, `flutter_secure_storage`, or any platform SDK

## Getting started

This package contains the interface only. To use it, depend on this package
plus a concrete implementation. The default implementation,
`biometric_gate_service_local`, wraps `local_auth` and `flutter_secure_storage`.

```yaml
dependencies:
  biometric_gate_service: ^1.0.0
  biometric_gate_service_local: ^1.0.0
```

The consuming program registers the implementation with the services broker
at startup; all other code depends on the interface only.

## Usage

```dart
import 'package:biometric_gate_service/biometric_gate_service.dart';

final BiometricGateService gate = /* injected from the broker */;

// Check what hardware is available before showing biometric UI.
final cap = await gate.capability();
final canShowToggle = switch (cap) {
  BiometricCapability.none ||
  BiometricCapability.notEnrolled => false,
  _ => true,
};

// Record the user's opt-in (no prompt).
await gate.enable();

// Store an opaque value behind the gate.
await gate.store(key: 'session_token', value: token);

// Retrieve it later — runs the biometric prompt.
final result = await gate.retrieve(
  key: 'session_token',
  reason: 'Unlock to sign in',
);

result.match(
  (failure) => switch (failure) {
    BiometricCancelled() => fallbackToPassword(),
    BiometricLockedOut() => showPasscodePrompt(),
    BiometricUnavailable() ||
    BiometricNotEnrolled() => disableBiometricFeature(),
    BiometricStorageFailure() ||
    BiometricPermanentlyLockedOut() ||
    BiometricUnknownFailure() => reportError(failure),
  },
  (value) => useToken(value),
);
```

## Choosing what to store

The gate is opaque on purpose. Different callers store different things:

- A Firebase-backed `AuthService` typically stores nothing — Firebase Auth
  has its own session persistence; the gate is used only as a yes/no door
  on top of an already-signed-in app.
- A Supabase- or AWS Cognito-backed `AuthService` typically stores the
  refresh token, since session re-hydration is the caller's responsibility.
- Non-auth callers might store API keys, encryption seeds, or any other
  secret that should be unlocked by biometric.

Each caller picks its own keys and decides what to put in the values. The
gate does not interpret value contents.

## Additional information

Part of the `icodeforyou_flutter` Melos monorepo. Issues, fixes, and PRs go
through the monorepo, not this package directly.
