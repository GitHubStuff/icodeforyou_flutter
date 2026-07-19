# biometric_gate_service

Backend-agnostic interface for biometric-gated secure storage.

A small Flutter package that defines the `BiometricGateService` contract:
biometric capability inspection, a biometric prompt for gating access to the
app itself, and an opaque key/value store whose reads are gated by the
device's biometric authentication (Face ID, Touch ID, Android
BiometricPrompt). The contract knows nothing about emails, passwords, refresh
tokens, or any other domain concept — callers decide what to store.

The contract is split into small, composable role interfaces so callers
depend only on what they actually use.

## Features

- Composable role interfaces (interface-segregation friendly):
  - `BiometricAuthenticator` — `capability()` and `verify()`; user presence
    only, no storage. Depend on this alone to gate the app at launch.
  - `BiometricSecureStore` — `store()`, `retrieve()`, `clear()`; the gated
    key/value store.
  - `BiometricGateService` — composes both roles and adds the opt-in
    lifecycle (`isEnabled()`, `enable()`, `disable()`).
- All operations return `Either<BiometricFailure, T>` (no exceptions escape
  an implementation)
- Sealed `BiometricFailure` hierarchy for exhaustive error handling at call
  sites: `BiometricUnavailable`, `BiometricNotEnrolled`, `BiometricCancelled`,
  `BiometricLockedOut`, `BiometricPermanentlyLockedOut`,
  `BiometricStorageFailure`, `BiometricUnknownFailure`
- `BiometricCapability` enum reporting available hardware: `none`,
  `notEnrolled`, `face`, `fingerprint`, `iris`, `generic`
- Dependency-free contract: this package has no dependency on `local_auth`,
  `flutter_secure_storage`, `service_locator`, or any platform SDK. Wiring an
  implementation into a DI broker is a composition-root concern, carried by
  the implementation — not baked into the contract.

## Getting started

This package is the contract only — it ships no implementation and has no
platform dependencies. To use it, register a concrete `BiometricGateService`
implementation (one that wraps the device APIs — for example `local_auth` for
the prompt and `flutter_secure_storage` for the store) with your services
broker at startup. All other code depends on the interface.

```yaml
dependencies:
  biometric_gate_service: ^2.0.0
  # plus a concrete implementation of BiometricGateService
```

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

### Gating the app itself

When you only need to prove user presence — not read a stored value — use
`verify()`. A launch-time unlock can depend on the narrow
`BiometricAuthenticator` role rather than the whole service:

```dart
final BiometricAuthenticator auth = gate; // or inject the role directly

final unlocked = await auth.verify(reason: 'Unlock to continue');
unlocked.match(
  (failure) => routeToFallback(failure),
  (_) => openApp(),
);
```

### Opting out is destructive

`disable()` records the opt-out **and purges every value stored behind the
gate** — it is not merely a flag flip. Read anything you need to keep before
calling it. Both `enable()` and `disable()` are idempotent.

## Choosing what to store

The gate is opaque on purpose. Different callers store different things:

- A Firebase-backed `AuthService` typically stores nothing — Firebase Auth
  has its own session persistence; the gate is used only as a yes/no door
  on top of an already-signed-in app. Capability plus `verify()` is enough,
  so such a caller can depend on the `BiometricAuthenticator` role alone.
- A Supabase- or AWS Cognito-backed `AuthService` typically stores the
  refresh token, since session re-hydration is the caller's responsibility.
- Non-auth callers might store API keys, encryption seeds, or any other
  secret that should be unlocked by biometric.

Each caller picks its own keys and decides what to put in the values. The
gate does not interpret value contents.

## Example using Supabase

Supabase owns the session, so the gate stores only the **refresh token**: the
app persists it behind the gate at sign-in and re-hydrates the session behind
a biometric prompt on the next launch. Refresh tokens are single-use (rotation
is on by default), so the rotated token is re-stored after each restore.

```dart
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Biometric unlock layered on top of a Supabase session.
class SupabaseBiometricAuth {
  SupabaseBiometricAuth(this._gate, this._supabase);

  final BiometricGateService _gate;
  final SupabaseClient _supabase;

  static const _refreshTokenKey = 'supabase_refresh_token';

  /// Turn on biometric unlock after a successful Supabase sign-in.
  Future<Either<BiometricFailure, Unit>> enableUnlock() async {
    final refreshToken = _supabase.auth.currentSession?.refreshToken;
    if (refreshToken == null) {
      return left(
        const BiometricStorageFailure(message: 'No active Supabase session.'),
      );
    }

    // enable() first so the backend is ready, then persist the token.
    final enabled = await _gate.enable();
    return enabled.match(
      (failure) async => left(failure),
      (_) => _gate.store(key: _refreshTokenKey, value: refreshToken),
    );
  }

  /// Restore the Supabase session at launch, behind a biometric prompt.
  Future<Either<BiometricFailure, Session>> unlock() async {
    if (!await _gate.isEnabled()) {
      return left(
        const BiometricStorageFailure(message: 'Biometric unlock is off.'),
      );
    }

    final stored = await _gate.retrieve(
      key: _refreshTokenKey,
      reason: 'Unlock to sign in',
    );

    // Propagate any biometric/storage failure unchanged; otherwise restore.
    return stored.match(
      (failure) async => left(failure),
      _restoreSession,
    );
  }

  Future<Either<BiometricFailure, Session>> _restoreSession(
    String refreshToken,
  ) async {
    final AuthResponse response;
    try {
      response = await _supabase.auth.setSession(refreshToken);
    } on Object catch (error) {
      return left(BiometricUnknownFailure(message: '$error', cause: error));
    }

    final session = response.session;
    if (session == null) {
      return left(
        const BiometricStorageFailure(message: 'Session restore failed.'),
      );
    }

    // Rotation invalidates the used token — persist the new one. Best-effort:
    // a failed re-store does not invalidate the live session.
    final rotated = session.refreshToken;
    if (rotated != null) {
      await _gate.store(key: _refreshTokenKey, value: rotated);
    }
    return right(session);
  }

  /// Sign out and turn off biometric unlock. disable() also purges the
  /// stored refresh token.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _gate.disable();
  }
}
```

Wiring it to launch UI:

```dart
final result = await auth.unlock();
result.match(
  (failure) => switch (failure) {
    BiometricCancelled() ||
    BiometricUnavailable() ||
    BiometricNotEnrolled() => showPasswordSignIn(),
    _ => reportError(failure),
  },
  (session) => goToHome(),
);
```

## Additional information

Part of the `icodeforyou_flutter` Melos monorepo. Issues, fixes, and PRs go
through the monorepo, not this package directly.
