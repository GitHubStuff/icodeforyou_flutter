// plugins/status_bar_android/lib/status_bar_android.dart
// Version: 0.0.1-a StatusBarAndroid

/// Instant show/hide of the Android status bar.
///
/// Standalone, Android-only plugin (not a federated implementation).
/// Requires Android 11 (API 30) or later.
library;

export 'src/status_bar.dart' show StatusBar;

export 'src/status_bar_android_platform_interface.dart'
    show StatusBarAndroidPlatform;
