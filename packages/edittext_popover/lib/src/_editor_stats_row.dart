// lib/src/_editor_stats_row.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:edittext_popover/src/_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays real-time line and character count statistics.
/// Shows "ln: X  ch: Y" right-aligned above the text field.
/// Rebuilds via BlocBuilder when EditorScreenCubit state changes.

class EditorStatsRow extends StatelessWidget {
  const EditorStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: kStatsHeight,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: kStatsRightPadding),
          child: BlocBuilder<EditorScreenCubit, EditorState>(
            builder: (context, state) {
              return Text(
                'ln: ${state.lineCount}  ch: ${state.characterCount}',
                style: TextStyle(
                  fontSize: kStatsFontSize,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: '.SF UI Text',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
