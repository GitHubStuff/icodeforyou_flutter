// lib/packages/ice_chips/lib/src/ice_chip_widget/ice_chip.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ice_chips/ice_chips.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: IceChip)
Widget iceChipUseCase(BuildContext context) {
  final message = context.knobs.string(
    label: 'message',
    initialValue: 'work',
  );

  final showBorder = context.knobs.boolean(
    label: 'showBorder',
    initialValue: true,
  );

  final color = context.knobs.color(
    label: 'background',
    initialValue: const Color(0xFF4A90E2),
  );

  return _IceChipShowcase(
    message: message,
    showBorder: showBorder,
    color: color,
  );
}

class _IceChipShowcase extends StatefulWidget {
  const _IceChipShowcase({
    required this.message,
    required this.showBorder,
    required this.color,
  });

  final String message;
  final bool showBorder;
  final Color color;

  @override
  State<_IceChipShowcase> createState() => _IceChipShowcaseState();
}

class _IceChipShowcaseState extends State<_IceChipShowcase> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IceChip(
            widget.message,
            backgroundColorInt: widget.color.toARGB32(),
            showBorder: widget.showBorder,
            onPress: () => setState(() => _taps++),
          ),
          const Gap(16),
          Text('taps: $_taps'),
        ],
      ),
    );
  }
}
