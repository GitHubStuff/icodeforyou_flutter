# Theme Package

A Flutter package for persistent theme management with Hive storage, BLoC state management, and built-in splash screen support.

## Features

- **Persistent Theme Storage** — Saves user theme preference to local storage using Hive CE
- **BLoC State Management** — Reactive theme updates via flutter_bloc/Cubit
- **Splash Screen Support** — Built-in animated transition from splash to app
- **Functional Error Handling** — Uses `Either` from dartz for type-safe error handling
- **In-Memory Mode** — Testing and Widgetbook support without file system access
- **Clean Architecture** — Separation of concerns with datasource, cubit, and widget layers

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  theme_package:
    path: packages/theme_package  # adjust path as needed
```

### Dependencies

This package requires:
- `flutter_bloc` — State management
- `hive_ce_flutter` — Local persistence
- `path_provider` — File system access

## Usage

### Option A: Use ThemePackageRoot (Recommended)

The simplest approach—wrap your app and let the package handle initialization:

```dart
void main() {
  runApp(
    ThemePackageRoot(
      databaseName: 'abc123def456ghi78901',  // exactly 20 chars
      splash: MySplashWidget(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, themeMode) {
        return MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: themeMode,
          home: HomePage(),
        );
      },
    );
  }
}
```

### Option B: Manual Initialization

For early access to theme state before widget tree builds:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final result = await ThemePackage.initialize(
    databaseName: 'abc123def456ghi78901',
  );
  
  result.fold(
    (error) => debugPrint('Theme init failed: $error'),
    (_) => debugPrint('Theme initialized'),
  );
  
  runApp(
    ThemePackageRoot(
      splash: MySplashWidget(),
      child: MyApp(),
    ),
  );
}
```

### Option C: In-Memory Mode (Testing / Widgetbook)

For environments without file system access:

```dart
await ThemePackage.initialize(
  databaseName: 'test_db_12345678901',
  inMemory: true,
);
```

## Widgets

### ThemePackageRoot

Root widget that initializes theme management and provides splash screen.

```dart
ThemePackageRoot(
  databaseName: 'abc123def456ghi78901',  // Required if not pre-initialized
  splash: MySplashWidget(),               // Displays during init
  child: MyApp(),                         // Your app
  splashMinDuration: Duration(seconds: 2), // Optional minimum splash time
  transitionDuration: Duration(milliseconds: 750), // Cross-fade duration
  inMemory: false,                        // Use in-memory storage
  onInitializationError: (error) {},      // Error callback
)
```

### ThemeBuilder

Reactive builder that provides current `ThemeMode`:

```dart
ThemeBuilder(
  builder: (context, themeMode) {
    return MaterialApp(
      themeMode: themeMode,
      // ...
    );
  },
)
```

### ThemeSelectorWidget

Pre-built radio button group for theme selection:

```dart
Scaffold(
  body: Column(
    children: [
      // Other settings...
      ThemeSelectorWidget(),  // System / Dark / Light options
    ],
  ),
)
```

## Static API

Access theme state and operations via the `ThemePackage` class:

| Method | Description |
|--------|-------------|
| `ThemePackage.initialize(...)` | Initialize the package. Returns `Either<ThemeError, Unit>`. |
| `ThemePackage.isInitialized` | Check if package is initialized. |
| `ThemePackage.currentTheme` | Get current `ThemeMode`. Throws if not initialized. |
| `ThemePackage.getTheme()` | Get persisted `ThemeMode` from storage. |
| `ThemePackage.setTheme(mode)` | Set and persist theme. Returns `Either<ThemeError, Unit>`. |

### Setting Theme Programmatically

```dart
// Set theme from anywhere
final result = await ThemePackage.setTheme(ThemeMode.dark);

result.fold(
  (error) => showSnackBar('Failed to save theme'),
  (_) => debugPrint('Theme saved'),
);
```

## Error Handling

The package uses sealed classes for type-safe error handling:

```dart
sealed class ThemeError {
  ThemeError.initializationFailed(String message)  // Hive init failed
  ThemeError.persistenceFailed(String message)     // Save to storage failed
}
```

Handle errors with pattern matching:

```dart
final result = await ThemePackage.setTheme(ThemeMode.dark);

result.fold(
  (error) {
    switch (error) {
      case _InitializationFailed(:final message):
        debugPrint('Init failed: $message');
      case _PersistenceFailed(:final message):
        debugPrint('Save failed: $message');
    }
  },
  (_) => debugPrint('Success'),
);
```

## Database Name Requirements

The `databaseName` parameter must be:
- Exactly **20 characters**
- Valid filename characters only: `a-z`, `A-Z`, `0-9`, `_`, `-`

```dart
// Valid
'abc123def456ghi78901'
'my_app_theme_db_0001'

// Invalid
'short'                    // Too short
'this_name_is_way_too_long' // Too long
'invalid/chars!'           // Invalid characters
```

## Testing

The package provides testing utilities:

```dart
setUp(() {
  ThemePackage.reset();  // Reset state between tests
});

test('handles initialization failure', () async {
  ThemePackage.testDatasourceInitializer = () async {
    return Left(ThemeError.initializationFailed('Test error'));
  };
  
  final result = await ThemePackage.initialize(
    databaseName: 'test_db_12345678901',
  );
  
  expect(result.isLeft(), true);
});

test('handles setTheme failure', () async {
  await ThemePackage.initialize(
    databaseName: 'test_db_12345678901',
    inMemory: true,
  );
  
  ThemePackage.forceSetThemeFailure = true;
  
  final result = await ThemePackage.setTheme(ThemeMode.dark);
  
  expect(result.isLeft(), true);
});
```

## Requirements

- Flutter SDK
- Dart SDK >=3.10.0 <4.0.0

## License

See LICENSE file for details.
