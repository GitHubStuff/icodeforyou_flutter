# ice_chips

Stadium-shaped, auto-contrasting tag chips for Flutter, with selection state managed by a Cubit and a sealed layout strategy. Designed to work either standalone over your own data or wired to the `since_when` glossary via a built-in `TagsCubit`.

## Features

- **`IceChip`** — single stadium-shaped chip that auto-picks black/white label text based on background luminance, with an optional border for the selected state.
- **`IceChipData`** — domain-free DTO (`id`, `label`, `colorInt`) that decouples the tray from your data source.
- **`IceChipsTray`** — renders a collection of chips, reads selection from an ambient `IceChipsTrayCubit`, and delegates spatial arrangement to a layout strategy.
- **Sealed `IceChipsTrayLayout`** — three concrete layouts (`Wrap`, `List`, `Row`); new layouts are added as new sealed cases without touching the tray.
- **`IceChipsTrayCubit`** — pure UI selection state — `Set<int>` of selected ids with `toggle`, `selectAll`, `clear`, `isSelected`, and `count`.
- **Per-chip decoration** — `IceChipsChipBuilder` callback lets you wrap each chip in a `Dismissible`, `Tooltip`, `Padding`, or any composition without forking the tray.
- **`TagsCubit` + sealed `TagsState`** — loads `RecordTagDefinition`s from the glossary, with reload-after-mutate semantics and a four-case state hierarchy (`Initial`, `Loading`, `Loaded`, `Error`).
- **Interface-segregated writes** — `TagsCubit` accepts four narrow interfaces (`GlossaryReader`, `GlossaryRepository`, `GlossaryWriter`, `GlossaryDeleter`); pass `null` for the ones you don't need and the cubit raises a descriptive `StateError` if those methods are called.
- **`IcePickerTray`** — glue widget that bridges `TagsCubit` data into an `IceChipsTray` selection UI, rendering each `TagsState` case appropriately.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ice_chips: ^1.0.0
```

Then import the barrel:

```dart
import 'package:ice_chips/ice_chips.dart';
```

### About the glossary types

This package currently re-exports `GlossaryReader`, `GlossaryRepository`, `GlossaryWriter`, `GlossaryDeleter`, `RecordTagDefinition`, and `SinceWhenFailure` from a stand-in file (`glossary_types_todo.dart`). They will be replaced by imports from the real `since_when` package once it ships, after which consumers should import those types directly from `since_when` and stop relying on the `ice_chips` re-exports.

## Usage

### Standalone — your own data through `IceChipsTray`

For the simplest case, hold your own list of chip data and let `IceChipsTrayCubit` track selection:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key, required this.categories});

  final List<IceChipData> categories;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IceChipsTrayCubit(),
      child: IceChipsTray(
        chipCount: categories.length,
        chipDataAt: (i) => categories[i],
        layout: const IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8),
      ),
    );
  }
}

// Translate your domain to IceChipData at the call site:
final categories = myCategories
    .map((c) => IceChipData(id: c.dbId, label: c.name, colorInt: c.argb))
    .toList();
```

Tapping any chip toggles its id in the cubit's `Set<int>`. Read the selection back from anywhere with `context.read<IceChipsTrayCubit>().state`.

### Pre-selecting and reading the selection

```dart
final tray = context.read<IceChipsTrayCubit>();

tray.selectAll([3, 7, 12]);     // replace the selection
tray.isSelected(7);             // true
tray.count;                     // 3
tray.clear();                   // empty

// Listen for changes:
BlocListener<IceChipsTrayCubit, Set<int>>(
  listener: (context, ids) => onSelectionChanged(ids),
  child: const IceChipsTray(...),
)
```

### Choosing a layout

`IceChipsTrayLayout` is sealed — pick the case that fits, or extend it for a custom one:

