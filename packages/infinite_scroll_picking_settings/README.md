# infinite_scroll_picking_settings

Settings screen and persistable visual configuration for the
`infinite_scroll_picking` package. This package owns everything about how a
picker's appearance is *stored, edited, and distributed* app-wide, while the
picker package itself stays JSON-free and settings-unaware. The seam between
the two is a pair of mapper extensions; the seam between this package and any
storage technology is a three-method repository interface.

## Structure

```
lib/
├── infinite_scroll_picking_settings.dart       # Public barrel
└── src/
    ├── json/
    │   └── duration_json_converter.dart        # Duration ↔ microseconds int
    ├── picker_visual_settings/
    │   └── picker_visual_settings.dart         # Persistable picker config (freezed)
    ├── wheel_settings/
    │   └── wheel_settings.dart                 # Persistable wheel config (freezed)
    ├── settings/
    │   ├── settings_repository.dart            # Persistence boundary (interface)
    │   ├── app_preferences_settings_repository.dart  # app_preferences impl
    │   ├── settings_state/settings_state.dart  # Sealed cubit state (freezed)
    │   ├── settings_cubit.dart                 # Edit-preview-save lifecycle
    │   ├── settings_holder.dart                # App-wide ValueListenable
    │   ├── settings_loader.dart                # Startup hydration
    │   ├── settings_scope.dart                 # InheritedNotifier provider
    │   └── settings_mapper.dart                # Settings ↔ runtime config
    └── widgets/
        ├── settings_screen.dart                # Full-screen editor
        ├── settings_screen_sections.dart       # (part) slider sections
        └── settings_screen_widgets.dart        # (part) actions & primitives
```

## The models

**`WheelSettings`** is a persistable mirror of `InfiniteScrollWheelConfig` —
identical fields, defaults, and asserts — existing solely to add JSON
serialization the picker package deliberately lacks. `Duration` fields
round-trip through **`DurationJsonConverter`** as microseconds (not
milliseconds), so sub-millisecond values survive storage exactly. The
converter is applied at the class level, so every `Duration` field picks it
up automatically.

**`PickerVisualSettings`** carries everything defining how a picker *looks* —
frame paddings, frame corner radius, the embedded `WheelSettings`, and the
`startingIndex` to land on. It deliberately does **not** carry `items` or
`pickerId`: those are runtime concerns owned by the consumer and have no
business in a JSON-serialized preference. Both models are freezed with
constructor asserts guarding their invariants (notably
`wheelHeight >= itemExtent * 1.1`, leaving room for the selection band and
fade).

## The mappers

`settings_mapper.dart` is the boundary between persistable and runtime types,
placed so neither side knows about the other:

- `WheelSettings.toWheelConfig()` — field-for-field into the runtime config.
- `InfiniteScrollWheelConfig.toWheelSettings()` — the reverse, for seeding
  settings from a config a consumer already has hard-coded.
- `PickerVisualSettings.toPickerConfig<T, K>(items:, pickerId:)` — combines
  the persisted visuals with the runtime-only `items` and `pickerId`, and
  asserts `items` is non-empty and `startingIndex < items.length` here at
  the boundary, since the settings type can't see `items`.

## Persistence

**`SettingsRepository`** is the DIP seam: `load()` (null means "nothing
saved — fall back to defaults"; throw means "broken store — surface an
error"), `save()`, and `clear()`. The whole settings object is one atomic
preference — no field-level partial saves, which prevents torn state when
one half writes and the other fails.

**`AppPreferencesSettingsRepository`** implements it over any
`AbstractPreferencesInterface` from `app_preferences` (shared_preferences,
Hive, or custom), storing the settings as a single JSON string under a
configurable `storageKey` (default `'InfiniteScrollPicking'`). Override the
key to namespace multiple setting sets in one store. It preserves the
missing/broken distinction: absent or empty key → `null`; present but
non-map JSON → `FormatException`; schema mismatch → whatever `fromJson`
throws.

## App-wide distribution

Three pieces move settings from disk to every live picker:

**`SettingsLoader.load(repository:)`** — call once during bootstrap, before
`runApp`. Reads the store and returns a seeded **`SettingsHolder`**. Failure
modes fall back to defaults silently (with a `debugPrint`) so a corrupt
store never blocks startup; callers needing telemetry or recovery UI should
call the repository directly instead.

**`SettingsHolder`** — the app-wide source of truth, a `ChangeNotifier`
implementing `ValueListenable<PickerVisualSettings>`. Mutated only by
`SettingsCubit` on a successful save; its `update` is a no-op on equal
values, avoiding spurious rebuilds.

**`SettingsScope`** — an `InheritedNotifier` wrapping the holder near the
root of the tree. `SettingsScope.of(context)` returns the holder without
subscribing (for callbacks); `SettingsScope.watch(context)` returns the
current settings and subscribes the caller to rebuilds (for `build`
methods). Both throw a descriptive `FlutterError` when no scope is present,
because settings access without a scope is a wiring bug.

```dart
final prefs = await PlatformPreferences.create();
final repo = AppPreferencesSettingsRepository(prefs);
final holder = await SettingsLoader.load(repository: repo);
runApp(SettingsScope(holder: holder, child: const MyApp()));
```

Anywhere in the app:

```dart
final settings = SettingsScope.watch(context);
final config = settings.toPickerConfig<int, String>(
  items: myItems,
  pickerId: 'myPicker',
);
```

## The editor

**`SettingsCubit`** orchestrates the edit-preview-save lifecycle over the
sealed **`SettingsState`** (`initial` / `loading` / `loaded(settings,
isDirty)` / `error(message)`). It constructs directly into `loaded(clean)`
from the already-seeded holder — no async load on screen entry. The core
invariant: edits live only in cubit state as previews; the holder — and
therefore every live picker — updates only when `save()` succeeds.
`reset()` previews defaults (dirty, uncommitted); `clearPersisted()` wipes
the store and commits defaults; failures emit `error` and leave the holder
untouched.

**`SettingsScreen`** renders a live picker preview pinned at the top and a
scrollable panel of slider sections below (frame, wheel dimensions,
selection band, perspective & motion, picker), with Save/Reset/Clear in the
AppBar and a current-values readout showing an "unsaved" chip when dirty.
Save is disabled while clean. The wheel-height sliders clamp against
`itemExtent * 1.1` so no drag can ever construct an invalid settings
object. The initial/loading arms of the screen are defensive only — the
normal flow never shows a spinner.

Provide the cubit above the screen:

```dart
BlocProvider(
  create: (context) => SettingsCubit(
    holder: SettingsScope.of(context),
    repository: repo,
  ),
  child: const SettingsScreen(),
)
```

## Dependencies

`infinite_scroll_picking` (runtime config types and the preview picker),
`app_preferences` (storage interface), `flutter_bloc` (cubit),
`freezed_annotation`/`json_annotation` (models; `build_runner` with
`freezed` and `json_serializable` for codegen).

## Testing

`test/` mirrors `lib/` one test file per source file — including one per
`part` file of the screen library, since LCOV attributes lines per file.
Conventions worth keeping: defensive screen arms are reached by forcing
cubit state *before* pumping so the first build renders them (no
stream-delivery races), and never `pumpAndSettle` an arm showing an
indeterminate spinner; Material `Slider` drags start at the widget center
and jump the thumb there, so only saturating drags are
position-deterministic — assert branch preconditions, not values relative
to defaults. Exclude generated files from coverage reports:
`lcov --remove coverage/lcov.info '**/*.freezed.dart' '**/*.g.dart'`.