// programs/shared_home.dart
// Used when building apps as a 'stub'/'template'
import 'package:flutter/material.dart';
import 'package:rail_navigation/rail_navigation.dart';

/// The seed color for the demo theme.
const Color _kSeedColor = Colors.teal;

/// The overflow destinations, in order, starting at screen index 3.
///
/// Padded well past the popover's max height so the list scrolls and
/// the scroll haptic tick can be felt. Games hosts the
/// state-preservation counter; About is deliberately not a Scaffold.
const List<({String label, IconData icon})> _kOverflowItems = [
  (label: 'Games', icon: Icons.sports_esports),
  (label: 'About', icon: Icons.info),
  (label: 'Help', icon: Icons.help),
  (label: 'Privacy', icon: Icons.privacy_tip),
  (label: 'Terms', icon: Icons.gavel),
  (label: 'Licenses', icon: Icons.article),
  (label: 'Feedback', icon: Icons.feedback),
  (label: 'Credits', icon: Icons.people),
  (label: 'Backup', icon: Icons.backup),
  (label: 'Logs', icon: Icons.receipt_long),
  (label: 'Version', icon: Icons.numbers),
];

/// The screen index of the first overflow destination.
const int _kOverflowBase = 3;

/// The human-readable description shown under each transition option.
const Map<RailTransition, String> _kTransitionDescriptions = {
  RailTransition.none: 'Instant switch, no animation',
  RailTransition.fadeIn: 'Incoming screen fades in over the surface',
  RailTransition.fadeThrough: 'M3 fade-through: out, then in (default)',
  RailTransition.sharedAxis: 'Directional slide, axis follows the rail',
};

/// A dirt-dumb showcase of [RailShell].
///
/// Holds the state the parent owns — the selected destination index,
/// the theme mode, the rail placement, and the screen transition —
/// with plain [setState]. The shell displays; this widget decides.
/// The Main screen hosts radio buttons that pick the [RailTransition]
/// played on the next rail tap; the Games overflow screen carries the
/// counter that proves state survives switches under every transition.
class RailDemoApp extends StatefulWidget {
  /// Creates a [RailDemoApp].
  const RailDemoApp({super.key});

  @override
  State<RailDemoApp> createState() => _RailDemoAppState();
}

class _RailDemoAppState extends State<RailDemoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  RailPlacement _placement = RailPlacement.bottom;
  RailTransition _transition = RailTransition.fadeThrough;
  int _selectedIndex = 0;

  bool get _isDark => _themeMode == ThemeMode.dark;

  /// The index into the overflow tile list of the selected overflow
  /// destination, or 0 when a rail destination is selected.
  int get _overflowScrollIndex =>
      _selectedIndex >= _kOverflowBase ? _selectedIndex - _kOverflowBase : 0;

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _cycleRailPlacement() {
    setState(() {
      _placement = RailPlacement
          .values[(_placement.index + 1) % RailPlacement.values.length];
    });
  }

  void _setTransition(RailTransition transition) {
    setState(() {
      _transition = transition;
    });
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// The global demo controls, passed into each screen that shows an
  /// app bar. Ordinary parent-to-child dependency passing; the shell
  /// is not involved.
  List<Widget> get _demoActions {
    final placementIcon = switch (_placement) {
      RailPlacement.bottom => const Icon(Icons.view_sidebar),
      RailPlacement.left => Transform.flip(
        flipX: true,
        child: const Icon(Icons.view_sidebar),
      ),
      RailPlacement.right => const Icon(Icons.call_to_action),
    };

    final placementTooltip = switch (_placement) {
      RailPlacement.bottom => 'Move rail to the left',
      RailPlacement.left => 'Move rail to the right',
      RailPlacement.right => 'Move rail to the bottom',
    };

    return [
      IconButton(
        onPressed: _cycleRailPlacement,
        icon: placementIcon,
        tooltip: placementTooltip,
      ),
      IconButton(
        onPressed: _toggleTheme,
        icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
        tooltip: _isDark ? 'Switch to light mode' : 'Switch to dark mode',
      ),
    ];
  }

  List<Widget> _popoverTiles() {
    return [
      for (final (i, item) in _kOverflowItems.indexed)
        RailPopoverTile<int>(
          value: _kOverflowBase + i,
          isSelected: _selectedIndex == _kOverflowBase + i,
          icon: Icon(item.icon),
          label: Text(item.label),
        ),
    ];
  }

  List<Widget> _railChildren() {
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
      RailOverflowButton<int>(
        isSelected: _selectedIndex >= _kOverflowBase,
        initialScrollIndex: _overflowScrollIndex,
        onSelected: _select,
        popoverChildren: _popoverTiles(),
      ),
    ];
  }

  List<Widget> _screens() {
    return [
      _MainScreen(
        actions: _demoActions,
        transition: _transition,
        onTransitionChanged: _setTransition,
      ),
      _DatabaseScreen(actions: _demoActions),
      _SettingsScreen(actions: _demoActions),
      // Overflow destinations, in _kOverflowItems order: Games hosts
      // the counter, About is Scaffold-less, the rest are stubs.
      _GamesScreen(actions: _demoActions),
      const _AboutScreen(),
      for (final item in _kOverflowItems.skip(2))
        _StubScreen(title: item.label, actions: _demoActions),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RailShell Demo',
      theme: ThemeData(colorSchemeSeed: _kSeedColor),
      darkTheme: ThemeData(
        colorSchemeSeed: _kSeedColor,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: RailShell(
        placement: _placement,
        transition: _transition,
        currentIndex: _selectedIndex,
        railChildren: _railChildren(),
        screens: _screens(),
      ),
    );
  }
}

