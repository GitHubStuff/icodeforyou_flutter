// lib/widgets/sql_text_field.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show ExpandingTextField;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: ExpandingTextField)
Widget sqlTextFieldDefaultUseCase(BuildContext context) {
  return const _SqlTextFieldKnobsHost();
}

@UseCase(name: 'In Popover', type: ExpandingTextField)
Widget sqlTextFieldInPopoverUseCase(BuildContext context) {
  return const _SqlTextFieldPopoverHost();
}

class _SqlTextFieldKnobsHost extends StatefulWidget {
  const _SqlTextFieldKnobsHost();

  @override
  State<_SqlTextFieldKnobsHost> createState() => _SqlTextFieldKnobsHostState();
}

class _SqlTextFieldKnobsHostState extends State<_SqlTextFieldKnobsHost> {
  final TextEditingController _controller = TextEditingController(
    text: 'SELECT *\nFROM users\nWHERE active = 1;',
  );
  String _lastChanged = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxLines = context.knobs.int.slider(
      label: 'maxLines',
      initialValue: 10,
      min: 1,
      max: 30,
    );

    final borderColor = context.knobs.colorOrNull(
      label: 'borderColor',
      initialValue: null,
    );

    final fontSize = context.knobs.double.slider(
      label: 'fontSize',
      initialValue: 18,
      min: 10,
      max: 32,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ExpandingTextField(
                controller: _controller,
                maxLines: maxLines,
                borderColor: borderColor,
                textStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                onChanged: (value) => setState(() => _lastChanged = value),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'onChanged: $_lastChanged',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SqlTextFieldPopoverHost extends StatefulWidget {
  const _SqlTextFieldPopoverHost();

  @override
  State<_SqlTextFieldPopoverHost> createState() =>
      _SqlTextFieldPopoverHostState();
}

class _SqlTextFieldPopoverHostState extends State<_SqlTextFieldPopoverHost> {
  final TextEditingController _controller = TextEditingController(
    text: 'SELECT *\nFROM products\nWHERE price > 100\nORDER BY price DESC;',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openDialog(BuildContext context) async {
    final maxLines = context.knobs.int.slider(
      label: 'maxLines',
      initialValue: 10,
      min: 1,
      max: 30,
    );

    final borderColor = context.knobs.colorOrNull(
      label: 'borderColor',
      initialValue: null,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Query',
                    style: Theme.of(dialogContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ExpandingTextField(
                    controller: _controller,
                    maxLines: maxLines,
                    borderColor: borderColor,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Run'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Open SQL editor'),
      ),
    );
  }
}
