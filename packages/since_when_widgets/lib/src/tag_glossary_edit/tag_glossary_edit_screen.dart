// since_when_widgets/lib/src/tag_glossary_edit/tag_glossary_edit_screen.dart

import 'dart:async' show unawaited;

import 'package:animated_widgets/animated_widgets.dart'
    show ColorPoint, ColorPointRamp, LengthColoredBorderField;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        IceChip,
        RecordTagDefinition;
import 'package:since_when_widgets/src/tag_glossary_edit/tag_glossary_edit_cubit.dart';
import 'package:since_when_widgets/src/tag_glossary_edit/tag_glossary_edit_state.dart';

/// Self-contained edit-tag screen — handles Create, Update, and Delete.
///
/// Mode is selected by the constructor:
/// - [TagGlossaryEditScreen.create] opens blank.
/// - [TagGlossaryEditScreen.update] opens pre-populated with the given
///   record. Delete is enabled in this mode.
///
/// On successful save, [onSaved] fires with the persisted record. On
/// successful delete (Update mode only), [onDeleted] fires with the
/// just-removed record. The host typically dismisses or refreshes the
/// parent in either callback.
class TagGlossaryEditScreen extends StatelessWidget {
  /// Create-mode screen.
  const TagGlossaryEditScreen.create({
    required GlossaryRepository this.repository,
    required this.reader,
    required this.onSaved,
    required this.onDismiss,
    super.key,
  }) : writer = null,
       deleter = null,
       existing = null,
       onDeleted = null;

  /// Update-mode screen — Delete is enabled.
  const TagGlossaryEditScreen.update({
    required this.reader,
    required GlossaryWriter this.writer,
    required GlossaryDeleter this.deleter,
    required RecordTagDefinition this.existing,
    required this.onSaved,
    required ValueChanged<RecordTagDefinition> this.onDeleted,
    required this.onDismiss,
    super.key,
  }) : repository = null;

  /// Source of glossary data. Required in both modes (used by reroll).
  final GlossaryReader reader;

  /// Insert path. Set in Create mode, null in Update.
  final GlossaryRepository? repository;

  /// Update path. Set in Update mode, null in Create.
  final GlossaryWriter? writer;

  /// Delete path. Set in Update mode, null in Create.
  final GlossaryDeleter? deleter;

  /// Record being edited. Set in Update mode, null in Create.
  final RecordTagDefinition? existing;

  /// Fires when a tag is persisted.
  final ValueChanged<RecordTagDefinition> onSaved;

  /// Fires when a tag is deleted (Update mode only).
  final ValueChanged<RecordTagDefinition>? onDeleted;

  /// Fires when the user taps the dismiss affordance.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TagGlossaryEditCubit>(
      create: (_) {
        final cubit = _buildCubit();
        unawaited(cubit.init());
        return cubit;
      },
      child: BlocListener<TagGlossaryEditCubit, TagGlossaryEditState>(
        listenWhen: _justFinished,
        listener: (context, state) {
          if (state is TagGlossaryEditSaved) onSaved(state.record);
          if (state is TagGlossaryEditDeleted) onDeleted?.call(state.record);
        },
        child: BlocBuilder<TagGlossaryEditCubit, TagGlossaryEditState>(
          builder: (context, state) {
            if (state is TagGlossaryEditLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _Editor(state: state, onDismiss: onDismiss);
          },
        ),
      ),
    );
  }

  TagGlossaryEditCubit _buildCubit() {
    final existingRecord = existing;
    if (existingRecord != null) {
      return TagGlossaryEditCubit.update(
        reader: reader,
        writer: writer!,
        deleter: deleter!,
        existing: existingRecord,
      );
    }
    return TagGlossaryEditCubit.create(
      repository: repository!,
      reader: reader,
    );
  }

  /// Listens for the leading edge of either terminal state. Saved and
  /// Deleted both fire their respective callbacks exactly once.
  bool _justFinished(
    TagGlossaryEditState previous,
    TagGlossaryEditState current,
  ) {
    final wasTerminal =
        previous is TagGlossaryEditSaved || previous is TagGlossaryEditDeleted;
    final isTerminal =
        current is TagGlossaryEditSaved || current is TagGlossaryEditDeleted;
    return isTerminal && !wasTerminal;
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.state, required this.onDismiss});

  final TagGlossaryEditState state;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagGlossaryEditCubit>();
    final isUpdate = cubit.mode is TagGlossaryEditUpdate;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DismissBar(onDismiss: onDismiss),
            const SizedBox(height: 12),
            _PreviewBlock(state: state),
            const SizedBox(height: 16),
            _FieldRow(state: state),
            const SizedBox(height: 8),
            _ErrorBanner(state: state),
            const SizedBox(height: 16),
            _ActionRow(state: state, isUpdate: isUpdate),
          ],
        ),
      ),
    );
  }
}

