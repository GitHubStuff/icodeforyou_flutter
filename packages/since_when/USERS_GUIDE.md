# since_when — User's Guide

A lightweight content management package for Flutter. Store text records with
tags, categories, and parent-child relationships.


## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  since_when: ^0.0.1
```

Import the package:

```dart
import 'package:since_when/since_when.dart';
```


## Opening a Database

### File-based (production)

```dart
final result = await SinceWhenDatabase.openOrCreate();

result.match(
  (failure) => print('Failed: $failure'),
  (db) => print('Database ready'),
);
```

You can customize the database name and path:

```dart
final result = await SinceWhenDatabase.openOrCreate(
  dbName: 'my_app_data.sqlite',
  dbPath: '/custom/path',
);
```

### In-memory (testing)

```dart
final db = await SinceWhenDatabase.openInMemory();
```

### Closing

```dart
await db.close();
```

### Checking State

```dart
if (db.isOpen) {
  // safe to use
}
```


## Working with Tags

Tags live in a glossary. Create them first, then attach them to records.

### Create a Tag

```dart
final result = await db.createTag(
  tagName: 'flutter',
  tagDescription: 'Flutter framework topics',
  color: 0xFF2196F3,
);

result.match(
  (failure) => print('Failed: $failure'),
  (tag) => print('Created: ${tag.tagName} (${tag.createdTimeStamp})'),
);
```

### Look Up a Tag

By name:

```dart
final result = await db.getTagByName('flutter');

result.match(
  (failure) => print('Not found'),
  (tag) => print('Found: ${tag.tagName}'),
);
```

By timestamp:

```dart
final result = await db.getTagByTimestamp('2025-01-15T10:30:00.000Z');
```

### List All Tags

```dart
final result = await db.getAllTags();

result.match(
  (failure) => print('Failed: $failure'),
  (tags) {
    for (final tag in tags) {
      print('${tag.tagName}: ${tag.tagDescription}');
    }
  },
);
```

### Update a Tag

```dart
final result = await db.updateTag(
  createdTimeStamp: tag.createdTimeStamp,
  tagName: 'Flutter SDK',
  tagDescription: 'Updated description',
  color: 0xFF4CAF50,
);
```

### Delete a Tag

Deleting fails if records still use the tag:

```dart
final result = await db.deleteTag(tag.createdTimeStamp);

result.match(
  (failure) => switch (failure) {
    TagInUse(:final usageCount) =>
      print('Still used by $usageCount records'),
    _ => print('Failed: $failure'),
  },
  (deleted) => print('Tag deleted'),
);
```

Force-delete removes the tag even if records reference it:

```dart
final result = await db.deleteTag(tag.createdTimeStamp, force: true);
```


## Working with Records

### Create a Record

```dart
final result = await db.create(
  metaData: 'Shopping list for weekend',
  dataString: 'Eggs, milk, bread, butter',
  category: 'grocery',
  tagTimestamps: [flutterTag.createdTimeStamp],
);

result.match(
  (failure) => print('Failed: $failure'),
  (record) => print('Created: ${record.createdTimeStamp}'),
);
```

### Create a Child Record

Pass the parent's `createdTimeStamp` to create a hierarchy:

```dart
final child = await db.create(
  metaData: 'Sub-item',
  dataString: 'Organic eggs, 12-pack',
  category: 'grocery',
  tagTimestamps: [],
  parentTimeStamp: parentRecord.createdTimeStamp,
);
```

### Query Records by Tag

By tag name (single):

```dart
final result = await db.getByTagName('flutter');

result.match(
  (failure) => print('Failed: $failure'),
  (records) {
    for (final r in records) {
      print('${r.metaData}: ${r.dataString}');
    }
  },
);
```

By tag timestamp (single):

```dart
final result = await db.getByTagTimestamp(tag.createdTimeStamp);
```

### Query Records by Multiple Tags

Records with **any** of the tags (OR):

```dart
final result = await db.getByTagNames(
  ['flutter', 'dart'],
  mode: TagMatchMode.any,
);
```

Records with **all** of the tags (AND):

```dart
final result = await db.getByTagNames(
  ['flutter', 'dart'],
  mode: TagMatchMode.all,
);
```

You can also query by timestamp list:

```dart
final result = await db.getByTagTimestamps(
  [tag1.createdTimeStamp, tag2.createdTimeStamp],
  mode: TagMatchMode.all,
);
```

### Manage Tags on a Record

Add a tag to an existing record:

```dart
final result = await db.addTagToRecord(
  record.createdTimeStamp,
  tag.createdTimeStamp,
);
```

Remove a tag from a record:

```dart
final result = await db.removeTagFromRecord(
  record.createdTimeStamp,
  tag.createdTimeStamp,
);
```

### Reading the Record Object

A `SinceWhenRecord` has these fields:

```dart
record.createdTimeStamp   // String — unique ID (ISO8601 UTC)
record.metaData           // String — short summary (~100 chars)
record.dataString         // String — primary content (unlimited)
record.category           // String — free-form classification
record.tags               // List<TagDefinition> — attached tags
record.parentTimeStamp    // String? — parent record ID, if any
record.reviewedTimeStamp  // String — last review time
record.editedTimeStamp    // String — last edit time
record.sequenceNumber     // int — ordering among siblings
record.metaTimeStamp      // String? — optional metadata timestamp
```

A `TagDefinition` has these fields:

```dart
tag.createdTimeStamp   // String — unique ID
tag.tagName            // String — display name (unique)
tag.tagDescription     // String — description
tag.color              // int — ARGB color value
```

Convert to a Flutter `Color`:

```dart
final color = Color(tag.color);
```


## Handling Errors

Every operation returns `Either<DataStoreFailure, T>`. Use `match` to
handle both cases:

```dart
final result = await db.create(
  metaData: 'My note',
  dataString: 'Content here',
  category: 'notes',
  tagTimestamps: [],
);

