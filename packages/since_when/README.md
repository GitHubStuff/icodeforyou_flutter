# since_when

A lightweight content management package for Flutter. Store, tag, and organize
text records with parent-child relationships and category filtering — backed by
SQLite out of the box.

## Features

- **Records** — create, read, update, and delete text content with metadata
- **Tags** — define a tag glossary and attach tags to records
- **Hierarchies** — nest records under parent records
- **Multi-tag queries** — find records matching any or all of a tag set
- **Structured errors** — every operation returns `Either<DataStoreFailure, T>`
- **Pluggable backends** — implement the store interfaces to swap SQLite for
  Firebase, Hive, or anything else

## Install

```yaml
dependencies:
  since_when: ^0.0.1
```

```dart
import 'package:since_when/since_when.dart';
```

## Quick Start

```dart
// Open the database
final result = await SinceWhenDatabase.openOrCreate();
final db = result.getOrElse(() => throw Exception('Failed'));

// Create a tag
final tag = (await db.createTag(
  tagName: 'flutter',
  tagDescription: 'Flutter framework',
  color: 0xFF2196F3,
)).getOrElse(() => throw Exception('Tag failed'));

// Create a record with the tag
final record = (await db.create(
  metaData: 'My first note',
  dataString: 'This is the content of the note.',
  category: 'notes',
  tagTimestamps: [tag.createdTimeStamp],
)).getOrElse(() => throw Exception('Record failed'));

// Query records by tag
final records = await db.getByTagName('flutter');
records.match(
  (failure) => print('Error: $failure'),
  (list) => print('Found ${list.length} records'),
);

// Clean up
await db.close();
```

## Error Handling

All operations return `Either<DataStoreFailure, T>` from the
[fpdart](https://pub.dev/packages/fpdart) package. Use `match` for
exhaustive handling:

```dart
result.match(
  (failure) => switch (failure) {
    StoreNotReady()       => showError('Database not open'),
    TagNameAlreadyExists() => showError('Tag name taken'),
    TagInUse(:final usageCount) =>
      showError('Used by $usageCount records'),
    _                     => showError('$failure'),
  },
  (value) => handleSuccess(value),
);
```

## Testing

Use the in-memory database for tests — no file system required, no shared
state between tests:

```dart
late SinceWhenDatabase db;

setUp(() async {
  db = await SinceWhenDatabase.openInMemory();
});

tearDown(() async {
  await db.close();
});

test('creates a record', () async {
  final result = await db.create(
    metaData: 'Test',
    dataString: 'Content',
    category: 'test',
    tagTimestamps: [],
  );
  expect(result.isRight(), isTrue);
});
```

## Custom Backends

The package defines four interfaces. Implement them to plug in your own
storage:

| Interface | Purpose |
|-----------|---------|
| `SinceWhenRecordStore` | Record CRUD |
| `SinceWhenTagStore` | Tag glossary and record-tag linking |
| `SinceWhenDataTransferStore` | Export and import |
| `SinceWhenDataStore` | All three combined with lifecycle |

```dart
class MyFirebaseStore implements SinceWhenDataStore {
  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> close() async { /* ... */ }

  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> create({ /* ... */ }) async {
    // Your Firebase implementation
  }

  // ... implement remaining methods
}
```

Consumers depend on the interface, not the implementation:

```dart
class NoteCubit extends Cubit<NoteState> {
  NoteCubit({required SinceWhenRecordStore store}) : _store = store;
  final SinceWhenRecordStore _store;
}
```

## Documentation

See [USERS_GUIDE.md](USERS_GUIDE.md) for the complete usage guide with
detailed examples covering tags, records, hierarchies, multi-tag queries,
error handling, and flutter_bloc integration.

## License

See [LICENSE](LICENSE) for details.
