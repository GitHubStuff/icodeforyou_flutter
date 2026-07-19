// programs/projector_demo/lib/main_glossary.dart

import 'package:flutter/material.dart';
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show GlossaryEntryForm;

const Color _kDemoColor = Color(0xFF3F8A5F);
const Color _kDialogDemoColor = Color(0xFF8A3F5F);

const double _kInputFontSize = 22;
const double _kButtonFontSize = 18;
const double _kLabelFontSize = 18;
const double _kPillFontSize = 12;
const double _kSectionGap = 24;

void main() => runApp(const DemoApp());

/// Minimal demo of [GlossaryEntryForm] with a light/dark theme toggle
/// and enlarged text driven entirely by theme roles.
///
/// Showcases both presentation modes: the form embedded inline in the
/// page body, and the same form presented as a dialog via
/// [GlossaryEntryForm.showAsDialog], launched from a button below the
/// inline instance.
class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  /// Applies the demo's font sizes to [base] via the theme roles the
  /// form consumes: `bodyLarge` (inputs + hex readout), `labelLarge`
  /// (buttons), `inputDecorationTheme.labelStyle` (floating field
  /// labels), and `chipTheme.labelStyle` (tag pill).
  ThemeData _sized(ThemeData base) {
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: _kInputFontSize,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: _kButtonFontSize,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        labelStyle: base.textTheme.bodyLarge?.copyWith(
          fontSize: _kLabelFontSize,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: base.textTheme.labelLarge?.copyWith(
          fontSize: _kPillFontSize,
        ),
      ),
    );
  }

  /// Replaces any visible snackbar with [message].
  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Presents the form via [GlossaryEntryForm.showAsDialog] and reports
  /// the outcome: the accept payload, or `null` when dismissed by cancel
  /// or barrier tap.
  Future<void> _showDialogDemo(BuildContext context) async {
    final payload = await GlossaryEntryForm.showAsDialog(
      context,
      accept: 'Create',
      color: _kDialogDemoColor,
    );
    if (!context.mounted) return;
    _notify(
      context,
      payload == null ? 'Dialog cancelled' : 'Dialog accepted: $payload',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlossaryEntryForm Demo',
      theme: _sized(ThemeData(brightness: Brightness.light)),
      darkTheme: _sized(ThemeData(brightness: Brightness.dark)),
      themeMode: _themeMode,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Glossary Entry'),
            actions: [
              IconButton(
                icon: Icon(
                  _themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                tooltip: 'Toggle theme',
                onPressed: _toggleTheme,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlossaryEntryForm(
                  color: _kDemoColor,
                  accept: 'Create',
                  onCancel: () => _notify(context, 'Cancelled'),
                  onAccept: (payload) => _notify(context, 'Accepted: $payload'),
                ),
                const SizedBox(height: _kSectionGap),
                const Divider(),
                const SizedBox(height: _kSectionGap),
                FilledButton.tonalIcon(
                  onPressed: () => _showDialogDemo(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Show as Dialog'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