result.match(
  (failure) => switch (failure) {
    StoreNotReady()      => print('Database not open'),
    IdentifierCollision() => print('ID collision, try again'),
    ParentNotFound()     => print('Parent record does not exist'),
    _                    => print('Error: $failure'),
  },
  (record) => print('Success: ${record.createdTimeStamp}'),
);
```

### Failure Types

| Failure | When It Happens |
|---------|----------------|
| `StoreNotReady` | Database not opened or already closed |
| `RecordNotFound` | Queried record does not exist |
| `ParentNotFound` | Specified parent record does not exist |
| `IdentifierCollision` | Unique ID could not be generated |
| `TagNotFound` | Queried tag does not exist |
| `TagNameAlreadyExists` | Tag name is taken |
| `InvalidTagName` | Tag name is empty or whitespace |
| `TagInUse` | Tag can't be deleted — records still use it |
| `UnexpectedStoreError` | Catch-all for unexpected errors |


## Using with flutter_bloc

A typical pattern with a Cubit:

```dart
class NoteCubit extends Cubit<NoteState> {
  NoteCubit({required SinceWhenRecordStore store})
    : _store = store,
      super(const NoteState.initial());

  final SinceWhenRecordStore _store;

  Future<void> loadByTag(String tagName) async {
    emit(const NoteState.loading());

    final result = await _store.getByTagName(tagName);

    result.match(
      (failure) => emit(NoteState.error(failure.toString())),
      (records) => emit(NoteState.loaded(records)),
    );
  }

  Future<void> createNote(String title, String content) async {
    final result = await _store.create(
      metaData: title,
      dataString: content,
      category: 'notes',
      tagTimestamps: [],
    );

    result.match(
      (failure) => emit(NoteState.error(failure.toString())),
      (record) => loadByTag('notes'),
    );
  }
}
```

Wiring it up:

```dart
final db = await SinceWhenDatabase.openInMemory();

BlocProvider(
  create: (_) => NoteCubit(store: db),
  child: const MyApp(),
);
```


## Complete Example

```dart
import 'package:since_when/since_when.dart';

Future<void> main() async {
  // Open database
  final dbResult = await SinceWhenDatabase.openOrCreate();
  final db = dbResult.getOrElse(
    () => throw Exception('Failed to open database'),
  );

  // Create tags
  final flutterTag = (await db.createTag(
    tagName: 'flutter',
    tagDescription: 'Flutter framework',
    color: 0xFF2196F3,
  )).getOrElse(() => throw Exception('Tag creation failed'));

  final dartTag = (await db.createTag(
    tagName: 'dart',
    tagDescription: 'Dart language',
    color: 0xFF00BCD4,
  )).getOrElse(() => throw Exception('Tag creation failed'));

  // Create a parent record with both tags
  final parent = (await db.create(
    metaData: 'Widget tutorial',
    dataString: 'Learn to build custom widgets in Flutter...',
    category: 'tutorial',
    tagTimestamps: [
      flutterTag.createdTimeStamp,
      dartTag.createdTimeStamp,
    ],
  )).getOrElse(() => throw Exception('Record creation failed'));

  // Create a child record
  await db.create(
    metaData: 'Step 1: StatelessWidget',
    dataString: 'Start with a simple StatelessWidget...',
    category: 'tutorial',
    tagTimestamps: [flutterTag.createdTimeStamp],
    parentTimeStamp: parent.createdTimeStamp,
  );

  // Query: find all records tagged 'flutter'
  final flutterRecords = await db.getByTagName('flutter');
  flutterRecords.match(
    (failure) => print('Query failed: $failure'),
    (records) {
      print('Found ${records.length} flutter records:');
      for (final r in records) {
        print('  - ${r.metaData}');
        print('    Tags: ${r.tags.map((t) => t.tagName).join(', ')}');
      }
    },
  );

  // Query: records with BOTH 'flutter' AND 'dart'
  final bothTags = await db.getByTagNames(
    ['flutter', 'dart'],
    mode: TagMatchMode.all,
  );
  bothTags.match(
    (failure) => print('Query failed: $failure'),
    (records) => print('Records with both tags: ${records.length}'),
  );

  // Update a tag
  await db.updateTag(
    createdTimeStamp: flutterTag.createdTimeStamp,
    tagName: 'Flutter SDK',
    tagDescription: 'Flutter SDK and framework',
    color: 0xFF4CAF50,
  );

  // List all tags
  final allTags = await db.getAllTags();
  allTags.match(
    (failure) => print('Failed: $failure'),
    (tags) {
      print('All tags:');
      for (final t in tags) {
        print('  - ${t.tagName}: ${t.tagDescription}');
      }
    },
  );

  // Clean up
  await db.close();
}
```


## Not Yet Implemented

The following methods exist in the API but are not yet available in the
SQLite backend. Calling them throws `UnimplementedError`:

| Method | Description |
|--------|------------|
| `getByCreatedTimeStamp()` | Get record with children by ID |
| `getByCategory()` | Get all records in a category |
| `update()` | Update an existing record |
| `markReviewed()` | Set reviewed timestamp |
| `delete()` | Delete a single record |
| `deleteWithDescendants()` | Delete record and all children |
| `exportToString()` | Export database to JSON string |
| `exportToFile()` | Export database to file |
| `importFromString()` | Import from JSON string |
| `importFromFile()` | Import from file |
