// packages/ice_chips/lib/src/ice_chip_tray/ice_picker_tray.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/src/glossary_types_todo.dart' show RecordTagDefinition;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray.dart'
    show IceChipsChipBuilder, IceChipsTray;
import 'package:ice_chips/src/ice_chip_tray/ice_chip_tray_layout.dart'
    show IceChipsTrayLayout;
import 'package:ice_chips/src/ice_chip_widget/ice_chip_data.dart'
    show IceChipData;
import 'package:ice_chips/src/tags/tags_cubit.dart' show TagsCubit;
import 'package:ice_chips/src/tags/tags_state.dart'
    show TagsError, TagsInitial, TagsLoaded, TagsLoading, TagsState;

/// Glue widget binding [TagsCubit] data to an [IceChipsTray].
///
/// Reads the loaded list of [RecordTagDefinition]s from the ambient
/// [TagsCubit], translates each to an [IceChipData] DTO, and renders
/// the result through [IceChipsTray]. Selection state is delegated to
/// the ambient [IceChipsTrayCubit].
///
/// Both Cubits must be provided above this widget in the tree:
///
/// ```dart
/// MultiBlocProvider(
///   providers: [
///     BlocProvider.value(value: iceChipsService.tagsCubit),
///     BlocProvider(create: (_) => IceChipsTrayCubit()),
///   ],
///   child: const IcePickerTray(layout: IceChipsTrayLayoutWrap()),
/// )
/// ```
///
/// The four [TagsState] cases render as:
/// - [TagsInitial] → [SizedBox.shrink].
/// - [TagsLoading] → small [CircularProgressIndicator].
/// - [TagsError]   → error text in the theme's error color.
/// - [TagsLoaded]  → [IceChipsTray] with the loaded data.
class IcePickerTray extends StatelessWidget {
  const IcePickerTray({
    required this.layout,
    this.chipBuilder,
    this.style,
    super.key,
  });

  /// Layout strategy passed through to the underlying [IceChipsTray].
  final IceChipsTrayLayout layout;

  /// Per-chip decoration passed through to the underlying [IceChipsTray].
  final IceChipsChipBuilder? chipBuilder;

  /// Optional [TextStyle] override forwarded to each [IceChip]'s label.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagsCubit, TagsState>(
      builder: (context, state) => switch (state) {
        TagsInitial() => const SizedBox.shrink(),
        TagsLoading() => const Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        TagsError(:final failure) => Text(
          failure.toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        TagsLoaded(:final tags) => _buildTray(tags),
      },
    );
  }

  Widget _buildTray(List<RecordTagDefinition> tags) {
    return IceChipsTray(
      chipCount: tags.length,
      chipDataAt: (index) => _toChipData(tags[index]),
      layout: layout,
      chipBuilder: chipBuilder ?? _defaultChipBuilder,
      style: style,
    );
  }

  IceChipData _toChipData(RecordTagDefinition tag) {
    return IceChipData(
      id: tag.id!,
      label: tag.tagName,
      colorInt: tag.color,
    );
  }

  static Widget _defaultChipBuilder(
    BuildContext _,
    IceChipData _,
    Widget chip,
  ) => chip;
}
