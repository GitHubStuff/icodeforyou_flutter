# app_preferences_service

Service-locator integration for the app's preferences store. Part of the
`icodeforyou_flutter` monorepo (`packages/`).

This package bridges two other monorepo packages: it wraps
`app_preferences`' `AbstractPreferencesInterface` in a `service_locator`
service handle and provides descriptors that select and build the concrete
backend at registration time. Consumers depend on the service, never on a
concrete preferences implementation.

## Dependencies

- `app_preferences` — `AbstractPreferencesInterface` and the concrete
  backends: `PlatformPreferences`, `HivePreferences`, `MockPreferences`,
  plus `HiveInitMode`
- `service_locator` — `ServiceClass`, `LazyAsyncServiceDescriptor`,
  `ServiceItemTimeout`

## Library structure

```
lib/
├── app_preferences_service.dart          # Barrel
└── src/
    ├── app_preferences.dart              # AppPreferences service handle
    └── app_preferences_descriptor.dart   # Descriptor + backend selector
```

## API

### AppPreferences

The service-locator handle for the preferences store. Exposes a single
`AbstractPreferencesInterface` via `prefs`. Other services that need
preferences access declare a dependency on this service class and read
`prefs` from the locator. The concrete backend — platform, Hive, or mock —
is invisible to consumers; it is selected entirely by the descriptor used at
registration time.

```dart
class AppPreferences implements ServiceClass {
  const AppPreferences(this.prefs);
  final AbstractPreferencesInterface prefs;
}
```

### AppPreferencesBackend

Backend selector enum for the descriptor:

| Value      | Backing store                | Notes                          |
| ---------- | ---------------------------- | ------------------------------ |
| `platform` | `SharedPreferencesAsync`     | Platform-native, no cache      |
| `hive`     | `hive_ce`                    | Dart-native, file-backed       |
| `mock`     | In-memory map                | Test/dev only, no persistence  |

### AppPreferencesDescriptor

A `LazyAsyncServiceDescriptor<AppPreferences>` with one named constructor
per backend. All three are `const`; backend-specific fields not used by a
given constructor are pinned to `null`.

- **`AppPreferencesDescriptor.platform`** — builds `PlatformPreferences`
  over `SharedPreferencesAsync` for on-device persisted values.
- **`AppPreferencesDescriptor.hive`** — builds `HivePreferences`. Requires
  `boxName` (the Hive box storing preferences); `initMode` selects the
  storage location (defaults to `HiveInitMode.productionDocuments`) and
  `customPath` is required when `initMode` is `HiveInitMode.custom`. Building
  additionally initializes Hive against the chosen location and opens the
  named box.
- **`AppPreferencesDescriptor.mock`** — builds `MockPreferences`, optionally
  seeded with `initialValues` at construction.

All variants share `serviceName` (default `'AppPreferences'`), declare no
`dependencies`, and enforce a 500ms build `timeout`.

#### Build flow and timeout

`builder` awaits the backend construction with `Future.timeout(timeout)` and
converts a `TimeoutException` into the locator's `ServiceItemTimeout(name,
timeout)`, so a hung backend surfaces as a well-typed startup failure rather
than an unbounded await.

The backend construction itself lives in `build()`, exposed as `@protected`
and `@visibleForTesting`: subclasses can substitute a slow or failing
implementation to exercise the timeout branch in `builder` without touching
real storage.

## Usage

Register one descriptor per app; consumers resolve `AppPreferences` from the
locator and use `prefs`.

```dart
// Production — Hive-backed.
const AppPreferencesDescriptor.hive(boxName: 'preferences');

// Production — platform-backed.
const AppPreferencesDescriptor.platform();

// Tests — in-memory, seeded.
const AppPreferencesDescriptor.mock(
  initialValues: {'themeMode': 'dark'},
);
```

Swapping backends is a one-line change at registration; no consumer code
changes.

## Conventions

- Curated barrel exports in `lib/app_preferences_service.dart`.
- One class per file.
- `const` descriptors throughout; backend selection is data, not behavior,
  until `build()` runs.
- Test seams (`build()`) are explicit and annotated rather than reached via
  reflection or global mutation.