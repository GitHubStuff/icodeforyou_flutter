// lib/packages/animated_widgets/lib/src/contextual_reveal/src/contextual_reveal.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ContextualReveal)
Widget contextualRevealUseCase(BuildContext context) {
  final doublePosition = context.knobs.object.dropdown<ContextualPosition>(
    label: 'doublePosition',
    options: ContextualPosition.values,
    initialOption: ContextualPosition.modal,
    labelBuilder: (p) => p.name,
  );

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Tap, long-press, or double-tap the card.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const Gap(16),
        SizedBox(
          width: 240,
          height: 140,
          child: ContextualReveal(
            doublePosition: doublePosition,
            tapChild: const _RevealChip(
              icon: Icons.touch_app,
              label: 'tapped',
              color: Colors.blue,
            ),
            longChild: const _RevealChip(
              icon: Icons.pan_tool,
              label: 'long press',
              color: Colors.purple,
            ),
            doubleChild: _RevealChip(
              icon: Icons.double_arrow,
              label: 'double tap (${doublePosition.name})',
              color: Colors.deepOrange,
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'gesture me',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RevealChip extends StatelessWidget {
  const _RevealChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
