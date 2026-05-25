# biometric_gate_service_local

A local implementation of `BiometricGateService` built on `local_auth` (for the platform biometric prompt) and `flutter_secure_storage` (for the platform secure key/value store). No exceptions escape the public surface — every failure is returned as a typed `BiometricFailure` inside an `fpdart` `Either`.

## Features

- **Single dependency for consumers** — the barrel re-exports `biometric_gate_service`, so you depend on this one package and pick up both the interface and the implementation.
- **Capability detection** — `capability()` returns a typed `BiometricCapability` (`face`, `fingerprint`, `iris`, `generic`, `notEnrolled`, or `none`) without throwing.
- **Opt-in flag** — `isEnabled()` / `enable()` / `disable()` persist a user-level toggle in secure storage under a single internal key.
- **Biometric-gated verify and retrieve** — `verify(reason:)` prompts the user; `retrieve(key:, reason:)` prompts and only returns the value on success.
- **`Either`-typed errors** — every mutating call returns `Either<BiometricFailure, Unit>` (or `Either<BiometricFailure, String>` for `retrieve`); no try/catch needed at the call site.
- **Injectable error mapping** — `BiometricErrorMapper` typedef and `defaultBiometricErrorMapper` let tests substitute a fake mapping to exercise error paths without depending on platform error codes.
- **Configurable storage options** — `IOSOptions` and `AndroidOptions` are forwarded to every secure-storage call so you can enable additional access controls (e.g. iOS Keychain biometric access control).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  biometric_gate_service_local: ^1.0.0
```

Then import it where you wire up your services:

```dart
import 'package:biometric_gate_service_local/biometric_gate_service_local.dart';
```

The barrel re-exports `biometric_gate_service`, so the same import gives you `BiometricGateService`, `BiometricCapability`, the `BiometricFailure` family, and the `Either` / `Unit` types from `fpdart`.

Production code should depend on the `BiometricGateService` interface, not on `BiometricGateServiceLocal` directly, so the backend stays a composition-root decision.

## Usage

### Construct the service

Defaults work for production. Pass overrides in tests:

```dart
final BiometricGateService gate = BiometricGateServiceLocal(
  // All optional:
  // localAuth: ...,
  // secureStorage: ...,
  // errorMapper: defaultBiometricErrorMapper,
  // iosOptions: IOSOptions.defaultOptions,
  // androidOptions: AndroidOptions.defaultOptions,
);
```

### Check capability before offering the feature

`capability()` is the safe gate before showing any biometric-related UI. It never throws — unsupported devices return `BiometricCapability.none`:

```dart
final cap = await gate.capability();

switch (cap) {
  case BiometricCapability.none:
    // Don't offer biometrics; fall back to passcode.
    break;
  case BiometricCapability.notEnrolled:
    // Prompt the user to enrol Face ID / fingerprint in system settings.
    break;
  case BiometricCapability.face:
  case BiometricCapability.fingerprint:
  case BiometricCapability.iris:
  case BiometricCapability.generic:
    // Safe to offer the opt-in.
    break;
}
```

### Opt-in toggle

The service persists a single opt-in flag in secure storage. Read it on app start, write it from a settings screen:

```dart
final enabled = await gate.isEnabled();

// Enable from a settings toggle:
final result = await gate.enable();
result.match(
  (failure) => _showError(failure),
  (_) => _setUiEnabled(true),
);

// Disable: clears all entries written through this service.
await gate.disable();
```

### Verify identity (no payload)

Use `verify` when you just need a biometric ack — for example, to gate a destructive action or unlock a screen. The implementation forces `biometricOnly: true` (no PIN fallback) and `persistAcrossBackgrounding: true`:

```dart
final result = await gate.verify(
  reason: 'Confirm it\'s you to delete this account.',
);

result.match(
  (failure) {
    if (failure is BiometricCancelled) {
      // User dismissed the prompt — silent return is usually correct.
      return;
    }
    _showError(failure);
  },
  (_) => _deleteAccount(),
);
```

### Store and retrieve a secret behind biometrics

`store` writes through to secure storage without prompting; `retrieve` prompts first and only returns the value on success. Missing keys come back as `BiometricStorageFailure`:

```dart
// Write after the user authenticates once at sign-in:
await gate.store(key: 'refresh_token', value: tokenFromServer);

// Read later, gated by biometrics:
final result = await gate.retrieve(
  key: 'refresh_token',
  reason: 'Sign in with Face ID',
);

result.match(
  (failure) {
    switch (failure) {
      case BiometricCancelled():
        // user dismissed
      case BiometricLockedOut():
        _showRetryLater();
      case BiometricPermanentlyLockedOut():
        _routeToPasscode();
      case BiometricStorageFailure():
        _routeToFreshSignIn();
      default:
        _showError(failure);
    }
  },
  (token) => _signInWith(token),
);

// Forget a single key without disabling the whole service:
await gate.clear(key: 'refresh_token');
```

### Tighten the secure-storage options

When you want the OS to enforce biometric access on the Keychain item itself (so even a copy of the file can't be decrypted off-device), pass stricter `IOSOptions` / `AndroidOptions`:

```dart
final gate = BiometricGateServiceLocal(
  iosOptions: const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
  androidOptions: const AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);
```

### Inject a custom error mapper in tests

`BiometricErrorMapper` lets a test verify the error-path wiring without simulating real platform error codes:

```dart
final gate = BiometricGateServiceLocal(
  localAuth: mockLocalAuth,
  secureStorage: mockStorage,
  errorMapper: (error) => BiometricUnknownFailure(
    message: 'forced for test',
    cause: error,
  ),
);
```

Production code keeps `defaultBiometricErrorMapper`, which recognises `LocalAuthException` codes from `local_auth` 3.x (`noBiometricHardware`, `noBiometricsEnrolled`, `temporaryLockout`, `biometricLockout`) and falls back to `BiometricUnknownFailure` for anything else — including codes added in future plugin versions.

## API reference

| Method | Returns | Prompts user? |
| --- | --- | --- |
| `capability()` | `Future<BiometricCapability>` | No |
| `isEnabled()` | `Future<bool>` | No |
| `enable()` | `Future<Either<BiometricFailure, Unit>>` | No |
| `disable()` | `Future<Either<BiometricFailure, Unit>>` | No |
| `verify(reason:)` | `Future<Either<BiometricFailure, Unit>>` | Yes |
| `store(key:, value:)` | `Future<Either<BiometricFailure, Unit>>` | No |
| `retrieve(key:, reason:)` | `Future<Either<BiometricFailure, String>>` | Yes |
| `clear(key:)` | `Future<Either<BiometricFailure, Unit>>` | No |

Failure types in the `Left` channel: `BiometricUnavailable`, `BiometricNotEnrolled`, `BiometricLockedOut`, `BiometricPermanentlyLockedOut`, `BiometricCancelled`, `BiometricStorageFailure`, `BiometricUnknownFailure`.

## Additional information

`disable()` calls `deleteAll` on the secure storage — every entry written through this service is removed, including the opt-in flag and any secrets stored via `store`. Use `clear(key:)` when you want to forget a single key without disabling the service.
