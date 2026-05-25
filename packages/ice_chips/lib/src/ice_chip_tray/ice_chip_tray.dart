// packages/ice_chips_tray/lib/src/ice_chips_tray.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart' show IceChip;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_cubit.dart'
    show IceChipsTrayCubit;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart'
    show IceChipsTrayLayout;
import 'package:ice_chips/src/ice_chip_widget/ice_chip_data.dart'
    show IceChipData;

/// Decorates an individual chip widget within an [IceChipsTray].
///
/// Receives the chip's data and the rendered [IceChip] widget; returns
/// whatever wrapping the caller wants (e.g. [Dismissible], [Padding],
/// [Tooltip], or compositions thereof). Default behavior is identity —
/// the chip is returned unchanged.
typedef IceChipsChipBuilder =
    Widget Function(
      BuildContext context,
      IceChipData data,
      Widget chip,
    );

Widget _identityChipBuilder(
  BuildContext _,
  IceChipData _,
  Widget chip,
) => chip;

/// Renders a collection of [IceChip]s with selection state managed by
/// an ambient [IceChipsTrayCubit].
///
/// Reads `Set<int>` of selected ids from the nearest [IceChipsTrayCubit]
/// in the widget tree (callers must provide one via [BlocProvider]).
/// Tapping a chip toggles its membership in the set.
///
/// Layout is delegated to an [IceChipsTrayLayout] strategy — typically
/// [IceChipsTrayLayoutWrap] for display, [IceChipsTrayLayoutList] for
/// scrollable or swipe-to-dismiss editing.
///
/// Per-chip decoration (dismissibility, padding, tooltips) is delegated
/// to an [IceChipsChipBuilder] callback. Default: identity.
///
/// The tray is domain-free — it operates only on [IceChipData] and
/// integer ids. Translate domain types at the call site.
class IceChipsTray extends StatelessWidget {
  const IceChipsTray({
    required this.chipCount,
    required this.chipDataAt,
    required this.layout,
    this.chipBuilder = _identityChipBuilder,
    this.style,
    super.key,
  });

  /// Total number of chips to render.
  final int chipCount;

  /// Returns the [IceChipData] at the given index. Called with indices
  /// in the range `[0, chipCount)`.
  final IceChipData Function(int index) chipDataAt;

  /// Layout strategy — decides how chips are arranged spatially.
  final IceChipsTrayLayout layout;

  /// Per-chip decoration. Default returns the chip unchanged.
  final IceChipsChipBuilder chipBuilder;

  /// Optional [TextStyle] override forwarded to each [IceChip]'s label.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IceChipsTrayCubit, Set<int>>(
      builder: (context, selected) {
        return layout.build(
          context,
          chipCount,
          (index) => _buildChip(context, index, selected),
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, int index, Set<int> selected) {
    final data = chipDataAt(index);
    final chip = IceChip(
      data.label,
      backgroundColorInt: data.colorInt,
      showBorder: selected.contains(data.id),
      onPress: () => context.read<IceChipsTrayCubit>().toggle(data.id),
      style: style,
    );
    return chipBuilder(context, data, chip);
  }
}
