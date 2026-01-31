// lib/src/builder_widget.dart
part of '../theme_package.dart';

/// A convenience widget for building UI based on theme state.
///
/// Wraps [BlocBuilder] to provide the current [ThemeMode] without
/// exposing internal cubit/state classes.
///
/// ## Example
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return ThemeBuilder(
///       builder: (context, themeMode) {
///         return MaterialApp(
///           theme: ThemeData.light(useMaterial3: true),
///           darkTheme: ThemeData.dark(useMaterial3: true),
///           themeMode: themeMode,
///           home: HomePage(),
///         );
///       },
///     );
///   }
/// }
/// ```
class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder({
    super.key,
    required this.builder,
  });

  /// Builder function that receives the current [ThemeMode].
  final Widget Function(BuildContext context, ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_ThemeCubit, _ThemeState>(
      builder: (context, state) {
        return builder(context, state.themeMode);
      },
    );
  }
}
