// lib/packages/edittext_popover/edittext_popover.usecase.dart

import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// EditorTextField — widget-based entry point
// ---------------------------------------------------------------------------

class _EditorTextFieldHost extends StatefulWidget {
  const _EditorTextFieldHost();

  @override
  State<_EditorTextFieldHost> createState() => _EditorTextFieldHostState();
}

class _EditorTextFieldHostState extends State<_EditorTextFieldHost> {
  final TextEditingController _controller = TextEditingController(
    text: 'Tap to edit this text.',
  );
  String _lastResult = '—';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onResult(EditorResult result) {
    setState(() {
      _lastResult = switch (result) {
        EditorCompleted(:final text) => 'Saved — ${text.length} chars',
        EditorDismissed(:final text) => 'Dismissed — ${text.length} chars',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorTextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Tap to edit',
              border: OutlineInputBorder(),
            ),
            onResult: _onResult,
          ),
          const SizedBox(height: 16),
          Text(
            'Last result: $_lastResult',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'EditorTextField', type: EditorTextField)
Widget editorTextFieldUseCase(BuildContext context) {
  return const Center(child: _EditorTextFieldHost());
}

// ---------------------------------------------------------------------------
// showEditor — imperative entry point
// ---------------------------------------------------------------------------

class _ShowEditorHost extends StatefulWidget {
  const _ShowEditorHost();

  @override
  State<_ShowEditorHost> createState() => _ShowEditorHostState();
}

class _ShowEditorHostState extends State<_ShowEditorHost> {
  String _text = 'Initial text passed to showEditor.';
  String _lastResult = '—';

  Future<void> _open() async {
    final result = await showEditor(
      context: context,
      initialText: _text,
    );

    setState(() {
      _lastResult = switch (result) {
        EditorCompleted(:final text) => 'Saved — ${text.length} chars',
        EditorDismissed(:final text) => 'Dismissed — ${text.length} chars',
      };
      if (result case EditorCompleted(:final text)) {
        _text = text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _open,
            child: const Text('Open Editor'),
          ),
          const SizedBox(height: 16),
          Text(
            'Current text: $_text',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Last result: $_lastResult',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'showEditor', type: EditorTextField)
Widget showEditorUseCase(BuildContext context) {
  return const Center(child: _ShowEditorHost());
}
