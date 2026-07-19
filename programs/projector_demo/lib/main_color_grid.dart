// packages/grid_picker/example/lib/main.dart
import 'dart:math' show Random;

import 'package:color_grid/color_grid.dart' show ColorGrid;
import 'package:flutter/material.dart';

const int _kColorCount = 15;

void main() => runApp(const GridPickerExampleApp());

/// Minimal demo app for [GridPicker] with a light/dark theme toggle.
class GridPickerExampleApp extends StatefulWidget {
  /// Creates the example app.
  const GridPickerExampleApp({super.key});

  @override
  State<GridPickerExampleApp> createState() => _GridPickerExampleAppState();
}

class _GridPickerExampleAppState extends State<GridPickerExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() => setState(
    () => _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GridPicker Example',
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    themeMode: _themeMode,
    home: _GridPickerExamplePage(
      themeMode: _themeMode,
      onToggleTheme: _toggleTheme,
    ),
  );
}

class _GridPickerExamplePage extends StatefulWidget {
  const _GridPickerExamplePage({
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<_GridPickerExamplePage> createState() => _GridPickerExamplePageState();
}

class _GridPickerExamplePageState extends State<_GridPickerExamplePage> {
  final Random _random = Random();
  late List<int> _colors = _nextBatch();

  List<int> _nextBatch() => List<int>.generate(
    _kColorCount,
    (_) => 0xFF000000 | _random.nextInt(0x01000000),
  );

  void _onRefreshRequested() => setState(() => _colors = _nextBatch());

  void _onColorTapped(int index, int colorValue) {
    final hex = colorValue.toRadixString(16).toUpperCase().padLeft(8, '0');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Tapped $index: 0x$hex')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('GridPicker'),
      actions: [
        IconButton(
          tooltip: widget.themeMode == ThemeMode.light
              ? 'Switch to dark mode'
              : 'Switch to light mode',
          icon: Icon(
            widget.themeMode == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: widget.onToggleTheme,
        ),
      ],
    ),
    body: Center(
      child: ColorGrid(
        colors: _colors,
        onColorTapped: _onColorTapped,
        onRefreshRequested: _onRefreshRequested,
      ),
    ),
  );
}
