# since_when_framework

Generic SQLite lifecycle scaffold plus `since_when` table setup and reset.

Two independent layers, each with its own barrel file:

| Layer | Barrel | Purpose |
|---|---|---|
| `database` | `package:since_when_framework/database.dart` | Reusable SQLite plumbing: configuration, handle, lifecycle cubit, pluggable setup / import / export interfaces, sealed failure hierarchy. |
| `since_when` | `package:since_when_framework/since_when.dart` | The `since_when` schema: `setup()` to create the three tables + indexes, `reset()` to drop them and erase the on-device file. |

The `since_when` layer sits **on top of** the `database` layer. The database layer knows nothing about `since_when` tables; the `since_when` layer never reaches around the handle to touch the filesystem directly except through a `DatabaseConfiguration`.

---

## Installation

In your package's `pubspec.yaml`:

```yaml
dependencies:
  since_when_framework: ^0.1.0
```

Then import the layer(s) you need:

```dart
import 'package:since_when_framework/database.dart';
import 'package:since_when_framework/since_when.dart';
```

---

## The `database` layer

### `DatabaseConfiguration` — write-once, use-everywhere

A single sealed value carries everything the framework needs to resolve a path, open the connection, and (later) erase the file. Three variants:

```dart
// Under the platform's application documents directory.
const cfg = DatabaseConfiguration.documents(
  dbName: 'app.db',
  subdirectory: 'db',                  // optional, defaults to 'db'
  access: DatabaseAccess.automatic,    // create | open | automatic
);

// Under the platform's application support directory.
const cfg = DatabaseConfiguration.applicationSupport(
  dbName: 'app.db',
);

// In-memory, for tests and the sqlite_viewer workflow.
const cfg = DatabaseConfiguration.inMemory();
```

`DatabaseAccess` controls open-time behaviour for file-backed configurations:

- `create` — fail if the file already exists.
- `open` — fail if the file does not exist.
- `automatic` — create if absent, open if present (default).

### `DatabaseHandle` — the SQL seam

Every consumer of the database — setup contributions, importers/exporters, your repositories — speaks SQL through `DatabaseHandle`. The default backend is sqflite (`SqfliteHandle`); swap it out by injecting a different `HandleFactory` into the lifecycle cubit.

```dart
abstract interface class DatabaseHandle {
  Future<List<Map<String, Object?>>> query(String sql, [List<Object?> args]);
  Future<int> execute(String sql, [List<Object?> args]);
  Future<T> transaction<T>(Future<T> Function(DatabaseHandle txn) work);
  bool get isOpen;
  Future<void> close();
}
```

### `DatabaseLifecycleCubit` — owns the connection's lifecycle

States (sealed):

```
Closed ─► Opening ─► InstallingSchema ─► Ready ─► Closing ─► Closed
Ready  ─► Importing ─► Ready
Ready  ─► Exporting ─► Ready
any    ─► Failed(cause)
```

Open with a configuration and any number of `DatabaseSetup` contributions:

```dart
final cubit = DatabaseLifecycleCubit();

await cubit.open(
  configuration: const DatabaseConfiguration.documents(dbName: 'app.db'),
  setups: const [SinceWhenSetup()],   // see "Using since_when" below
);

// state is now DatabaseReady(handle: ...)
final handle = cubit.currentHandle!;
```

Then import or export at will:

```dart
await cubit.import(MyJsonSnapshotImporter(path: '/tmp/snap.json'));
await cubit.export(MySqlDumpExporter(path: '/tmp/dump.sql'));
```

Close when done:

```dart
await cubit.closeDatabase();
```

### `DatabaseSetup` — pluggable schema installers

Implement this for each package or feature that contributes tables. Run in order during `DatabaseInstallingSchema`, before `DatabaseReady` is emitted:

```dart
abstract interface class DatabaseSetup {
  String get name;
  Future<void> install(DatabaseHandle handle);
}
```

Implementations should be idempotent (`CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`) so reopening an existing database is a no-op.

### `DatabaseImporter` / `DatabaseExporter` — pluggable I/O

```dart
abstract interface class DatabaseImporter {
  String get name;
  Future<void> import(DatabaseHandle handle);
}

abstract interface class DatabaseExporter {
  String get name;
  Future<void> export(DatabaseHandle handle);
}
```

Implementations choose their own format (SQL dump, JSON snapshot, CSV, raw file copy, network upload, etc.). Wrap multi-row work in `handle.transaction(...)` so partial failures don't leave the database inconsistent.

### `DatabaseFailure` — sealed failure hierarchy

Every lifecycle failure is one of:

