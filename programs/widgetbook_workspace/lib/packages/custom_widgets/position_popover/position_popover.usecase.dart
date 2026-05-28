// widgetbook_workspace/lib/packages/position_popover/position_popover.usecase.dart
import 'package:custom_widgets/custom_widgets.dart' show PopoverHandle, PopoverPosition, PositionPopover;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum _PopoverSide { left, right, above, below, center }

@widgetbook.UseCase(name: 'Default', type: PositionPopover)
Widget positionPopoverDefault(BuildContext context) {
  final side = context.knobs.object.dropdown<_PopoverSide>(
    label: 'position',
    options: _PopoverSide.values,
    initialOption: _PopoverSide.below,
    labelBuilder: (s) => s.name,
  );

  final useDefaultSize = context.knobs.boolean(
    label: 'childSize: use default (80% × 50%)',
    initialValue: true,
  );

  final childWidth = context.knobs.double.slider(
    label: 'childSize.width',
    initialValue: 240,
    min: 80,
    max: 600,
    divisions: 52,
  );

  final childHeight = context.knobs.double.slider(
    label: 'childSize.height',
    initialValue: 160,
    min: 80,
    max: 600,
    divisions: 52,
  );

  final barrierColor = context.knobs.color(
    label: 'barrierColor',
    initialValue: Colors.black54,
  );

  final barrierDismissible = context.knobs.boolean(
    label: 'barrierDismissible',
    initialValue: true,
  );

  final hideStatusBar = context.knobs.boolean(
    label: 'hideStatusBar',
    initialValue: true,
  );

  final childItemCount = context.knobs.double
      .slider(
        label: 'child item count',
        initialValue: 8,
        min: 1,
        max: 100,
        divisions: 99,
      )
      .round();

  return _PositionPopoverStage(
    side: side,
    childSize: useDefaultSize ? null : Size(childWidth, childHeight),
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    hideStatusBar: hideStatusBar,
    childItemCount: childItemCount,
  );
}

/// Stage widget: holds the anchor button, owns the [GlobalKey], and shows the
/// popover on tap. Dismisses any open popover when the usecase rebuilds (a
/// knob changed) so we don't leak stale overlay entries.
class _PositionPopoverStage extends StatefulWidget {
  const _PositionPopoverStage({
    required this.side,
    required this.childSize,
    required this.barrierColor,
    required this.barrierDismissible,
    required this.hideStatusBar,
    required this.childItemCount,
  });

  final _PopoverSide side;
  final Size? childSize;
  final Color barrierColor;
  final bool barrierDismissible;
  final bool hideStatusBar;
  final int childItemCount;

  @override
  State<_PositionPopoverStage> createState() => _PositionPopoverStageState();
}

class _PositionPopoverStageState extends State<_PositionPopoverStage> {
  final GlobalKey _anchorKey = GlobalKey();
  PopoverHandle? _openHandle;

  @override
  void didUpdateWidget(_PositionPopoverStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Knob changed while popover was open — dismiss to avoid stale config.
    _openHandle?.dismiss();
    _openHandle = null;
  }

  @override
  void dispose() {
    _openHandle?.dismiss();
    super.dispose();
  }

  PopoverPosition _resolvePosition() {
    switch (widget.side) {
      case _PopoverSide.left:
        return PopoverPosition.left(_anchorKey);
      case _PopoverSide.right:
        return PopoverPosition.right(_anchorKey);
      case _PopoverSide.above:
        return PopoverPosition.above(_anchorKey);
      case _PopoverSide.below:
        return PopoverPosition.below(_anchorKey);
      case _PopoverSide.center:
        return PopoverPosition.center();
    }
  }

  void _show(BuildContext context) {
    _openHandle?.dismiss();
    _openHandle = PositionPopover(
      position: _resolvePosition(),
      childSize: widget.childSize,
      barrierColor: widget.barrierColor,
      barrierDismissible: widget.barrierDismissible,
      child: _PopoverContent(itemCount: widget.childItemCount),
    ).show(context, hideStatusBar: widget.hideStatusBar);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        key: _anchorKey,
        onPressed: () => _show(context),
        icon: const Icon(Icons.touch_app),
        label: Text('Show popover (${widget.side.name})'),
      ),
    );
  }
}

class _PopoverContent extends StatelessWidget {
  const _PopoverContent({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text('Item ${i + 1}'),
            subtitle: const Text('Tap the barrier to dismiss'),
          ),
        ),
      ),
    );
  }
}
