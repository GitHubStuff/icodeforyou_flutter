// packages/rail_navigation/example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:rail_navigation/src/widgets/rail_button_database.dart';
import 'package:rail_navigation/src/widgets/rail_button_main.dart';
import 'package:rail_navigation/src/widgets/rail_button_more.dart';
import 'package:rail_navigation/src/widgets/rail_button_settings.dart';
import 'package:rail_navigation/src/widgets/rail_widget.dart';

/// The seed color for the demo theme.
const Color _kSeedColor = Colors.teal;

/// The labels shown in the body for each destination index.
const List<String> _kScreenLabels = <String>['Main', 'Database', 'Settings'];

void main() {
  runApp(const RailDemoApp());
}

/// A dirt-dumb showcase of [RailWidget].
///
/// Holds the three pieces of state the parent owns — the selected
/// destination index, the theme mode, and where the rail is placed —
/// with plain [setState]. In a real app the first two live in a Cubit
/// and placement is a breakpoint decision; the demo's only job is to
/// show the wiring.
class RailDemoApp extends StatefulWidget {
  /// Creates a [RailDemoApp].
  const RailDemoApp({super.key});

  @override
  State<RailDemoApp> createState() => _RailDemoAppState();
}

class _RailDemoAppState extends State<RailDemoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Axis _railDirection = Axis.horizontal;
  int _selectedIndex = 0;

  bool get _isDark => _themeMode == ThemeMode.dark;

  bool get _isBottom => _railDirection == Axis.horizontal;

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _toggleRailPlacement() {
    setState(() {
      _railDirection = _isBottom ? Axis.vertical : Axis.horizontal;
    });
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showMore(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Overflow destinations would appear here.')),
    );
  }

  List<Widget> _railChildren(BuildContext context) {
    return [
      MainRailButton(
        isSelected: _selectedIndex == 0,
        onPressed: () => _select(0),
      ),
      DatabaseRailButton(
        isSelected: _selectedIndex == 1,
        onPressed: () => _select(1),
      ),
      SettingsRailButton(
        isSelected: _selectedIndex == 2,
        onPressed: () => _select(2),
      ),
      MoreRailButton(onPressed: () => _showMore(context)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RailWidget Demo',
      theme: ThemeData(colorSchemeSeed: _kSeedColor),
      darkTheme: ThemeData(
        colorSchemeSeed: _kSeedColor,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: Builder(
        builder: (context) {
          final body = Center(
            child: Text(
              '${_kScreenLabels[_selectedIndex]} screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );

          return Scaffold(
            appBar: AppBar(
              title: const Text('RailWidget Demo'),
              actions: [
                IconButton(
                  onPressed: _toggleRailPlacement,
                  icon: Icon(
                    _isBottom ? Icons.view_sidebar : Icons.call_to_action,
                  ),
                  tooltip: _isBottom
                      ? 'Move rail to the side'
                      : 'Move rail to the bottom',
                ),
                IconButton(
                  onPressed: _toggleTheme,
                  icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: _isDark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                ),
              ],
            ),
            body: _isBottom
                ? body
                : Row(
                    children: [
                      RailWidget(
                        direction: Axis.vertical,
                        children: _railChildren(context),
                      ),
                      Expanded(child: body),
                    ],
                  ),
            bottomNavigationBar: _isBottom
                ? RailWidget(children: _railChildren(context))
                : null,
          );
        },
      ),
    );
  }
}
