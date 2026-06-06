// lib/packages/custom_widgets/lib/src/expanding_textfield/expanding_textfield.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ExpandingTextField)
Widget expandingTextFieldUseCase(BuildContext context) {
  final minLines = context.knobs.int.slider(
    label: 'minLines',
    initialValue: 4,
    min: 1,
    max: 10,
  );

  final maxLines = context.knobs.int.slider(
    label: 'maxLines',
    initialValue: 10,
    min: 2,
    max: 30,
  );

  final tintBorder = context.knobs.boolean(
    label: 'tint border (custom color)',
    initialValue: false,
  );

  return _ExpandingTextFieldShowcase(
    minLines: minLines,
    maxLines: maxLines < minLines ? minLines : maxLines,
    borderColor: tintBorder ? Colors.deepPurple : null,
  );
}

class _ExpandingTextFieldShowcase extends StatefulWidget {
  const _ExpandingTextFieldShowcase({
    required this.minLines,
    required this.maxLines,
    required this.borderColor,
  });

  final int minLines;
  final int maxLines;
  final Color? borderColor;

  @override
  State<_ExpandingTextFieldShowcase> createState() =>
      _ExpandingTextFieldShowcaseState();
}

class _ExpandingTextFieldShowcaseState
    extends State<_ExpandingTextFieldShowcase> {
  final _controller = TextEditingController();
  int _length = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpandingTextField(
                controller: _controller,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                borderColor: widget.borderColor,
                hintText: 'type as many lines as you like…',
                onChanged: (v) => setState(() => _length = v.length),
              ),
              const Gap(8),
              Text('length: $_length'),
            ],
          ),
        ),
      ),
    );
  }
}
