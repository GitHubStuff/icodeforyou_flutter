// lib/package/edittext_popover/edittext_popover.usecase.dart

import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Default use case for EditorTextField widget.
///
/// Demonstrates basic usage with a text controller and result callback.
@widgetbook.UseCase(name: 'Default', type: EditorTextField)
Widget editorTextFieldDefault(BuildContext context) {
  return _EditorTextFieldWrapper(
    decoration: const InputDecoration(
      labelText: 'Tap to edit',
      border: OutlineInputBorder(),
    ),
  );
}

/// EditorTextField with custom styling.
///
/// Demonstrates custom text styles for both the field and editor.
@widgetbook.UseCase(name: 'Custom Styling', type: EditorTextField)
Widget editorTextFieldCustomStyling(BuildContext context) {
  return _EditorTextFieldWrapper(
    initialText: 'Custom styled text',
    decoration: const InputDecoration(
      labelText: 'Styled Editor',
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Color(0xFFF5F5F5),
    ),
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.indigo,
    ),
    editorTextStyle: const TextStyle(
      fontSize: 20,
      fontFamily: 'Courier',
      color: Colors.indigo,
    ),
  );
}

/// EditorTextField with pre-populated multiline text.
///
/// Shows how the editor handles multiple lines of text.
@widgetbook.UseCase(name: 'Multiline Content', type: EditorTextField)
Widget editorTextFieldMultiline(BuildContext context) {
  return _EditorTextFieldWrapper(
    initialText: 'Line 1: First line of text\n'
        'Line 2: Second line of text\n'
        'Line 3: Third line of text\n'
        'Line 4: Fourth line with more content',
    decoration: const InputDecoration(
      labelText: 'Multiline Notes',
      border: OutlineInputBorder(),
      helperText: 'Tap to edit multiple lines',
    ),
  );
}

/// EditorTextField with custom button widgets.
///
/// Demonstrates replacing default SAVE/CANCEL buttons with custom widgets.
@widgetbook.UseCase(name: 'Custom Buttons', type: EditorTextField)
Widget editorTextFieldCustomButtons(BuildContext context) {
  return _EditorTextFieldWrapper(
    initialText: 'Edit me!',
    decoration: const InputDecoration(
      labelText: 'Custom Buttons Demo',
      border: OutlineInputBorder(),
    ),
    editorSaveWidget: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: 20),
        SizedBox(width: 4),
        Text(
          'Done',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
    editorCancelWidget: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.close, size: 20),
        SizedBox(width: 4),
        Text(
          'Discard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// EditorTextField with custom barrier color.
///
/// Shows customization of the overlay background color.
@widgetbook.UseCase(name: 'Custom Barrier Color', type: EditorTextField)
Widget editorTextFieldCustomBarrier(BuildContext context) {
  return _EditorTextFieldWrapper(
    initialText: 'Tap to see custom barrier',
    decoration: const InputDecoration(
      labelText: 'Custom Barrier Demo',
      border: OutlineInputBorder(),
    ),
    editorBarrierColor: Colors.indigo.withValues(alpha: 0.6),
  );
}

/// Interactive playground for EditorTextField with knobs.
///
/// Allows real-time customization of various parameters.
@widgetbook.UseCase(name: 'Interactive Playground', type: EditorTextField)
Widget editorTextFieldPlayground(BuildContext context) {
  final initialText = context.knobs.string(
    label: 'Initial Text',
    initialValue: 'Hello, World!\nThis is a multiline editor.',
  );

  final labelText = context.knobs.string(
    label: 'Label Text',
    initialValue: 'Notes',
  );

  final helperText = context.knobs.stringOrNull(
    label: 'Helper Text',
    initialValue: 'Tap to open the editor',
  );

  final fontSize = context.knobs.double.slider(
    label: 'Editor Font Size',
    initialValue: 18,
    min: 12,
    max: 32,
  );

  final useFilled = context.knobs.boolean(
    label: 'Filled Input',
    initialValue: false,
  );

  final barrierOpacity = context.knobs.double.slider(
    label: 'Barrier Opacity',
    initialValue: 0.4,
    min: 0.1,
    max: 0.9,
  );

  return _EditorTextFieldWrapper(
    initialText: initialText,
    decoration: InputDecoration(
      labelText: labelText,
      helperText: helperText,
      border: const OutlineInputBorder(),
      filled: useFilled,
      fillColor: useFilled ? Colors.grey.shade100 : null,
    ),
    editorTextStyle: TextStyle(fontSize: fontSize),
    editorBarrierColor: Colors.black.withValues(alpha: barrierOpacity),
  );
}

/// Demonstrates the showEditor function directly with a button trigger.
@widgetbook.UseCase(name: 'Show Editor Function', type: EditorTextField)
Widget showEditorDemo(BuildContext context) {
  return const _ShowEditorDemoWrapper();
}

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

/// Stateful wrapper for EditorTextField to manage TextEditingController.
class _EditorTextFieldWrapper extends StatefulWidget {
  const _EditorTextFieldWrapper({
    this.initialText = '',
    this.decoration,
    this.style,
    this.editorTextStyle,
    this.editorBarrierColor,
    this.editorSaveWidget,
    this.editorCancelWidget,
  });

  final String initialText;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextStyle? editorTextStyle;
  final Color? editorBarrierColor;
  final Widget? editorSaveWidget;
  final Widget? editorCancelWidget;

  @override
  State<_EditorTextFieldWrapper> createState() =>
      _EditorTextFieldWrapperState();
}

class _EditorTextFieldWrapperState extends State<_EditorTextFieldWrapper> {
  late final TextEditingController _controller;
  String _resultMessage = 'No result yet';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorTextField(
                controller: _controller,
                decoration: widget.decoration,
                style: widget.style,
                editorTextStyle: widget.editorTextStyle,
                editorBarrierColor: widget.editorBarrierColor,
                editorSaveWidget: widget.editorSaveWidget,
                editorCancelWidget: widget.editorCancelWidget,
                onResult: (result) {
                  setState(() {
                    switch (result) {
                      case EditorCompleted(:final text):
                        _resultMessage =
                            'Completed: ${text.length} chars, '
                            '${text.split('\n').length} lines';
                      case EditorDismissed(:final text):
                        _resultMessage =
                            'Dismissed: ${text.length} chars, '
                            '${text.split('\n').length} lines';
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Result:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resultMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Demo wrapper for showEditor function.
class _ShowEditorDemoWrapper extends StatefulWidget {
  const _ShowEditorDemoWrapper();

  @override
  State<_ShowEditorDemoWrapper> createState() => _ShowEditorDemoWrapperState();
}

class _ShowEditorDemoWrapperState extends State<_ShowEditorDemoWrapper> {
  String _currentText = 'Initial content\nLine 2\nLine 3';
  String _resultMessage = 'Tap the button to open the editor';

  Future<void> _openEditor() async {
    final result = await showEditor(
      context: context,
      initialText: _currentText,
    );

    switch (result) {
      case EditorCompleted(:final text):
        setState(() {
          _currentText = text;
          _resultMessage =
              'Saved: ${text.length} chars, ${text.split('\n').length} lines';
        });
      case EditorDismissed(:final text):
        setState(() {
          _resultMessage =
              'Cancelled: ${text.length} chars, '
              '${text.split('\n').length} lines';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Using showEditor() directly:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openEditor,
                icon: const Icon(Icons.edit),
                label: const Text('Open Editor'),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Content:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Result:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resultMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
