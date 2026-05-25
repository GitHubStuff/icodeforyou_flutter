# app_preferences_service

A service-locator descriptor and handle for `app_preferences`. Registers the preferences store as a `LazyAsyncServiceDescriptor` so other services can depend on it, with the concrete backend (platform, Hive, or in-memory mock) chosen at registration time.

## Features

- **One service, three backends** — pick `.platform`, `.hive`, or `.mock` at registration; consumers always see the same `AppPreferences` handle.
- **Lazy async registration** — extends `LazyAsyncServiceDescriptor<AppPreferences>`, so the backend is constructed on first resolve, not at app start.
- **Hive setup baked in** — the `.hive` constructor calls `HivePreferences.init` against the chosen `HiveInitMode` and opens the named box for you.
- **Test seeding** — the `.mock` constructor accepts an `initialValues` map for deterministic test fixtures.
- **Built-in timeout** — construction is wrapped in a 500 ms timeout; exceeding it throws `ServiceItemTimeout` for the locator to surface.
- **Custom service name** — every constructor accepts `serviceName` so multiple preference stores can coexist under different locator names.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  app_preferences_service: ^1.0.0
```

Then import it where you wire up your services:

```dart
import 'package:app_preferences_service/app_preferences_service.dart';
```

This package builds on `app_preferences` (the backend implementations) and `service_locator` (the registration/resolution mechanism). Consumers depend on `AppPreferences` — not on a concrete backend — so the storage choice stays a composition-root decision.

## Usage

### Choosing a backend

`AppPreferencesDescriptor` has three named constructors, one per backend:

```dart
// Platform-native — SharedPreferencesAsync on iOS/Android/web/macOS.
const platform = AppPreferencesDescriptor.platform();

// Hive — file-backed, fast reads, named box.
const hive = AppPreferencesDescriptor.hive(
  boxName: 'user_settings',
  initMode: HiveInitMode.productionSupport,
);

// Mock — in-memory, optionally seeded. Tests and dev harnesses only.
const mock = AppPreferencesDescriptor.mock(
  initialValues: {'theme': 'dark', 'launch_count': 0},
);
```

Each constructor accepts an optional `serviceName` (default `'AppPreferences'`) so you can register multiple independent stores side by side:

```dart
const userPrefs = AppPreferencesDescriptor.hive(
  boxName: 'user_settings',
  serviceName: 'UserPreferences',
);

const featureFlags = AppPreferencesDescriptor.hive(
  boxName: 'feature_flags',
  serviceName: 'FeatureFlags',
);
```

### Consuming the handle

Once the descriptor has been registered through your `service_locator` setup and resolved, the `AppPreferences` handle exposes the underlying `AbstractPreferencesInterface` on its `prefs` field:

```dart
final appPrefs = /* resolved AppPreferences from the locator */;

await appPrefs.prefs.setString('theme', 'dark');
final theme = await appPrefs.prefs.getString('theme');     // 'dark'

await appPrefs.prefs.setInt('launch_count', 42);
final launches = await appPrefs.prefs.getInt('launch_count'); // 42

if (await appPrefs.prefs.contains('legacy_flag')) {
  await appPrefs.prefs.remove('legacy_flag');
}
```

A service that needs preferences should declare its dependency on `AppPreferences` in its own descriptor and read `prefs` from it — never reach for a concrete backend directly.

### Hive backend with a custom path

When you need the Hive box to live somewhere specific (a shared container directory, a per-flavor folder, an external SD-card path), pair `HiveInitMode.custom` with `customPath`:

```dart
const descriptor = AppPreferencesDescriptor.hive(
  boxName: 'user_settings',
  initMode: HiveInitMode.custom,
  customPath: '/var/mobile/Containers/Shared/AppGroup/.../hive',
);
```

For all other modes (`productionDocuments`, `productionSupport`, `test`), the descriptor resolves the directory for you — no `customPath` needed.

### Test fixture with the mock backend

The mock backend wipes between app runs but accepts seed data at construction, which keeps integration tests deterministic without touching disk:

```dart
const descriptor = AppPreferencesDescriptor.mock(
  serviceName: 'AppPreferences',
  initialValues: {
    'theme': 'light',
    'launch_count': 5,
    'favourite_tags': ['flutter', 'dart'],
  },
);
```

After resolution, `appPrefs.prefs` is a `MockPreferences` that returns those seeded values on first read.

## Descriptor reference

| Constructor | Backend | Required | Optional |
| --- | --- | --- | --- |
| `.platform()` | `PlatformPreferences` | — | `serviceName` |
| `.hive(...)` | `HivePreferences` | `boxName` | `serviceName`, `initMode` (default `productionDocuments`), `customPath` |
| `.mock(...)` | `MockPreferences` | — | `serviceName`, `initialValues` |

All three resolve to the same `AppPreferences` handle, with the chosen backend exposed on `prefs`. Construction is wrapped in a 500 ms timeout; exceeding it throws `ServiceItemTimeout(name, timeout)`.

## Additional information

`AppPreferencesDescriptor.build()` is `@protected` and `@visibleForTesting`, so test subclasses can substitute a slow or failing implementation to exercise the timeout branch.
