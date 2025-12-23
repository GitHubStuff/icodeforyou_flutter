# NoSQL

A NoSQL database abstraction layer for Flutter with Hive CE backend.

## Features

- Abstract interfaces for database and box operations
- Hive CE (Community Edition) implementation
- Cross-platform support (mobile, desktop, web)
- Type-safe generic box operations
- Simple key-value storage API
- Testable with dependency injection for platform detection

## Installation

```yaml
dependencies:
  nosql: ^1.0.0
  hive_ce_flutter: ^2.0.0
  path_provider: ^2.0.0
  path: ^1.8.0
```

## Usage

### Initialize Database

```dart
import 'package:nosql/nosql.dart';

final db = NoSqlCEdb();

// Initialize with default directory
await db.init();

// Or specify custom directory name
await db.init(dirName: 'my_app_data');
```

### Open a Box

```dart
// Open a typed box
final box = await db.openBox<String>('settings');

// Store a value
await box?.put('theme', 'dark');

// Retrieve a value
final theme = box?.get('theme');
print(theme); // 'dark'

// Retrieve with default value
final language = box?.get('language', defaultValue: 'en');
```

### Close Resources

```dart
// Close a specific box
await box?.close();

// Close all boxes and the database
await db.close();
```

### Delete Database

```dart
// Delete all data from device
final success = await db.deleteFromDevice();
```

## API

### NoSqlDBAbstract

Abstract interface for database operations.

| Method | Return | Description |
|--------|--------|-------------|
| `init({dirName})` | `FutureOr<void>` | Initialize database with optional directory name |
| `close()` | `FutureOr<void>` | Close all boxes and database |
| `deleteFromDevice()` | `FutureOr<bool>` | Delete all data, returns success status |
| `openBox<T>(boxName)` | `FutureOr<NoSqlBoxAbstract<T>?>` | Open a typed box |

### NoSqlBoxAbstract\<T\>

Abstract interface for box (collection) operations.

| Method | Return | Description |
|--------|--------|-------------|
| `put(key, value)` | `FutureOr<bool>` | Store value, returns success status |
| `get(key, {defaultValue})` | `FutureOr<T?>` | Retrieve value or default |
| `close()` | `FutureOr<void>` | Close the box |

### NoSqlCEdb

Hive CE implementation of `NoSqlDBAbstract`.

```dart
// Default usage
final db = NoSqlCEdb();

// With custom platform checker (for testing)
final db = NoSqlCEdb(MockPlatformChecker());
```

### NoSqlCEBox\<T\>

Hive CE implementation of `NoSqlBoxAbstract<T>`.

## Platform Behavior

| Platform | Storage Location |
|----------|-----------------|
| iOS/Android | Application documents directory |
| macOS/Windows/Linux | Application documents directory |
| Web | IndexedDB (via Hive Flutter) |

## Testing

Inject a mock platform checker for testing:

```dart
class MockPlatformChecker implements PlatformChecker {
  @override
  bool get isWeb => false;
}

final db = NoSqlCEdb(MockPlatformChecker());
```

Reset static state between tests:

```dart
import 'package:nosql/nosql_ce/nosql_ce_db.dart';

tearDown(() {
  resetForTesting();
});
```

## Architecture

```
lib/
├── nosql.dart                    # Main barrel file
├── src/
│   └── nosql.dart                # Internal barrel
├── abstract/
│   ├── abstract.dart             # Abstract barrel
│   ├── nosql_db_abstract.dart    # Database interface
│   └── nosql_box_abstract.dart   # Box interface
└── nosql_ce/
    ├── nosql_ce.dart             # CE barrel
    ├── nosql_ce_db.dart          # Hive CE database implementation
    └── nosql_ce_box.dart         # Hive CE box implementation
```

### Design Principles

- **Dependency Inversion**: Code depends on abstractions, not Hive directly
- **Single Responsibility**: Separate classes for database and box operations
- **Testability**: Platform detection is injectable

## Extending

Implement custom backends by extending the abstract classes:

```dart
class MyCustomDB implements NoSqlDBAbstract {
  @override
  FutureOr<void> init({String dirName = 'nosqldb'}) {
    // Custom initialization
  }
  
  @override
  FutureOr<NoSqlBoxAbstract<T>?> openBox<T>(String boxName) {
    // Return custom box implementation
  }
  
  // ... other methods
}
```

## License

See LICENSE file.
