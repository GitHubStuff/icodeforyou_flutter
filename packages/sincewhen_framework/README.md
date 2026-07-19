# sincewhen_framework
 
Enhanced Since_When database package. A cross-platform SQLite data layer built on
[drift](https://pub.dev/packages/drift), providing a single gateway class — `SinceWhen` —
for persistent and in-memory databases on iOS, Android, macOS, Linux, and Web.
 
## Features
 
- **One API, five platforms** — the same `SinceWhen.open()` / `SinceWhen.openInMemory()`
  calls work on iOS, Android, macOS, Linux, and Web.
- **Core schema managed for you** — the `since_when`, `glossary`, and `tags` tables are
  created automatically (idempotently, via `CREATE TABLE IF NOT EXISTS`) every time the
  database is opened. Foreign keys are enabled on every connection.
- **Extendable** — supply your own `CREATE TABLE` statements through `addTables`.
  Core tables cannot be redefined or dropped through the framework API.
- **In-memory mode** — a volatile database for development and testing. Runs in plain
  `dart test` with no plugins, paths, or devices.
- **Pure Dart package** — no Flutter dependency. Directory resolution is injected by the
  consuming app, keeping this package testable and platform-agnostic.
## Installation
 
In the consuming app's `pubspec.yaml`:
 
```yaml
dependencies:
  sincewhen_framework:
    path: ../packages/sincewhen_framework   # adjust to your workspace layout
  path_provider: ^2.1.6                     # the app resolves the storage directory
```
 
## Usage
 
### Persistent database (iOS, Android, macOS, Linux)
 
The app resolves a **persistent** directory and passes it in. The database file is always
named `SinceWhen.db`.
 
```dart
import 'package:path_provider/path_provider.dart';
import 'package:sincewhen_framework/sincewhen_framework.dart';
 
final dir = await getApplicationSupportDirectory();
final db  = await SinceWhen.open(directory: dir.path);
```
 
> **Use a persistent location.** `getApplicationSupportDirectory()` (or
> `getApplicationDocumentsDirectory()` if you want OS backup) is correct.
> Do **not** use `getTemporaryDirectory()` or a cache directory — the OS deletes
> cached files between launches, and your data will silently disappear.
 
### In-memory database (development and tests)
 
```dart
final db = await SinceWhen.openInMemory();
```
 
Contents are lost when the database is closed. Ideal for unit tests: no filesystem,
no plugins, works under `dart test`.
 
### Adding your own tables
 
Pass additional `CREATE TABLE` DDL at open. Statements run **after** the core tables,
in order, inside the same transaction — so they may reference core tables in
foreign keys.
 
```dart
final db = await SinceWhen.open(
  directory: dir.path,
  addTables: [
    '''
    CREATE TABLE IF NOT EXISTS notes (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      record_ts INTEGER NOT NULL,
      body      TEXT NOT NULL,
      FOREIGN KEY (record_ts)
        REFERENCES since_when(createdTimeStamp)
        ON DELETE CASCADE
    )
    ''',
  ],
);
```
 
Rules for `addTables` statements:
 
- Must be `CREATE TABLE` statements (anything else throws `ArgumentError`).
- Must not name a core table (`since_when`, `glossary`, `tags`) — redefinition is rejected.
- Should use `IF NOT EXISTS`, because they run on **every** open.
### Querying
 
```dart
final rows = await db.select(query: 'SELECT * FROM glossary');
for (final row in rows) {
  print(row['tagName']);
}
```
 
`select` returns `List<Map<String, Object?>>` — one map per row, keyed by column name.
 
### Closing
 
```dart
await db.close();
```
 
## Core schema
 
| Table | Purpose |
|---|---|
| `since_when` | The core records — tracking when something began or last occurred. |
| `glossary` | Tag definitions: unique `tagName` and `color`. |
| `tags` | Join table linking records to glossary entries, with `ON DELETE CASCADE`. |
 
The schema is created with `CREATE TABLE IF NOT EXISTS` on every `open()`, so opening
is idempotent and cheap. Foreign-key enforcement (`PRAGMA foreign_keys = ON`) is
applied to every connection.
 
## Platform notes
 
### iOS, Android, macOS, Linux
 
No extra setup. drift depends on version 3.x of `package:sqlite3`, which bundles the
native SQLite library automatically — `sqlite3_flutter_libs` is **not** required
(it is deprecated as of sqlite3 3.x).
 
### Web — required setup
 
Browsers can't load native SQLite, so drift runs SQLite compiled to WebAssembly.
The consuming app must place **two files** in its `web/` folder:
 
```
your_app/
  web/
    sqlite3.wasm       ← SQLite compiled to WebAssembly
    drift_worker.js    ← drift's database worker
```
 
Where to get them:
 
- **`sqlite3.wasm`** — from the
  [sqlite3.dart GitHub releases](https://github.com/simolus3/sqlite3.dart/releases).
  Use a **3.x** release to match the sqlite3 version drift depends on.
- **`drift_worker.js`** — from the
  [drift GitHub releases](https://github.com/simolus3/drift/releases),
  matching your drift version.
See drift's [web setup documentation](https://drift.simonbinder.eu/platforms/web/)
for details.
 
On web there is no filesystem: `directory` is not used, and data is stored by the
browser (OPFS or IndexedDB) under the database name `SinceWhen`.
 
#### Production server headers (recommended)
 
For the fastest storage backend (OPFS with a shared worker), serve the app with:
 
```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```
 
Without these headers drift silently falls back to IndexedDB — everything still
works, just with slower storage. `flutter run -d chrome` handles this in
development; only your production host needs configuring.
 
#### Web storage caveats
 
- Browser storage is **per-origin** and can be cleared by the user
  ("Clear site data" deletes the database).
- Browsers may evict origin storage under disk pressure; consider calling
  `navigator.storage.persist()` from your app for durability.
- In-memory mode on web lives in the worker — a page refresh wipes it
  (which is what you want in development).
## Error handling
 
`open()` fails fast — any problem surfaces at the `await`, never on a later query:
 
- Non-existent or unwritable directory → `SqliteException` (SQLite creates a missing
  *file*, never missing *directories*).
- Invalid `addTables` DDL → `ArgumentError` (before anything touches the database).
- Malformed SQL in a supplied statement → the transaction fails atomically and the
  connection is closed before the error propagates.
If you hold a `SinceWhen` instance, the connection is live and every table exists.
 
## Testing
 
Because this is a pure Dart package, tests run without Flutter:
 
```dart
import 'package:test/test.dart';
import 'package:sincewhen_framework/sincewhen_framework.dart';
 
void main() {
  test('core tables exist after open', () async {
    final db = await SinceWhen.openInMemory();
    final tables = await db.select(
      query: "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    expect(
      tables.map((r) => r['name']),
      containsAll(['since_when', 'glossary', 'tags']),
    );
    await db.close();
  });
}
```
 
```sh
dart test
```
 
