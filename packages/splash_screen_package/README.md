# Splash Screen Package

A Flutter package for managing splash screens with animations, error handling, and async initialization support following SOLID principles and Clean Code practices.

## Features

- 🎨 Customizable fade-in animation for splash screen content
- ⏱️ Built-in timeout handling with configurable duration
- ❌ Comprehensive error handling with custom error widgets
- 🔄 Loading spinner display while waiting for async operations
- 🎯 Clean separation of concerns using BLoC pattern
- ✅ 100% test coverage
- 🚀 Simple API with maximum flexibility

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  splash_screen_package: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Initialize the Cubit

In your `main()` function, initialize the `SplashScreenCubit` before running your app:

```dart
void main() {
  // Initialize splash screen cubit with timeout duration
  SplashScreenCubit.initialize(
    const Duration(seconds: 10),
  );
  
  // Start your async initialization tasks
  _initializeApp();
  
  runApp(const MyApp());
}
```

### 2. Create Your Splash Screen

Use `AppSplashScreen` as your initial screen:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppSplashScreen(
        animationWidget: const FlutterLogo(size: 200),
        animationDuration: const Duration(seconds: 2),
        newRootWidget: const HomePage(),
        errorWidgetBuilder: (error) => ErrorScreen(
          errorMessage: error.errorMessage,
          errorDetails: error.errorDetails,
        ),
        timeoutDuration: const Duration(seconds: 10),
        spinnerWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Signal Completion or Errors

From your async initialization code, signal when ready or report errors:

```dart
Future<void> _initializeApp() async {
  try {
    // Perform your initialization tasks
    await _loadConfiguration();
    await _connectToServices();
    await _preloadData();
    
    // Signal successful completion
    SplashScreenCubit.instance.dismiss();
  } catch (e) {
    // Report any errors
    SplashScreenCubit.instance.reportError(
      LoadingError(
        'Failed to initialize app',
        {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }
}
```

### 4. Create Custom Error Widget

Create your own error widget that accepts error data:

```dart
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final Map<String, dynamic>? errorDetails;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'ERROR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              if (errorDetails != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Details: ${errorDetails.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## API Reference

### SplashScreenCubit

#### Methods

- `static void initialize(Duration timeout)` - Initialize the cubit with timeout duration. Must be called in `main()` before `runApp()`.
- `static SplashScreenCubit get instance` - Get the singleton instance.
- `void dismiss()` - Signal that initialization is complete and app should proceed.
- `void reportError(LoadingError error)` - Report an error that occurred during initialization.

### LoadingError

A class representing initialization errors.

```dart
class LoadingError {
  final String errorMessage;
  final Map<String, dynamic>? errorDetails;
  
  const LoadingError(this.errorMessage, [this.errorDetails]);
}
```

### AppSplashScreen

#### Required Parameters

- `Widget animationWidget` - The widget to fade in during splash screen
- `Duration animationDuration` - How long the fade-in animation takes
- `Widget newRootWidget` - The main app widget after successful initialization
- `Widget Function(LoadingError) errorWidgetBuilder` - Builder for error widgets
- `Duration timeoutDuration` - Maximum wait time after animation completes
- `Widget spinnerWidget` - Widget to show while waiting for dismiss signal

#### Optional Parameters

- `Color barrierColor` - Color overlay between splash and spinner (default: Color(0x66FF9800))
- `Curve fadeInCurve` - Animation curve for fade-in (default: `Curves.easeInOut`)

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0

## Dependencies

- `flutter_bloc: ^9.1.1` - State management
- `equatable: ^2.0.5` - Value equality

## License

MIT License - see LICENSE file for details.
