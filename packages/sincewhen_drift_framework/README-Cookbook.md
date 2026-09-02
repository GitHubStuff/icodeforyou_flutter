# packages/sincewhen_drift_framework/COOKBOOK.md

# SinceWhen Persistence Cookbook

Three parts:

- **Part 1** — Directory rules: what lives where, what each file may know.
- **Part 2** — Changes to existing tables (column add/rename/remove, new query).
- **Part 3** — New-table template: adding `new_table` end to end in a
  future version of `sincewhen_models` + `sincewhen_drift_framework`.

Current spelling standard: `Timestamp` (never `TimeStamp`). Dev-mode
schema policy: `schemaVersion` stays 1, no migrations — schema changes
mean deleting persisted dev database files so `onCreate` rebuilds.

---

# Part 1 — Directory rules

## packages/sincewhen_models/

| Path | Holds | Rules |
|---|---|---|
| `lib/src/models/` | One entity per table (`since_when_item.dart`, `glossary_item.dart`, `tag_item.dart`) | Pure Dart. `final class X extends Equatable`. Constructor parameter names MUST equal the table's column getter names. `copyWith` (sentinel pattern for nullable fields), `props`, `stringify => true`. NO drift, NO flutter, ever. |
| `lib/src/repositories/` | One contract per table (`*_repository.dart`) | `abstract interface class`. Entities and Dart core types only in signatures. |
| `lib/sincewhen_models.dart` | Barrel | Exports every model and contract, alphabetical. |
| `pubspec.yaml` | — | `equatable` is the only runtime dependency. If a drift or flutter dependency ever appears here, stop — the architecture is broken. |

## packages/sincewhen_drift_framework/

| Path | Holds | Rules |
|---|---|---|
| `lib/src/tables/<name>_items/` | Table + DAO pair (`<name>_items.dart`, `<name>_items_dao.dart`) | Table: `@UseRowClass(Entity)`, `.named('camelCase')` on every multi-word column (codebase standard). DAO: ALL drift statements live here — queries, companion mappers, nothing leaks out. |
| `lib/src/repositories/` | One impl per contract (`drift_<name>_repository.dart`) | Pure delegation to the DAO. One line per method. NO drift statements — if you're writing `select(...)` here, it belongs in the DAO. |
| `lib/src/database/` | `database.dart`, `database_opening.dart` | `@DriftDatabase(tables: [...], daos: [...])` registers every table/DAO pair. `schemaVersion` 1 while in dev. |
| `lib/src/startup_methods.dart` | One `registerXxxDao` + one `registerXxxRepository` per table | Repositories register against the CONTRACT type from `sincewhen_models`, never the concrete impl. Alphabetical function order. |
| `lib/src/sincewhen_startup.dart` | `SinceWhenStartup` facade + `SinceWhenConfiguration` sealed hierarchy | The only public startup surface. Calls every registration; apps never see individual `registerXxx` functions. |
| `lib/sincewhen_drift_framework.dart` | Barrel | `show` combinators, alphabetical. Exports: database types, repository impls, the facade + configurations, tables/DAOs only where genuinely needed. `startup_methods.dart` is NOT exported. |

## programs/<app>/

| Path | Holds | Rules |
|---|---|---|
| `lib/app/since_when_configurations.dart` | Program-specific configs (`SinceWhenDevConfigurations`) | Pure data: which `SinceWhenConfiguration` + file names. No logic. |
| `lib/main.dart` | Composition root | The ONLY app file that imports `sincewhen_drift_framework`. Calls `SinceWhenStartup.start(resolver, configuration)` as a startup task. |
| Everything else | Features, blocs, screens | Import `sincewhen_models` only. Resolve contracts (`SinceWhenRepository` etc.) from DI. An import of the framework outside `main.dart` is a leak. |

---

# Part 2 — Changes to existing tables

## 2.1 Add a column

Touch, in order:

1. **Entity** (`sincewhen_models/lib/src/models/`) — field, constructor
   param (name == column getter), `copyWith` (sentinel if nullable),
   `props` entry.
2. **Table** — column getter with `.named('camelCase')`.
3. **DAO** — add the field to `_toInsertCompanion` and
   `_toUpdateCompanion`: `newField: Value(item.newField)`.
4. `dart run build_runner build` in the framework.
5. Delete persisted dev database files.

NOT touched: contract, repository impl, database, startup, barrels.

## 2.2 Rename a column

Same file set as 2.1 — entity field, table getter AND `.named()` string,
companion fields — plus any DAO/contract/impl method names containing the
old word, plus `#symbol` references in OTHER tables' foreign keys
(`tag_items.dart` references `#createdTimestamp` in both parent tables).
Then steps 4–5. VSCode: case-sensitive search/replace, exclude `*.g.dart`.

## 2.3 Remove a column

Reverse of 2.1: entity (field, ctor, copyWith, props), table getter, both
companion mappers. Search app code for entity-field usages FIRST. Then
steps 4–5.

## 2.4 Add a query/operation

Touch, in order:

1. **Contract** — the signature. Entities and core types only.
2. **DAO** — the actual drift statement.
3. **Repository impl** — one-line delegation.