- `DatabaseInvalidName` — empty or whitespace `dbName`.
- `DatabaseAlreadyExists` — file present when `DatabaseAccess.create` was requested.
- `DatabaseNotFound` — file absent when `DatabaseAccess.open` was requested.
- `DatabaseOpenFailure(cause)` — anything else thrown during open.
- `DatabaseSetupFailure(setupName, cause)` — a setup contribution threw.
- `DatabaseImportFailure(importerName, cause)` — an importer threw.
- `DatabaseExportFailure(exporterName, cause)` — an exporter threw.
- `DatabaseCloseFailure(cause)` — close threw.
- `DatabaseEraseFailure(cause)` — file delete threw (`SinceWhen.reset`).

`switch` on `state.failure` to handle each case exhaustively.

---

## The `since_when` layer

Two static methods on `SinceWhen`:

### `SinceWhen.setup(handle)`

Creates the three since_when tables and their indexes inside a single transaction. Idempotent — safe to call on an already-initialised database.

```dart
final result = await SinceWhen.setup(handle);

result.fold(
  (failure) => print('setup failed: $failure'),
  (_) => print('since_when ready'),
);
```

The three tables:

- **`since_when`** — main records (`id`, `createdTimeStamp` UNIQUE, `reviewedTimeStamp`, `editedTimeStamp`, `parentTimeStamp`, `eventTimeStamp`, `sequenceNumber`, `metaData`, `data`).
- **`since_when_tag_glossary`** — tag definitions (`id`, `createdTimeStamp` UNIQUE, `tagName` UNIQUE, `color` UNIQUE).
- **`since_when_tags`** — join table linking records to tags, with FK cascades on both sides and a `UNIQUE(record_timestamp, glossary_timestamp)` constraint.

### `SinceWhen.reset(handle, configuration)`

Drops all three tables in a single transaction (child-first, to satisfy foreign-key constraints), then erases the on-device file for file-backed configurations.

```dart
final result = await SinceWhen.reset(handle, configuration);

result.fold(
  (failure) => print('reset failed: $failure'),
  (_) => print('since_when reset, file erased'),
);
```

**Lifecycle note:** sqflite holds the file open until you close the database. To actually delete the file:

```dart
final handle = cubit.currentHandle!;
final config = const DatabaseConfiguration.documents(dbName: 'app.db');

// Drop tables while still connected.
await SinceWhen.reset(handle, config);

// Close so sqflite releases the file lock.
await cubit.closeDatabase();
```

For in-memory configurations the file-erase step is a no-op.

---

## Wiring `SinceWhen` into the lifecycle cubit

`SinceWhen.setup` is a static method, not a `DatabaseSetup` implementation, so the calling app (or a thin adapter) bridges the two. The smallest adapter:

```dart
class SinceWhenSetup implements DatabaseSetup {
  const SinceWhenSetup();

  @override
  String get name => SinceWhen.setupName;

  @override
  Future<void> install(DatabaseHandle handle) async {
    final result = await SinceWhen.setup(handle);
    result.fold(
      (failure) => throw failure,
      (_) {},
    );
  }
}
```

Then:

```dart
await cubit.open(
  configuration: const DatabaseConfiguration.documents(dbName: 'app.db'),
  setups: const [SinceWhenSetup()],
);
```

The `Either`-throw bridge is intentional: `DatabaseSetup` signals failure with a thrown exception (the lifecycle cubit catches it and wraps it in `DatabaseSetupFailure`); `SinceWhen.setup` signals failure with `Left(DatabaseSetupFailure)`. The adapter converts one to the other so both APIs stay idiomatic.

---

## End-to-end example

```dart
import 'package:since_when_framework/database.dart';
import 'package:since_when_framework/since_when.dart';

Future<void> main() async {
  final cubit = DatabaseLifecycleCubit();

  // Open + install schema.
  await cubit.open(
    configuration: const DatabaseConfiguration.documents(
      dbName: 'app.db',
      access: DatabaseAccess.automatic,
    ),
    setups: const [SinceWhenSetup()],
  );

  if (cubit.state is! DatabaseReady) {
    print('open failed: ${cubit.state}');
    await cubit.close();
    return;
  }

  // Use the handle.
  final handle = cubit.currentHandle!;
  await handle.execute(
    '''
INSERT INTO since_when
  (createdTimeStamp, reviewedTimeStamp, editedTimeStamp,
   sequenceNumber, data)
VALUES (?, ?, ?, 0, ?)
''',
    [
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      '{"note":"hello"}',
    ],
  );

  // Tear down.
  await cubit.close();
}
```

---

## Testing tips

- Use `DatabaseConfiguration.inMemory()` for any test that needs a real SQL engine without filesystem noise.
- Inject a fake `HandleFactory` into `DatabaseLifecycleCubit` to test lifecycle transitions without sqflite.
- `SinceWhen.setup` and `SinceWhen.reset` return `Either<DatabaseFailure, Unit>`; assert on the `Left`/`Right` rather than catching exceptions.
- Indexes are created with `IF NOT EXISTS`, so `SinceWhen.setup` can be called repeatedly in a test without `_setUp` / `_setUpAll` gymnastics.
