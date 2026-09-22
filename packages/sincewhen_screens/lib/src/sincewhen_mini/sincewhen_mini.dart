// packages/sincewhen_screens/lib/src/sincewhen_mini/sincewhen_mini.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMiniState;
import 'package:sincewhen_screens/src/cubit/cubit.dart' show SinceWhenMiniCubit;
import 'package:sincewhen_screens/src/cubit/state.dart'
    show SinceWhenMiniLoading, SinceWhenMiniReady;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;
import 'package:sincewhen_screens/src/widgets/since_when_mini_action_bar.dart'
    show SinceWhenMiniActionBar;
import 'package:sincewhen_screens/src/widgets/since_when_mini_text_column.dart'
    show SinceWhenMiniTextColumn;
import 'package:sincewhen_screens/src/widgets/sincewhen_mini_timestamp_column.dart'
    show SinceWhenMiniTimestampColumn;

/// {@template since_when_mini}
/// Create/edit screen for a [SinceWhenItem], laid out for an iPad mini
/// in landscape (≈1133 × 744 logical pixels).
///
/// Pass `null` as [item] to create a new record, or an existing record
/// to edit it. The screen pops with the resulting [SinceWhenItem] on
/// the primary action, or `null` on Cancel:
///
/// ```dart
/// final result = await Navigator.push<SinceWhenItem?>(
///   context,
///   SinceWhenMini.route(item: existing),
/// );
/// ```
///
/// The primary button is contextual (see [SinceWhenMiniAction]):
/// `Submit` when creating, `Update` when editing with changes,
/// `Reviewed` when editing without changes.
/// {@endtemplate}
class SinceWhenMini extends StatelessWidget {
  /// {@macro since_when_mini}
  const SinceWhenMini({
    this.item,
    this.now = DateTime.now,
    super.key,
  });

  /// The record to edit, or `null` to create a new record.
  final SinceWhenItem? item;

  /// Clock used for timestamp minting; inject a fake in tests.
  final DateTime Function() now;

  /// Builds a route that pops a [SinceWhenItem] on the primary action
  /// or `null` on Cancel.
  static Route<SinceWhenItem?> route({SinceWhenItem? item}) {
    return MaterialPageRoute<SinceWhenItem?>(
      builder: (_) => SinceWhenMini(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SinceWhenMiniCubit>(
      create: (_) => SinceWhenMiniCubit(item: item, now: now),
      child: _SinceWhenMiniView(item: item),
    );
  }
}

/// Stateful glue: controller and focus lifecycle, cubit wiring, pops.
class _SinceWhenMiniView extends StatefulWidget {
  const _SinceWhenMiniView({required this.item});

  final SinceWhenItem? item;

  @override
  State<_SinceWhenMiniView> createState() => _SinceWhenMiniViewState();
}

class _SinceWhenMiniViewState extends State<_SinceWhenMiniView> {
  late final TextEditingController _contentController;
  late final TextEditingController _tldrController;
  late final TextEditingController _metaDataController;
  final FocusNode _contentFocusNode = FocusNode(
    debugLabel: 'since_when_mini_content',
  );

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.item?.content ?? '',
    );
    _tldrController = TextEditingController(
      text: widget.item?.tldr ?? '',
    );
    _metaDataController = TextEditingController(
      text: widget.item?.metaData ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tldrController.dispose();
    _metaDataController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  /// Grants the content field focus once the draft is ready.
  ///
  /// Deferred a frame so the field exists before focus is requested —
  /// in create mode the fields are not built until Loading→Ready.
  void _focusContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _contentFocusNode.requestFocus();
      }
    });
  }

  Future<void> _onPrimaryPressed() async {
    final navigator = Navigator.of(context);
    final result = await context.read<SinceWhenMiniCubit>().complete();
    navigator.pop<SinceWhenItem?>(result);
  }

  void _onCancelPressed() {
    Navigator.of(context).pop<SinceWhenItem?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SinceWhenMiniCubit, SinceWhenMiniState>(
          listener: (context, state) {
            if (state is SinceWhenMiniReady) {
              _focusContent();
            }
          },
          builder: (context, state) {
            return switch (state) {
              SinceWhenMiniLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              SinceWhenMiniReady() => _ReadyBody(
                state: state,
                contentController: _contentController,
                tldrController: _tldrController,
                metaDataController: _metaDataController,
                contentFocusNode: _contentFocusNode,
                onPrimaryPressed: _onPrimaryPressed,
                onCancelPressed: _onCancelPressed,
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Landscape arrangement: timestamp and text columns side by side
/// over the action bar.
///
/// Arrangement is this widget's sole responsibility; a small-screen
/// variant replaces exactly this widget and reuses every child.
class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.state,
    required this.contentController,
    required this.tldrController,
    required this.metaDataController,
    required this.contentFocusNode,
    required this.onPrimaryPressed,
    required this.onCancelPressed,
  });

  final SinceWhenMiniReady state;
  final TextEditingController contentController;
  final TextEditingController tldrController;
  final TextEditingController metaDataController;
  final FocusNode contentFocusNode;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SinceWhenMiniCubit>();
    return Padding(
      padding: const EdgeInsets.all(
        SinceWhenMiniDimensions.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: SinceWhenMiniDimensions.timestampColumnFlex,
                  child: SinceWhenMiniTimestampColumn(
                    state: state,
                    onEventSelected: cubit.eventTimestampChanged,
                    onEventCleared: cubit.eventTimestampCleared,
                  ),
                ),
                const Gap(SinceWhenMiniDimensions.columnGap),
                Expanded(
                  flex: SinceWhenMiniDimensions.textColumnFlex,
                  child: SinceWhenMiniTextColumn(
                    contentController: contentController,
                    tldrController: tldrController,
                    metaDataController: metaDataController,
                    contentFocusNode: contentFocusNode,
                    onContentChanged: cubit.contentChanged,
                    onTldrChanged: cubit.tldrChanged,
                    onMetaDataChanged: cubit.metaDataChanged,
                  ),
                ),
              ],
            ),
          ),
          const Gap(SinceWhenMiniDimensions.actionBarTopGap),
          SinceWhenMiniActionBar(
            primaryAction: state.primaryAction,
            isPrimaryEnabled: state.isPrimaryEnabled,
            onPrimaryPressed: onPrimaryPressed,
            onCancelPressed: onCancelPressed,
          ),
        ],
      ),
    );
  }
}
