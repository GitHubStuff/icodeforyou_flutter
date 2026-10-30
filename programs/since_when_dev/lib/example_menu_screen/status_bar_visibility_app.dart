// packages/status_bar_visibility/example/lib/main.dart
// Version: 1.0.0 StatusBarVisibility

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:status_bar_visibility/status_bar_visibility.dart'
    show StatusBarVisibility;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isSupported = await StatusBarVisibility.init();
  runApp(StatusBarVisibilityApp(isSupported: isSupported));
}

/// Root application widget.
class StatusBarVisibilityApp extends StatelessWidget {
  /// Creates the root application widget.
  const StatusBarVisibilityApp({required this.isSupported, super.key});

  /// Whether the current platform supports status bar toggling.
  final bool isSupported;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Status Bar Visibility',
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    ),
    home: const StatusBarVisibilityPage(),
  );
}

/// Page holding the visibility status box and its toggle switch.
class StatusBarVisibilityPage extends StatefulWidget {
  /// Creates the page.
  const StatusBarVisibilityPage({super.key});

  @override
  State<StatusBarVisibilityPage> createState() =>
      _StatusBarVisibilityPageState();
}

class _StatusBarVisibilityPageState extends State<StatusBarVisibilityPage> {
  bool _isHidden = StatusBarVisibility.isHidden ?? true;
  late final bool isSupported;

  void _onChanged({required bool isHidden}) {
    StatusBarVisibility.setVisibility(isHidden: isHidden);
    setState(() => _isHidden = StatusBarVisibility.isHidden ?? isHidden);
  }

  @override
  void initState() {
    super.initState();
    isSupported = StatusBarVisibility.isSupported;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Status Bar Visibility')),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VisibilityStatusBox(
                isHidden: _isHidden,
                isSupported: isSupported,
              ),
              const Gap(24),
              VisibilitySwitch(
                isHidden: _isHidden,
                onChanged: (value) => _onChanged(isHidden: value),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Card showing the current status bar state and platform support.
class VisibilityStatusBox extends StatelessWidget {
  /// Creates the status box.
  const VisibilityStatusBox({
    required this.isHidden,
    required this.isSupported,
    super.key,
  });

  /// Whether the status bar is currently hidden.
  final bool isHidden;

  /// Whether the current platform supports status bar toggling.
  final bool isSupported;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              size: 64,
              color: isHidden ? colors.error : colors.primary,
            ),
            const Gap(12),
            Text(
              isHidden ? 'Hidden' : 'Visible',
              style: theme.textTheme.headlineSmall,
            ),
            const Gap(4),
            Text(
              isSupported
                  ? 'Platform supported'
                  : 'Platform unsupported (no-op)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch that hides the status bar when on and shows it when off.
class VisibilitySwitch extends StatelessWidget {
  /// Creates the switch.
  const VisibilitySwitch({
    required this.isHidden,
    required this.onChanged,
    super.key,
  });

  /// Whether the status bar is currently hidden.
  final bool isHidden;

  /// Called with the new hidden state when the switch is toggled.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: const Text('Hide status bar'),
    secondary: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
    value: isHidden,
    onChanged: onChanged,
  );
}
