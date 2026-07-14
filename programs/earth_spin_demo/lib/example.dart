// example/main.dart

import 'package:data_grid/data_grid.dart';
import 'package:flutter/material.dart';

/// Name pool for generated sample rows.
const List<String> _kFirstNames = <String>[
  'Ada',
  'grace',
  'Linus',
  'margaret',
  'Dennis',
  'Barbara',
  'ken',
  'Radia',
];

/// City pool for generated sample rows.
const List<String> _kCities = <String>[
  'Toronto',
  'Chicago',
  'Auckland',
  'Berlin',
  'Osaka',
  'Reykjavik',
];

/// A deliberately long note to demonstrate single-line ellipsis and the
/// tap-to-inspect cell dialog.
const String _kLongNote =
    'This note is intentionally far too long to fit in its column so the '
    'cell ellipsizes and tapping it opens the full-content dialog.';

/// Forty sample rows, ten columns wide — wider than a phone screen in
/// both portrait and landscape. Mixed types, mixed string casing, and
/// periodic nulls exercise sorting, dim-null rendering, and the dialog.
final List<Map<String, Object?>> _sampleRows =
    List<Map<String, Object?>>.generate(40, (int i) {
      return <String, Object?>{
        'id': i + 1,
        'first_name': _kFirstNames[i % _kFirstNames.length],
        'last_name': 'Person-${(97 - i) % 40}',
        'email': 'user$i@example.com',
        'city': _kCities[i % _kCities.length],
        'country_code': i % 4 == 0 ? null : 'C${(i * 7) % 90 + 10}',
        'balance': ((i * 137.5) % 5000) - 500,
        'active': i.isEven,
        'last_login': i % 7 == 0 ? null : '2026-0${(i % 9) + 1}-1${i % 10}',
        'notes': i % 5 == 0 ? _kLongNote : 'ok',
      };
    });

void main() {
  runApp(const DataGridDemoApp());
}

/// Demo application for the [DataGrid] widget. Owns the light/dark
/// theme state so the screen's toggle button can flip it.
class DataGridDemoApp extends StatefulWidget {
  /// Creates the demo app.
  const DataGridDemoApp({super.key});

  @override
  State<DataGridDemoApp> createState() => _DataGridDemoAppState();
}

class _DataGridDemoAppState extends State<DataGridDemoApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataGrid Demo',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: DataGridDemoScreen(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// Demo screen hosting a [DataGrid], a row-tap reaction, and a theme
/// toggle button below the grid.
class DataGridDemoScreen extends StatelessWidget {
  /// Creates the demo screen.
  const DataGridDemoScreen({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  /// Whether the app is currently in dark mode. Drives the toggle
  /// button's icon and label.
  final bool isDark;

  /// Flips the app between light and dark mode.
  final VoidCallback onToggleTheme;

  /// The demo's entire row-tap UI: a snack bar summarizing the tapped
  /// row. [DataGrid] performs no row-tap UI itself — whatever should
  /// happen lives here, in the consumer.
  void _onRowTap(
    BuildContext context,
    int rowNumber,
    Map<String, Object?> rowData,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Row $rowNumber: ${rowData['first_name']} '
            '${rowData['last_name']} — ${rowData['email']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DataGrid Demo')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: DataGrid(
                data: _sampleRows,
                columnWidths: const <String, int>{
                  // Wide enough for the long note to be readable in-grid.
                  'notes': 220,
                  // Deliberately absurd: clamps up to the caption minimum,
                  // proving an override can never truncate a header.
                  'id': 10,
                },
                headerStyle: const TextStyle(color: Colors.white),
                chromeColor: Colors.purple,
                onRowTap: (rowNumber,  rowData) =>
                    _onRowTap(context, rowNumber, rowData),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.tonalIcon(
                onPressed: onToggleTheme,
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                label: Text(isDark ? 'Light mode' : 'Dark mode'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
