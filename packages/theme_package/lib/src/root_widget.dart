// lib/src/root_widget.dart
part of '../theme_package.dart';

/// Root widget that initializes theme management and provides splash screen.
///
/// Wrap your app with this widget to enable theme persistence and management.
/// You retain full control of your [MaterialApp] configuration.
///
/// The splash screen displays until both conditions are met:
/// - Hive database is initialized and theme is loaded
/// - [splashMinDuration] has elapsed (if provided)
///
/// The transition from splash to app uses a cross-fade animation.
///
/// ## Example
/// ```dart
/// void main() {
///   runApp(
///     ThemePackageRoot(
///       databaseName: 'abc123def456ghi78901',
///       splash: MySplashWidget(),
///       child: MyApp(),
///     ),
///   );
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ThemeBuilder(
///       builder: (context, themeMode) {
///         return MaterialApp(
///           theme: myLightTheme,
///           darkTheme: myDarkTheme,
///           themeMode: themeMode,
///           home: HomePage(),
///         );
///       },
///     );
///   }
/// }
/// ```
class ThemePackageRoot extends StatefulWidget {
  const ThemePackageRoot({
    super.key,
    this.databaseName,
    required this.splash,
    required this.child,
    this.splashMinDuration,
    this.transitionDuration = const Duration(milliseconds: 750),
    this.customPath,
    this.inMemory = false,
    this.onInitializationError,
  });

  /// Unique database name. Must be exactly 20 valid filename characters.
  /// Valid characters: a-z, A-Z, 0-9, underscore, hyphen.
  ///
  /// Required if [ThemePackage.initialize] has not been called.
  /// Ignored if already initialized.
  final String? databaseName;

  /// Widget to display during initialization.
  /// Displayed with a dark background to prevent light flash.
  final Widget splash;

  /// The app widget to display after initialization.
  /// Typically contains your [MaterialApp] wrapped with [ThemeBuilder].
  final Widget child;

  /// Minimum duration to display the splash screen.
  /// Splash persists until this duration AND initialization are complete.
  final Duration? splashMinDuration;

  /// Duration of the cross-fade transition from splash to app.
  /// Defaults to 750 milliseconds.
  final Duration transitionDuration;

  /// Optional custom base path. If provided, bypasses path_provider.
  /// Useful for platforms where path_provider is unavailable.
  final String? customPath;

  /// If true, uses in-memory storage instead of Hive.
  /// Useful for testing, Widgetbook, or environments without file system access.
  /// Defaults to false.
  final bool inMemory;

  /// Callback for initialization errors.
  /// If not provided, errors are silently ignored and system theme is used.
  final void Function(ThemeError error)? onInitializationError;

  @override
  State<ThemePackageRoot> createState() => _ThemePackageRootState();
}

class _ThemePackageRootState extends State<ThemePackageRoot> {
  bool _initialized = false;
  bool _minDurationElapsed = false;

  bool get _showApp =>
      _initialized && _minDurationElapsed && ThemePackage.isInitialized;

  @override
  void initState() {
    super.initState();
    _validateConfiguration();
    _startInitialization();
    _startMinDurationTimer();
  }

  void _validateConfiguration() {
    if (!ThemePackage.isInitialized && widget.databaseName == null) {
      throw StateError(
        'ThemePackageRoot requires databaseName when '
        'ThemePackage.initialize() has not been called.',
      );
    }
  }

  Future<void> _startInitialization() async {
    if (!ThemePackage.isInitialized) {
      final result = await ThemePackage.initialize(
        databaseName: widget.databaseName!,
        customPath: widget.customPath,
        inMemory: widget.inMemory,
      );

      result.match(
        (error) => widget.onInitializationError?.call(error),
        (_) {},
      );
    }

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _startMinDurationTimer() {
    final minDuration = widget.splashMinDuration;

    if (minDuration == null) {
      _minDurationElapsed = true;
      return;
    }

    Future<void>.delayed(minDuration, () {
      if (mounted) {
        setState(() {
          _minDurationElapsed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSwitcher(
        duration: widget.transitionDuration,
        child: _showApp ? _buildApp() : _buildSplash(),
      ),
    );
  }

  Widget _buildSplash() {
    return Container(
      key: const ValueKey('splash'),
      color: Colors.black,
      child: widget.splash,
    );
  }

  Widget _buildApp() {
    return BlocProvider<_ThemeCubit>.value(
      key: const ValueKey('app'),
      value: ThemePackage._cubit!,
      child: widget.child,
    );
  }
}