class _DismissBar extends StatelessWidget {
  const _DismissBar({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Dismiss',
        onPressed: onDismiss,
      ),
    );
  }
}

/// Live preview chip on top, reroll button centered below.
///
/// Owns the chip's border-shown toggle as local widget state — purely
/// visual, never participates in save/validation.
class _PreviewBlock extends StatefulWidget {
  const _PreviewBlock({required this.state});

  final TagGlossaryEditState state;

  @override
  State<_PreviewBlock> createState() => _PreviewBlockState();
}

class _PreviewBlockState extends State<_PreviewBlock> {
  bool _showBorder = false;

  void _toggleBorder() => setState(() => _showBorder = !_showBorder);

  void _reroll() => context.read<TagGlossaryEditCubit>().rerollColor();

  @override
  Widget build(BuildContext context) {
    final draft = _Draft.of(widget.state);
    if (draft == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: IceChip(
            draft.name,
            backgroundColorInt: draft.color.toARGB32(),
            showBorder: _showBorder,
            onPress: _toggleBorder,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Try another colour',
            onPressed: _reroll,
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatefulWidget {
  const _FieldRow({required this.state});

  final TagGlossaryEditState state;

  @override
  State<_FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<_FieldRow> {
  late final TextEditingController _controller;

  static const int _maxLength = 15;

  static final ColorPointRamp _ramp = ColorPointRamp(const [
    ColorPoint(point: 0, color: Color(0xFF800080)), // purple
    ColorPoint(point: 3, color: Color(0xFF00C853)), // green
    ColorPoint(point: 8, color: Color(0xFFFFC107)), // yellow
    ColorPoint(point: 11, color: Color(0xFFD32F2F)), // red
  ]);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialName());
    _controller.addListener(_pushNameToCubit);
  }

  @override
  void didUpdateWidget(covariant _FieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = _Draft.of(widget.state)?.name ?? '';
    if (incoming != _controller.text) {
      _controller.value = TextEditingValue(
        text: incoming,
        selection: TextSelection.collapsed(offset: incoming.length),
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_pushNameToCubit)
      ..dispose();
    super.dispose();
  }

  String _initialName() => _Draft.of(widget.state)?.name ?? '';

  void _pushNameToCubit() {
    context.read<TagGlossaryEditCubit>().nameChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return LengthColoredBorderField(
      ramp: _ramp,
      controller: _controller,
      maxLength: _maxLength,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.state});

  final TagGlossaryEditState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s is! TagGlossaryEditError) return const SizedBox.shrink();
    return Text(
      s.failure.toString(),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

/// Bottom row of actions. Save is always shown; Delete only in Update.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.state, required this.isUpdate});

  final TagGlossaryEditState state;
  final bool isUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isUpdate) ...[
          _DeleteButton(state: state),
          const SizedBox(width: 12),
        ],
        _SaveButton(state: state),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.state});

  final TagGlossaryEditState state;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _enabled ? () => _save(context) : null,
      child: _label,
    );
  }

  bool get _enabled {
    final s = state;
    if (s is TagGlossaryEditReady) return s.canSave;
    return false;
  }

  Widget get _label {
    if (state is TagGlossaryEditSaving) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return const Text('Save');
  }

  void _save(BuildContext context) =>
      context.read<TagGlossaryEditCubit>().save();
}

/// Delete affordance for Update mode. Opens a confirm dialog before
/// invoking [TagGlossaryEditCubit.delete]; disabled outside Ready to
/// prevent racing terminal transitions.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.state});

  final TagGlossaryEditState state;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _enabled ? () => _confirm(context) : null,
      icon: _icon,
      label: const Text('Delete'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  bool get _enabled => state is TagGlossaryEditReady;

  Widget get _icon {
    if (state is TagGlossaryEditDeleting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return const Icon(Icons.delete_outline);
  }

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<TagGlossaryEditCubit>();
    final tagName = (state as TagGlossaryEditReady).name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(
          'Delete "$tagName"? This will remove the tag from every '
          'record using it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await cubit.delete();
    }
  }
}

/// Pulls (name, color) from any state that carries them. Returns null
/// for states that don't (Loading, Saved, Deleted).
class _Draft {
  const _Draft({required this.name, required this.color});

  final String name;
  final Color color;

  static _Draft? of(TagGlossaryEditState state) => switch (state) {
    TagGlossaryEditReady(:final name, :final color) => _Draft(
      name: name,
      color: color,
    ),
    TagGlossaryEditSaving(:final name, :final color) => _Draft(
      name: name,
      color: color,
    ),
    TagGlossaryEditDeleting(:final name, :final color) => _Draft(
      name: name,
      color: color,
    ),
    TagGlossaryEditError(:final name, :final color) => _Draft(
      name: name,
      color: color,
    ),
    TagGlossaryEditLoading() ||
    TagGlossaryEditSaved() ||
    TagGlossaryEditDeleted() => null,
  };
}