/// The main screen: its own app bar and radio buttons choosing the
/// [RailTransition] played on the next rail tap.
class _MainScreen extends StatelessWidget {
  const _MainScreen({
    required this.actions,
    required this.transition,
    required this.onTransitionChanged,
  });

  /// The global demo controls to show on this screen's app bar.
  final List<Widget> actions;

  /// The transition currently in effect.
  final RailTransition transition;

  /// Called when the user picks a different transition.
  final ValueChanged<RailTransition> onTransitionChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main'), actions: actions),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Screen transition',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioGroup<RailTransition>(
            groupValue: transition,
            onChanged: (value) {
              if (value != null) onTransitionChanged(value);
            },
            child: Column(
              children: [
                for (final transition in RailTransition.values)
                  RadioListTile<RailTransition>(
                    value: transition,
                    title: Text(transition.name),
                    subtitle: Text(_kTransitionDescriptions[transition]!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The games screen, reached through the overflow popover: hosts the
/// counter and floating action button proving screen state survives
/// tab switches under every transition.
class _GamesScreen extends StatefulWidget {
  const _GamesScreen({required this.actions});

  /// The global demo controls to show on this screen's app bar.
  final List<Widget> actions;

  @override
  State<_GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<_GamesScreen> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Games'), actions: widget.actions),
      body: Center(
        child: Text(
          'Counter: $_count\n(switch tabs and come back)',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// The database screen: its own app bar with its own extra action.
class _DatabaseScreen extends StatelessWidget {
  const _DatabaseScreen({required this.actions});

  /// The global demo controls to show on this screen's app bar.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshed (pretend).')),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          ...actions,
        ],
      ),
      body: Center(
        child: Text(
          'Database screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// The settings screen: a deliberately different app bar style.
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({required this.actions});

  /// The global demo controls to show on this screen's app bar.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
        actions: actions,
      ),
      body: Center(
        child: Text(
          'Settings screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// The about screen: not a [Scaffold] at all, proving any widget is a
/// valid screen. Paints its own surface since it brings no chrome.
class _AboutScreen extends StatelessWidget {
  const _AboutScreen();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Text(
            'About screen\n(no Scaffold here at all)',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// A generic overflow destination screen: minimal scaffold, titled.
class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title, required this.actions});

  /// The screen's title.
  final String title;

  /// The global demo controls to show on this screen's app bar.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Center(
        child: Text(
          '$title screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