The compiler enforces 3 after 1. No build_runner needed for plain
selects. NOT touched: entity, table, database, startup, barrels.

## 2.5 Change table constraints (unique, check, FK)

Table file only, then build_runner + dev-db wipe. If a FK target column
gains/loses `unique()`, remember SQLite requires FK targets to be
uniquely constrained.

---

# Part 3 — New-table template: `new_table`

Adding a table called `newTable` with entity `NewTableItem`. Eleven
files, in dependency order — each compiles against the previous.

## In sincewhen_models

**1. `lib/src/models/new_table_item.dart`**

```dart
import 'package:equatable/equatable.dart';

final class NewTableItem extends Equatable {
  const NewTableItem({
    required this.id,
    required this.createdTimestamp,
    // one param per column, names == table column getters
  });

  final int id;
  final int createdTimestamp;

  NewTableItem copyWith({...}) => ...;   // sentinel pattern for nullables

  @override
  List<Object?> get props => [id, createdTimestamp, ...];

  @override
  bool get stringify => true;
}
```

**2. `lib/src/repositories/new_table_repository.dart`**

```dart
abstract interface class NewTableRepository {
  Future<List<NewTableItem>> allItems();
  Stream<List<NewTableItem>> watchAllItems();
  Future<int> itemCount();
  Stream<int> watchItemCount();
  Future<NewTableItem> insertItem(NewTableItem item);
  Future<bool> updateItem(NewTableItem item);   // omit for join tables
  Future<bool> deleteItem(NewTableItem item);
  // + table-specific lookups
}
```

**3. Barrel `lib/sincewhen_models.dart`** — two exports, alphabetical.

## In sincewhen_drift_framework

**4. `lib/src/tables/new_table_items/new_table_items.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

@UseRowClass(NewTableItem) //Connects to the pure dart model
class NewTableItems extends Table {
  @override
  String get tableName => 'newTable';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get createdTimestamp =>
      integer().named('createdTimestamp').unique()();
  // .named('camelCase') on every multi-word column
  // FK columns: integer().references(OtherTable, #columnGetter,
  //     onDelete: KeyAction.cascade)()
}
```

**5. `lib/src/tables/new_table_items/new_table_items_dao.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/new_table_items/new_table_items.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

part 'new_table_items_dao.g.dart';

@DriftAccessor(tables: [NewTableItems])
class NewTableItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$NewTableItemsDaoMixin {
  NewTableItemsDao(super.attachedDatabase);

  // one method per contract entry; ALL drift statements here
  // insertItem via into(...).insertReturning(_toInsertCompanion(item))
  // _toInsertCompanion / _toUpdateCompanion at the bottom
}
```

**6. `lib/src/database/database.dart`** — add to BOTH annotation lists:

```dart
@DriftDatabase(
  tables: [GlossaryItems, NewTableItems, SinceWhenItems, TagItems],
  daos: [GlossaryItemsDao, NewTableItemsDao, SinceWhenItemsDao, TagItemsDao],
)
```

plus the two imports (`show`-scoped, alphabetical).

**7. `lib/src/repositories/drift_new_table_repository.dart`**

```dart
final class DriftNewTableRepository implements NewTableRepository {
  const DriftNewTableRepository(this._dao);
  final NewTableItemsDao _dao;
  // one-line delegation per contract method
}
```

**8. `lib/src/startup_methods.dart`** — two functions, alphabetical
placement, contract-typed registration:

```dart
Future<void> registerNewTableItemsDao(DependencyContainer container) async {
  container.registerLazySingleton<NewTableItemsDao>(
    () => container.get<SinceWhenDatabase>().newTableItemsDao,
  );
}

Future<void> registerNewTableRepository(DependencyContainer container) async {
  container.registerLazySingleton<NewTableRepository>(
    () => DriftNewTableRepository(container.get<NewTableItemsDao>()),
  );
}
```

**9. `lib/src/sincewhen_startup.dart`** — two calls in `setup`, DAO
block then repository block:

```dart
await registerNewTableItemsDao(container);
// ...
await registerNewTableRepository(container);
```

plus the two names in the `startup_methods.dart` import's `show` list.

**10. Barrel `lib/sincewhen_drift_framework.dart`** — export
`DriftNewTableRepository`; the register functions stay internal (facade
covers them).

## Finish

**11.** `dart run build_runner build` in the framework; delete persisted
dev database files (in-memory mode needs nothing). App code: nothing —
the facade already registers the new pair; features resolve
`NewTableRepository` from DI and import `sincewhen_models` only.

## Version bumps

`sincewhen_models` gains public API → bump its `version`; framework's
dependency constraint (`sincewhen_models: ^1.0.0`) already tolerates
minor bumps. Framework gains public API → bump its version likewise.

---

# Invariants (all parts)

- Drift never appears in `sincewhen_models`.
- Repository impls: delegation only, no drift statements.
- DI registers contracts, never impls.
- Entity constructor param names == table column getters, exactly.
- `Timestamp` spelling; `.named('camelCase')` on multi-word columns.
- Apps: framework imported in `main.dart` only; features import
  `sincewhen_models` only.
- `melos bootstrap` after any pubspec change; `build_runner` after any
  table/DAO change; dev-db wipe after any schema change.