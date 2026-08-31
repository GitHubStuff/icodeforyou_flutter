// packages/sincewhen_widgets/lib/src/glossary_edits/widgets/glossary_item_create_dialog.usecase.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryItem;
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show GlossaryItemCreateDialog;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// {@template glossary_item_create_dialog_use_case_host}
/// Host widget for the Widgetbook use case that provides an interactive
/// trigger button to launch [GlossaryItemCreateDialog.show] and renders
/// the resulting [GlossaryItem] state upon resolution.
/// {@endtemplate}
class GlossaryItemCreateDialogUseCaseHost extends StatefulWidget {
  /// {@macro glossary_item_create_dialog_use_case_host}
  const GlossaryItemCreateDialogUseCaseHost({
    required this.createdTimestamp,
    required this.colorArgb,
    super.key,
  });

  /// The timestamp passed into the dialog.
  final int createdTimestamp;

  /// The ARGB color integer passed into the dialog.
  final int colorArgb;

  @override
  State<GlossaryItemCreateDialogUseCaseHost> createState() =>
      _GlossaryItemCreateDialogUseCaseHostState();
}

class _GlossaryItemCreateDialogUseCaseHostState
    extends State<GlossaryItemCreateDialogUseCaseHost> {
  GlossaryItem? _resolvedItem;
  bool _wasDismissed = false;

  Future<void> _launchDialog(BuildContext context) async {
    final result = await GlossaryItemCreateDialog.show(
      context,
      createdTimestamp: widget.createdTimestamp,
      colorArgb: widget.colorArgb,
    );

    if (!mounted) return;

    setState(() {
      _resolvedItem = result;
      _wasDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () => _launchDialog(context),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Launch GlossaryItemCreateDialog'),
            ),
            const Gap(24),
            if (_wasDismissed) ...[
              Text(
                'Dialog Outcome:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              if (_resolvedItem != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('id: ${_resolvedItem!.id}'),
                        Text(
                          'createdTimestamp: '
                          '${_resolvedItem!.createdTimestamp}',
                        ),
                        Text('tag: "${_resolvedItem!.tag}"'),
                        Text(
                          'colorArgb: 0x'
                          '${_resolvedItem!.colorArgb.toRadixString(16).toUpperCase()}',
                        ),
                        Text('descr: "${_resolvedItem!.descr}"'),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'Cancelled (null returned)',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// {@template glossary_item_create_dialog_use_case}
/// Default interactive use case testing modal launch, validation barriers,
/// and model instantiation.
/// {@endtemplate}
@widgetbook.UseCase(
  name: 'Default',
  type: GlossaryItemCreateDialog,
)
Widget glossaryItemCreateDialogDefaultUseCase(BuildContext context) {
  return const GlossaryItemCreateDialogUseCaseHost(
    createdTimestamp: 1717171717,
    colorArgb: 0xFF2196F3, // Material Blue
  );
}

/// {@template glossary_item_create_dialog_embedded_use_case}
/// Direct inline view of [GlossaryItemCreateDialog] within the canvas
/// for rapid visual inspection of layouts and border rendering.
/// {@endtemplate}
@widgetbook.UseCase(
  name: 'Inline Presentation',
  type: GlossaryItemCreateDialog,
)
Widget glossaryItemCreateDialogInlineUseCase(BuildContext context) {
  return const Center(
    child: SingleChildScrollView(
      child: GlossaryItemCreateDialog(
        createdTimestamp: 1717171717,
        colorArgb: 0xFF4CAF50, // Material Green
      ),
    ),
  );
}
