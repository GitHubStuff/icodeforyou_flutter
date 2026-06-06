// lib/packages/extensions/lib/widget_ext/widget_ext.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Chained transforms', type: WidgetExtShowcase)
Widget widgetExtUseCase(BuildContext context) {
  final hidden = context.knobs.boolean(
    label: 'hide (opacity 0)',
    initialValue: false,
  );

  final removed = context.knobs.boolean(
    label: 'remove (SizedBox.shrink)',
    initialValue: false,
  );

  final opacity = context.knobs.double.slider(
    label: 'opacity',
    initialValue: 1,
    min: 0,
    max: 1,
  );

  final padding = context.knobs.double.slider(
    label: 'padding',
    initialValue: 16,
    min: 0,
    max: 48,
  );

  final borderRadius = context.knobs.double.slider(
    label: 'border radius',
    initialValue: 12,
    min: 0,
    max: 40,
  );

  return WidgetExtShowcase(
    hidden: hidden,
    removed: removed,
    opacity: opacity,
    padding: padding,
    borderRadius: borderRadius,
  );
}

/// Showcase for [WidgetExt] — an extension on [Widget] (not a widget class).
/// Demonstrates chaining `withPaddingAll`, `withBackground`, `withBorder`,
/// `withOpacity`, `hide`, and `remove` on a single source widget.
class WidgetExtShowcase extends StatelessWidget {
  const WidgetExtShowcase({
    required this.hidden,
    required this.removed,
    required this.opacity,
    required this.padding,
    required this.borderRadius,
    super.key,
  });

  final bool hidden;
  final bool removed;
  final double opacity;
  final double padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final source = const Icon(Icons.star, size: 64, color: Colors.white)
        .withPaddingAll(padding)
        .withBackground(color: Colors.amber)
        .withBorder(
          color: Colors.deepOrange,
          width: 3,
          radius: borderRadius,
        )
        .withOpacity(opacity)
        .hide(hidden)
        .remove(removed);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          source,
          const Gap(16),
          Text(
            removed
                ? 'remove(true) → SizedBox.shrink()'
                : hidden
                    ? 'hide(true) → opacity 0 (still occupies space)'
                    : 'normal',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
