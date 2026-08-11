# ice_chips

Domain-free chip rendering for Flutter, plus the glue that binds it to the
`since_when` tag glossary. The package splits cleanly into two halves: a
reusable tray/chip layer that knows nothing but `IceChipData` and integer
ids, and a tags layer that loads `RecordTagDefinition` rows through
role-segregated glossary interfaces and feeds them into the tray.

## Structure

```
lib/
├── ice_chips.dart                          # Public barrel
└── src/
    ├── glossary_types_todo.dart            # TEMPORARY glossary stand-ins
    ├── ice_chip_tray/
    │   ├── ice_chip_tray.dart              # IceChipsTray widget
    │   ├── ice_chip_tray_cubit.dart        # Selection state (Set<int>)
    │   ├── ice_chip_tray_layout.dart       # Sealed layout strategies
    │   └── ice_picker_tray.dart            # TagsCubit → tray glue widget
    ├── ice_chip_widget/
    │   ├── ice_chip.dart                   # Single chip (FilterChip)
    │   └── ice_chip_data.dart              # Chip DTO
    └── tags/
        ├── tags_cubit.dart                 # Glossary CRUD → observable state
        └── tags_state.dart                 # Sealed TagsState hierarchy
```

## Public API

### `ice_chips.dart`

The barrel. Exports everything below, including — for now — the glossary
placeholder types via a `show` clause. Consumers import
`package:ice_chips/ice_chips.dart` and nothing else.

### `src/glossary_types_todo.dart` — TEMPORARY

Stand-in for the future `since_when` package so `ice_chips` compiles
against `since_when_framework` alone. This file is the single source of
truth for these types during the stub period; `since_when_widgets` imports
them from here. Delete the entire file the day the real package ships —
the migration steps are documented at the top of the file.

Contents:

- **`SinceWhenFailure`** — typed failure for glossary CRUD. Wraps an
  underlying `DatabaseFailure` from `since_when_framework`; `Equatable`
  so it flows through `Either` and Cubit state comparisons.
- **`RecordTagDefinition`** — one row from `since_when_tag_glossary`:
  nullable auto-increment `id`, stable `createdTimeStamp` (the FK target
  from `since_when_tags.glossary_timestamp`), `UNIQUE` upper-cased
  `tagName`, `UNIQUE` ARGB32-packed `color`. Full `copyWith` and
  value equality.
- **Role-segregated interfaces** — `GlossaryReader.fetchAllTagDefinitions`,
  `GlossaryRepository.insertTagDefinition`,
  `GlossaryWriter.updateTagDefinition`,
  `GlossaryDeleter.deleteTagDefinition`. Four narrow interfaces instead
  of one god-object (ISP): tests substitute fakes per role, and read-only
  consumers construct a `TagsCubit` with only a reader.

## Chip layer (domain-free)

### `IceChipData` — `src/ice_chip_widget/ice_chip_data.dart`

Immutable DTO and the boundary type between domain models and the render
layer: `id` (selection and `Dismissible` key), `label`, `colorInt`
(packed ARGB). The tray and its Cubit operate exclusively on this type;
callers translate their domain records at the call site.

### `IceChip` — `src/ice_chip_widget/ice_chip.dart`

A single chip rendered as a `StadiumBorder` `FilterChip`. Background
comes from the packed `backgroundColorInt`; label color is computed via
`ColorExt.contrastingTextColor()` from `package:extensions`, with an
optional caller `TextStyle` merged over the bold 14pt default.
`showBorder` draws a 2px selection border — black in light themes, white
in dark, transparent when unselected. Taps forward to `onPress`.

### `IceChipsTrayCubit` — `src/ice_chip_tray/ice_chip_tray_cubit.dart`

`Cubit<Set<int>>` holding the selected chip ids. Pure UI state — no
persistence, no knowledge of the chip source. One instance per tray via
`BlocProvider` at the appropriate scope. API: `toggle`, `selectAll`,
`clear`, `isSelected`, `count`.

### `IceChipsTrayLayout` — `src/ice_chip_tray/ice_chip_tray_layout.dart`

Sealed strategy hierarchy deciding how the tray arranges its chips (OCP:
new layouts are new sealed cases; the tray never changes). All variants
are const-constructible:

| Layout | Widget | Materialization | Use for |
| --- | --- | --- | --- |
| `IceChipsTrayLayoutWrap` | `Wrap` | Eager | Display, flowing rows |
| `IceChipsTrayLayoutList` | `ListView.builder` | Lazy | Large sets, swipe-to-dismiss edit modes |
| `IceChipsTrayLayoutRow` | `Row` | Eager | Short single-line groups |

For long horizontal lists prefer `IceChipsTrayLayoutList` with
`scrollDirection: Axis.horizontal` over `IceChipsTrayLayoutRow`.

### `IceChipsTray` — `src/ice_chip_tray/ice_chip_tray.dart`

The tray. Reads `Set<int>` from the nearest `IceChipsTrayCubit`, renders
`chipCount` chips through `chipDataAt(index)`, and delegates spatial
arrangement to the injected layout strategy. Tapping a chip toggles its
id in the Cubit; membership drives `showBorder`. Per-chip decoration
(`Dismissible`, `Padding`, `Tooltip`, …) is delegated to an
`IceChipsChipBuilder` callback, defaulting to identity.

## Tags layer (glossary-aware)

### `TagsState` — `src/tags/tags_state.dart`

Sealed hierarchy covering the load lifecycle: `TagsInitial` (constructed,
not yet loaded), `TagsLoading`, `TagsLoaded(tags)`, and
`TagsError(failure)` carrying the typed `SinceWhenFailure` for
pattern-matching.

### `TagsCubit` — `src/tags/tags_cubit.dart`

Wraps the four glossary interfaces into observable state. `load()` emits
`TagsLoading` then `TagsLoaded`/`TagsError`. Mutations — `add`, `update`,
`remove` — reload on success (keeping the Cubit aligned with the
database's truth without in-memory diff logic) and emit `TagsError` on
failure. Only the reader is required at construction; calling a mutation
on a cubit built without the corresponding interface throws a
`StateError` naming the missing role.

### `IcePickerTray` — `src/ice_chip_tray/ice_picker_tray.dart`

Glue widget binding `TagsCubit` to an `IceChipsTray`. Renders the four
states as: nothing (`TagsInitial`), a small progress indicator
(`TagsLoading`), the failure text in the theme's error color
(`TagsError`), or the tray with each `RecordTagDefinition` translated to
an `IceChipData` (`TagsLoaded`). Layout, chip builder, and style pass
straight through to the tray.

## Usage

```dart
MultiBlocProvider(
  providers: [
    BlocProvider.value(value: iceChipsService.tagsCubit),
    BlocProvider(create: (_) => IceChipsTrayCubit()),
  ],
  child: const IcePickerTray(layout: IceChipsTrayLayoutWrap()),
)
```

For a tray driven by arbitrary domain data, skip the tags layer and use
`IceChipsTray` directly with your own `IceChipData` translation.

## Dependencies

`flutter_bloc` (Cubits), `equatable` (value types), `fpdart`
(`Either`/`Unit` on the glossary interfaces), `extensions`
(`contrastingTextColor`), `since_when_framework` (`DatabaseFailure`).
`fpdart` may become removable once the real `since_when` package ships,
if it re-exports the functional types.

## Testing

`test/` mirrors `lib/` one test file per source file, targeting 100%
LCOV. Cubit stream sequences are asserted with
`expectLater`/`emitsInOrder` registered before the action under test;
glossary roles are faked per interface; `SinceWhenFailure` causes are
constructed from the real sealed `DatabaseOpenFailure` variant.