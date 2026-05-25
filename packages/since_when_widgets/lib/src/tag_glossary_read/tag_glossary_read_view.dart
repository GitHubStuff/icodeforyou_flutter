// since_when_widgets/lib/src/tag_glossary_read/tag_glossary_read_view.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show GlossaryReader, IceChip, RecordTagDefinition;
import 'package:since_when_widgets/src/tag_glossary_read/tag_glossary_read_cubit.dart';
import 'package:since_when_widgets/src/tag_glossary_read/tag_glossary_read_state.dart';

/// Embeddable read-only view of every tag in the glossary.
///
/// Provides its own `TagGlossaryReadCubit` over the supplied [reader]
/// and runs `load()` on first build. Hosts that need to trigger a
/// refresh (e.g. after a successful Create) can change the widget's
/// [refreshKey] — any value change re-runs `load()`.
///
/// Renders a [Wrap] of [IceChip]s. Each chip toggles its own border on
/// tap; hosts that want notification of the tap supply [onTap].
class TagGlossaryReadView extends StatelessWidget {
  /// Creates the view.
  const TagGlossaryReadView({
    required this.reader,
    this.onTap,
    this.refreshKey,
    super.key,
  });

  /// Source of glossary data. Typically obtained from the service locator.
  final GlossaryReader reader;

  /// Optional tap callback. Fires after the chip's border has toggled.
  final ValueChanged<RecordTagDefinition>? onTap;

  /// Change this value to force a refresh — useful after a Create completes.
  final Object? refreshKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TagGlossaryReadCubit>(
      create: (_) {
        final cubit = TagGlossaryReadCubit(reader);
        unawaited(cubit.load());
        return cubit;
      },
      child: _ReadBody(onTap: onTap, refreshKey: refreshKey),
    );
  }
}

class _ReadBody extends StatefulWidget {
  const _ReadBody({required this.onTap, required this.refreshKey});

  final ValueChanged<RecordTagDefinition>? onTap;
  final Object? refreshKey;

  @override
  State<_ReadBody> createState() => _ReadBodyState();
}

class _ReadBodyState extends State<_ReadBody> {
  @override
  void didUpdateWidget(covariant _ReadBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshKey != oldWidget.refreshKey) {
      unawaited(context.read<TagGlossaryReadCubit>().load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagGlossaryReadCubit, TagGlossaryReadState>(
      builder: (context, state) {
        return switch (state) {
          TagGlossaryReadLoading() => const _Loading(),
          TagGlossaryReadEmpty() => const _Empty(),
          TagGlossaryReadError(:final failure) => _Error(failure: failure),
          TagGlossaryReadLoaded(:final records) => _ChipWrap(
            records: records,
            onTap: widget.onTap,
          ),
        };
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        'No tags yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.failure});

  final Object failure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        failure.toString(),
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.records, required this.onTap});

  final List<RecordTagDefinition> records;
  final ValueChanged<RecordTagDefinition>? onTap;

  static const _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _spacing,
      runSpacing: _spacing,
      children: [
        for (final record in records)
          _BorderToggleChip(
            key: ValueKey<int?>(record.id),
            record: record,
            onTap: onTap,
          ),
      ],
    );
  }
}

/// One chip that owns its own border-shown bool.
///
/// Per-chip state (rather than a [Set] in the parent) keeps the
/// bookkeeping local and matches Flutter's widget-state model: identity
/// is preserved across reloads via the [ValueKey] supplied by the parent.
class _BorderToggleChip extends StatefulWidget {
  const _BorderToggleChip({
    required this.record,
    required this.onTap,
    super.key,
  });

  final RecordTagDefinition record;
  final ValueChanged<RecordTagDefinition>? onTap;

  @override
  State<_BorderToggleChip> createState() => _BorderToggleChipState();
}

class _BorderToggleChipState extends State<_BorderToggleChip> {
  bool _showBorder = false;

  void _toggle() {
    setState(() => _showBorder = !_showBorder);
    widget.onTap?.call(widget.record);
  }

  @override
  Widget build(BuildContext context) {
    return IceChip(
      widget.record.tagName,
      backgroundColorInt: widget.record.color,
      showBorder: _showBorder,
      onPress: _toggle,
    );
  }
}
