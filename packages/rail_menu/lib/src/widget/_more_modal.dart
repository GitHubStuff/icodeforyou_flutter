// packages/rail_menu/lib/src/widget/_more_modal.dart

part of '_internal.dart';

/// Presents the More modal dialog.
///
/// Passes ALL items so the modal shows the complete list.
/// Captures [RailMenuCubit] before [showDialog] pushes onto the root
/// navigator so it remains accessible outside the shell's subtree.
class _MoreModal {
  const _MoreModal();

  Future<void> show({
    required BuildContext context,
    required List<RailMenuItem> allItems,
    required Widget cancelWidget,
  }) {
    final cubit = context.read<RailMenuCubit>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _MoreModalContent(
          items: allItems,
          cancelWidget: cancelWidget,
        ),
      ),
    );
  }
}
