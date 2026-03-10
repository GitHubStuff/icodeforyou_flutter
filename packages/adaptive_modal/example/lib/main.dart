// example/lib/main.dart
// ---------------------------------------------------------------------------
// main.dart — entry point for the adaptive_modal example app.
//
// Demonstrates three scenarios on a single screen:
//   1. Default modal — barrier dismissible, default close icon.
//   2. Custom close icon — barrier dismissible, custom icon.
//   3. No barrier — background remains fully interactive.
//
// Each modal uses AdaptiveModalController<String> so show() returns a
// Future<String?> — the selected item value, or null if dismissed without
// confirming. The result is shown in a SnackBar.
// ---------------------------------------------------------------------------

// ignore_for_file: document_ignores, public_member_api_docs

import 'package:adaptive_modal/adaptive_modal.dart';
import 'package:adaptive_modal_example/modal_content.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdaptiveModalExampleApp());
}

class AdaptiveModalExampleApp extends StatelessWidget {
  const AdaptiveModalExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'adaptive_modal Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// ExampleScreen
// ---------------------------------------------------------------------------

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final GlobalKey<State<StatefulWidget>> _defaultAnchor = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _customIconAnchor = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _noBarrierAnchor = GlobalKey();

  late final AdaptiveModalController<String> _defaultModal;
  late final AdaptiveModalController<String> _customIconModal;
  late final AdaptiveModalController<String> _noBarrierModal;

  @override
  void initState() {
    super.initState();

    _defaultModal = AdaptiveModalController<String>(
      anchorKey: _defaultAnchor,
      child: ModalContent(
        label: 'Default Modal',
        onConfirm: (value) => _defaultModal.resolve(value),
      ),
    );

    _customIconModal = AdaptiveModalController<String>(
      anchorKey: _customIconAnchor,
      child: ModalContent(
        label: 'Custom Icon Modal',
        onConfirm: (value) => _customIconModal.resolve(value),
      ),
      config: const AdaptiveModalConfig(
        closeIcon: Icon(Icons.arrow_back_ios_new, size: 18),
      ),
    );

    _noBarrierModal = AdaptiveModalController<String>(
      anchorKey: _noBarrierAnchor,
      child: ModalContent(
        label: 'No Barrier Modal',
        onConfirm: (value) => _noBarrierModal.resolve(value),
      ),
      config: const AdaptiveModalConfig(
        barrierDismissible: false,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultModal.attach(context);
    _customIconModal.attach(context);
    _noBarrierModal.attach(context);
  }

  @override
  void dispose() {
    _defaultModal.dispose();
    _customIconModal.dispose();
    _noBarrierModal.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Show helpers
  // ---------------------------------------------------------------------------

  Future<void> _showAndHandle(
    AdaptiveModalController<String> modal,
  ) async {
    final result = await modal.show(context);
    if (!mounted) return;
    _showResult(result);
  }

  void _showResult(String? result) {
    final message = result != null ? 'Selected: $result' : 'Dismissed';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('adaptive_modal')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap a button to open a modal.\n'
              'On phone it fills the screen.\n'
              'On tablet, desktop, or web it anchors near the button.\n'
              'Select an item and tap Confirm to return a value.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 40),
            _TriggerButton(
              anchorKey: _defaultAnchor,
              label: 'Default modal',
              onPressed: () => _showAndHandle(_defaultModal),
            ),
            const SizedBox(height: 20),
            _TriggerButton(
              anchorKey: _customIconAnchor,
              label: 'Custom close icon',
              onPressed: () => _showAndHandle(_customIconModal),
            ),
            const SizedBox(height: 20),
            _TriggerButton(
              anchorKey: _noBarrierAnchor,
              label: 'No barrier — tap behind me',
              onPressed: () => _showAndHandle(_noBarrierModal),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TriggerButton
// ---------------------------------------------------------------------------

class _TriggerButton extends StatelessWidget {
  const _TriggerButton({
    required this.anchorKey,
    required this.label,
    required this.onPressed,
  });

  final GlobalKey anchorKey;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: anchorKey,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
