# app_preferences

A swappable preferences abstraction with three backend implementations behind a single asynchronous interface — Hive for fast file-backed reads, native platform preferences for low-frequency settings, and an in-memory mock for tests.

## Features

- **One interface, three backends** — `AbstractPreferencesInterface` is the contract; `HivePreferences`, `PlatformPreferences`, and `MockPreferences` are interchangeable implementations.
- **Five primitive types** — `String`, `int`, `double`, `bool`, and `List<String>`. Reads return `null` when the key is absent or the stored value is the wrong type.
- **Async by default** — every operation returns a `Future`, so backends without an in-memory cache (like `SharedPreferencesAsync`) and backends with native sync reads (like Hive) sit behind the same surface.
- **Structural operations** — `remove(key)`, `clear()`, and `contains(key)`.
- **Hive multi-store support** — `HivePreferences.create(boxName:)` opens a named box, so independent preference stores can coexist in the same app.
- **Test-friendly mock** — `MockPreferences` exposes `reset()`, `snapshot()`, and `peek()` for setup, assertions, and stored-type checks.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  app_preferences: ^1.0.0
```

Then import it where you need it:

```dart
import 'package:app_preferences/app_preferences.dart';
```

Pick the backend that fits the call site:

| Backend | Use when | Storage |
| --- | --- | --- |
| `HivePreferences` | You want fast file-backed reads, multiple named stores, or your own custom path. | Hive box on disk. |
| `PlatformPreferences` | You want OS-native preferences (NSUserDefaults, SharedPreferences, IndexedDB) and reads are low-frequency. | Platform store via `SharedPreferencesAsync`. |
| `MockPreferences` | You're writing tests or running in a dev/CI harness with no real persistence. | In-memory `Map`. |

All three implement `AbstractPreferencesInterface`, so production code should depend on the interface and accept any implementation by injection.

## Usage

### Hive backend

Hive needs a one-time `init` per app run, then any number of named stores can be opened via `create`. Choose the `HiveInitMode` that matches your platform and backup requirements:

```dart
import 'package:app_preferences/app_preferences.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // One-time init. Pick the mode that fits your needs:
  //   test                 — system temp directory, OS-reclaimed
  //   productionDocuments  — backed up on iOS / iCloud
  //   productionSupport    — not backed up on iOS
  //   custom               — pass `customPath: '/your/path'`
  await HivePreferences.init(mode: HiveInitMode.productionSupport);

  // Open a named box. Open as many as you need.
  final settings = await HivePreferences.create(boxName: 'user_settings');

  await settings.setString('theme', 'dark');
  await settings.setInt('launch_count', 42);

  final theme = await settings.getString('theme');           // 'dark'
  final launches = await settings.getInt('launch_count');    // 42
  final missing = await settings.getString('not_a_key');     // null

  // A second, independent store for unrelated state.
  final cache = await HivePreferences.create(boxName: 'feature_flags');
  await cache.setBool('beta_enabled', true);
}
```

### Platform-native backend

`PlatformPreferences` routes every call through `SharedPreferencesAsync`, so it has no in-memory cache — every call crosses the platform channel. Best for low-frequency settings:

```dart
import 'package:app_preferences/app_preferences.dart';

Future<void> example() async {
  final prefs = await PlatformPreferences.create();

  await prefs.setBool('notifications_enabled', true);
  await prefs.setStringList('favourite_tags', ['flutter', 'dart']);

  final enabled = await prefs.getBool('notifications_enabled');  // true
  final tags = await prefs.getStringList('favourite_tags');      // [flutter, dart]

  if (await prefs.contains('legacy_flag')) {
    await prefs.remove('legacy_flag');
  }
}
```

### In-memory mock for tests

`MockPreferences` is synchronous-internally but exposes the same async surface, so it drops in anywhere the interface is accepted. Seed it via the constructor, inspect it via `snapshot()`, wipe it via `reset()`:

```dart
import 'package:app_preferences/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsService', () {
    late MockPreferences prefs;

    setUp(() {
      prefs = MockPreferences(initialValues: {
        'theme': 'light',
        'launch_count': 0,
      });
    });

    test('increments launch_count on app start', () async {
      final service = SettingsService(prefs);

      await service.recordLaunch();

      expect(await prefs.getInt('launch_count'), 1);
      expect(prefs.snapshot(), containsPair('launch_count', 1));
    });

    test('reset clears the store between cases', () {
      prefs.reset();
      expect(prefs.snapshot(), isEmpty);
    });
  });
}
```

### Depending on the interface, not the implementation

Production code should accept `AbstractPreferencesInterface` so the backend is swappable per call site, per environment, or per test:

```dart
import 'package:app_preferences/app_preferences.dart';

class SettingsService {
  SettingsService(this._prefs);

  final AbstractPreferencesInterface _prefs;

  static const _kTheme = 'theme';
  static const _kLaunchCount = 'launch_count';

  Future<String> theme() async => await _prefs.getString(_kTheme) ?? 'system';

  Future<void> setTheme(String value) => _prefs.setString(_kTheme, value);

  Future<int> launchCount() async => await _prefs.getInt(_kLaunchCount) ?? 0;

  Future<void> recordLaunch() async {
    final current = await launchCount();
    await _prefs.setInt(_kLaunchCount, current + 1);
  }
}
```

Then wire it up at the composition root:

```dart
// Production
final prefs = await HivePreferences.create(boxName: 'user_settings');
final service = SettingsService(prefs);

// Tests
final service = SettingsService(MockPreferences());
```

## Interface reference

`AbstractPreferencesInterface` exposes the same five typed read/write pairs across every backend, plus three structural operations:

| Category | Methods |
| --- | --- |
| Reads | `getString`, `getInt`, `getDouble`, `getBool`, `getStringList` |
| Writes | `setString`, `setInt`, `setDouble`, `setBool`, `setStringList` |
| Structural | `remove(key)`, `clear()`, `contains(key)` |

Every read returns `null` when the key is absent or the stored value is not the requested type. Writes complete once the value has been persisted to the backing store.

## Additional information

`HivePreferences.init()` is one-time per app run and asserts on a second call. In tests, use `HivePreferences.resetForTesting()` to clear the initialization flag between cases.