```dart
// Filter bar that wraps to new rows as needed:
const IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8)

// Scrollable list — required for swipe-to-dismiss edit modes, and the
// right choice for very long collections that benefit from lazy build.
const IceChipsTrayLayoutList(
  scrollDirection: Axis.vertical,
  shrinkWrap: true,
)

// Single horizontal row, eager — for short fixed-size sets:
const IceChipsTrayLayoutRow(spacing: 6)
```

### Decorating chips with `chipBuilder`

`IceChipsChipBuilder` wraps each rendered chip without forking the tray. Pair it with `IceChipsTrayLayoutList` for swipe-to-delete:

```dart
IceChipsTray(
  chipCount: tags.length,
  chipDataAt: (i) => tags[i],
  layout: const IceChipsTrayLayoutList(shrinkWrap: true),
  chipBuilder: (context, data, chip) {
    return Dismissible(
      key: ValueKey(data.id),
      direction: DismissDirection.endToStart,
      background: const ColoredBox(color: Colors.red),
      onDismissed: (_) => context.read<TagsCubit>().remove(data.id),
      child: chip,
    );
  },
)
```

The builder receives the chip's `IceChipData` and the already-rendered `IceChip` widget — return whatever wrapping you want, or the chip itself unchanged.

### Glossary-backed — `TagsCubit` + `IcePickerTray`

When the chip data lives in the `since_when` glossary, wire up a `TagsCubit` and let `IcePickerTray` handle state rendering:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => TagsCubit(
        reader: glossaryReader,
        repository: glossaryRepository, // optional
        writer: glossaryWriter,         // optional
        deleter: glossaryDeleter,       // optional
      )..load(),
    ),
    BlocProvider(create: (_) => IceChipsTrayCubit()),
  ],
  child: const IcePickerTray(
    layout: IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8),
  ),
)
```

`IcePickerTray` renders each `TagsState` case for you:

- `TagsInitial` → `SizedBox.shrink()`.
- `TagsLoading` → small `CircularProgressIndicator` with padding.
- `TagsError` → error text in the theme's `colorScheme.error`.
- `TagsLoaded` → `IceChipsTray` with the loaded data.

### Mutating the glossary

Mutations on `TagsCubit` reload the list on success and emit `TagsError` on failure, so the cubit's state always matches the database:

```dart
final tags = context.read<TagsCubit>();

await tags.add(tagName: 'Urgent', color: 0xFFFF3B30);
await tags.update(existing.copyWith(color: 0xFF34C759));
await tags.remove(existing.id!);
```

### Read-only cubits

`TagsCubit` follows the Interface Segregation Principle — the read interface is required, the write/update/delete interfaces are optional. A read-only consumer can omit them:

```dart
// Display-only tray — load() and the loaded list are all that's used.
final cubit = TagsCubit(reader: glossaryReader)..load();
```

Calling `add`, `update`, or `remove` on a read-only cubit throws `StateError` with a descriptive message naming the method and the missing interface — so the failure is loud and immediate at the call site.

## Layout reference

| Layout | Build mode | Best for |
| --- | --- | --- |
| `IceChipsTrayLayoutWrap` | Eager (all chips up front) | Filter bars, tag clouds, anything that should reflow to fit. |
| `IceChipsTrayLayoutList` | Lazy (`ListView.builder`) | Long lists, swipe-to-dismiss edit modes, scrollable horizontal strips. |
| `IceChipsTrayLayoutRow` | Eager | Short, fixed-size horizontal sets that should never wrap. |

For long horizontal sets, prefer `IceChipsTrayLayoutList` with `scrollDirection: Axis.horizontal` over `IceChipsTrayLayoutRow`.

## Additional information

`IceChipsTrayCubit` is scoped per tray — `BlocProvider` it at the appropriate scope (typically per screen) so multiple trays on the same screen each get their own selection state. `TagsCubit`, by contrast, is usually app-wide and provided once via `BlocProvider.value`. The glossary types currently re-exported from this package will move to `since_when` in a future release.
