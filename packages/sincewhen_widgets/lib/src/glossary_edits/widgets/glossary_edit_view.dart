// packages/sincewhen_widgets/lib/src/glossary_edits/glossary_edit_view.dart

import 'dart:async';

import 'package:color_grid/color_grid.dart' show ColorGrid;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryItem;
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditCubit,
        GlossaryEditInitial,
        GlossaryEditPopover,
        GlossaryEditState,
        GlossaryItemCreateDialog;

// Number of colors in the grid
const int _kDefaultColorCount = 15;

/// {@template glossary_edit_view}
/// Presentational view for editing glossary colors and tags.
///
/// Reacts to [GlossaryEditState] emitted by [GlossaryEditCubit]:
/// * [GlossaryEditInitial]: Displays a button to trigger color generation.
/// * [GlossaryEditColorRequest]: Displays a loading indicator while colors
///   are generated.
/// * [GlossaryEditColorList]: Displays a [ColorGrid] with the generated
///   color palette.
/// * [GlossaryEditPopover]: Listens for dialog invocation while keeping the
///   underlying presentation stable.
/// {@endtemplate}
class GlossaryEditView extends StatelessWidget {
  /// {@macro glossary_edit_view}
  const GlossaryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Glossary'),
      ),
      body: Center(
        child: BlocConsumer<GlossaryEditCubit, GlossaryEditState>(
          listenWhen: (previous, current) => current is GlossaryEditPopover,
          listener: (context, state) {
            if (state is GlossaryEditPopover) {
              unawaited(
                _handlePopoverRequest(
                  context,
                  colorArgb: state.colorArgb,
                  timestamp: state.timestamp,
                ),
              );
            }
          },
          buildWhen: (previous, current) => current is! GlossaryEditPopover,
          builder: (context, state) {
            return switch (state) {
              //
              GlossaryEditInitial() => ElevatedButton(
                onPressed: () => context
                    .read<GlossaryEditCubit>()
                    .requestRandomColors(count: _kDefaultColorCount),
                child: const Text('Load Color Grid'),
              ),
              //
              GlossaryEditColorRequest() => const CircularProgressIndicator(),
              //
              GlossaryEditColorList(:final colorList) => ColorGrid(
                colors: colorList
                    .map((color) => color.toARGB32())
                    .toList(growable: false),
                onRefreshRequested: () => context
                    .read<GlossaryEditCubit>()
                    .requestRandomColors(count: _kDefaultColorCount),
                onColorTapped: (index, colorValue) {
                  _onColorTapped(context, colorValue: colorValue);
                },
              ),
              // Fallback if initial state was directly popover
              GlossaryEditPopover() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Future<void> _handlePopoverRequest(
    BuildContext context, {
    required int colorArgb,
    required int timestamp,
  }) async {
    final cubit = context.read<GlossaryEditCubit>();

    final GlossaryItem? item = await GlossaryItemCreateDialog.show(
      context,
      createdTimestamp: timestamp,
      colorArgb: colorArgb,
    );

    await cubit.editComplete(glossaryItem: item);
  }

  void _onColorTapped(
    BuildContext context, {
    required int colorValue,
  }) {
    unawaited(
      context.read<GlossaryEditCubit>().requestNewId(usingColor: colorValue),
    );
  }
}
