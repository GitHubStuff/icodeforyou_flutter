// packages/rail_menu/lib/src/widget/_more_modal_content.dart

part of '_internal.dart';

const _activeCheckIcon = Icons.check;
const _modalMaxHeight = 400.0;
const _separatorHeight = 1.0;
const _modalBottomGap = 64.0;

/// Pure widget rendering the More modal's scrollable list and cancel button.
///
/// Shows ALL [items]. [activeIndex] is the global Cubit index, matched
/// directly against each item's position in the full list.
/// Active item is shown at full opacity with a checkmark.
/// Inactive items are shown at reduced opacity.
class _MoreModalContent extends StatelessWidget {
  const _MoreModalContent({
    required this.items,
    required this.cancelWidget,
  });

  final List<RailMenuItem> items;
  final Widget cancelWidget;

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<RailMenuCubit>().activeIndex;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: cancelWidget,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _modalMaxHeight),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: _separatorHeight,
                    thickness: _separatorHeight,
                  ),
                  itemBuilder: (context, index) => _MoreModalRow(
                    item: items[index],
                    isActive: index == activeIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _modalBottomGap),
          ],
        ),
      ),
    );
  }
}

class _MoreModalRow extends StatelessWidget {
  const _MoreModalRow({
    required this.item,
    required this.isActive,
  });

  final RailMenuItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1 : 0.75,
      child: _TapInterceptor(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(child: item.child),
              if (isActive)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(_activeCheckIcon),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
