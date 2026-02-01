// packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_query_input.dart

import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';

import 'package:sqlite_viewer/src/utils/query_validator.dart';

/// A widget for entering and executing custom SELECT queries.
///
/// Provides:
/// - Multi-line text input with monospace font
/// - Real-time validation feedback
/// - Run button with loading state
/// - Clear button
/// - Expand button to open full editor popover
///
/// Used in 'SqliteViewerPage' for custom query execution.
///
/// Example:
/// ```dart
/// SqliteViewerQueryInput(
///   onExecute: (sql) => cubit.executeQuery(sql),
///   isExecuting: state is QueryExecuting,
/// )
/// ```
class SqliteViewerQueryInput extends StatefulWidget {
  /// Create [SqliteViewerQueryInput] with constructor
  const SqliteViewerQueryInput({
    required this.onExecute,
    super.key,
    this.isExecuting = false,
    this.initialQuery,
    this.hintText = 'SELECT * FROM table_name',
    this.maxLines = 5,
    this.minLines = 3,
    this.showValidation = true,
    this.enabled = true,
  });

  /// Callback when query is executed.
  final ValueChanged<String> onExecute;

  /// Whether a query is currently executing.
  final bool isExecuting;

  /// Initial query text.
  final String? initialQuery;

  /// Hint text shown when input is empty.
  final String hintText;

  /// Maximum lines for text input.
  final int maxLines;

  /// Minimum lines for text input.
  final int minLines;

  /// Whether to show real-time validation feedback.
  final bool showValidation;

  /// Whether the input is enabled.
  final bool enabled;

  @override
  State<SqliteViewerQueryInput> createState() => _SqliteViewerQueryInputState();
}

class _SqliteViewerQueryInputState extends State<SqliteViewerQueryInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _validationError;
  bool _hasInteracted = false;
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!widget.showValidation) return;

    final text = _controller.text.trim();

    setState(() {
      if (text.isEmpty) {
        _validationError = null;
      } else {
        final result = QueryValidator.validate(text);
        _validationError = result.fold(
          (failure) => failure.message,
          (_) => null,
        );
      }
    });
  }

  void _executeQuery() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final result = QueryValidator.validate(text);
    if (result.isLeft()) {
      setState(() {
        _hasInteracted = true;
        _validationError = result.fold((f) => f.message, (_) => null);
      });
      return;
    }

    widget.onExecute(text);
  }

  void _clearQuery() {
    _controller.clear();
    _focusNode.requestFocus();
    setState(() {
      _validationError = null;
      _hasInteracted = false;
    });
  }

  Future<void> _showExpandedEditor() async {
    final renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;

    Rect? targetRect;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      targetRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
    }

    final result = await showEditor(
      context: context,
      initialText: _controller.text,
      textStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      targetRect: targetRect,
    );

    if (result is EditorCompleted) {
      _controller.text = result.text;
      setState(() => _hasInteracted = true);
    }
  }

  bool get _isValid {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    return QueryValidator.isValid(text);
  }

  bool get _canExecute {
    return widget.enabled &&
        !widget.isExecuting &&
        _controller.text.trim().isNotEmpty &&
        _isValid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.code,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Custom Query',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              // Expand button
              IconButton(
                onPressed: widget.isExecuting ? null : _showExpandedEditor,
                icon: const Icon(Icons.open_in_full, size: 18),
                tooltip: 'Expand editor',
                visualDensity: VisualDensity.compact,
                color: colorScheme.onSurfaceVariant,
              ),
              if (_controller.text.isNotEmpty)
                TextButton.icon(
                  onPressed: widget.isExecuting ? null : _clearQuery,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Text input
          TextField(
            key: _textFieldKey,
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled && !widget.isExecuting,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              contentPadding: const EdgeInsets.all(12),
              errorText: (_hasInteracted || _controller.text.isNotEmpty)
                  ? _validationError
                  : null,
              errorMaxLines: 2,
            ),
            onChanged: (_) {
              if (!_hasInteracted) {
                setState(() => _hasInteracted = true);
              }
            },
            onSubmitted: (_) {
              if (_canExecute) _executeQuery();
            },
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Validation indicator
              if (widget.showValidation && _controller.text.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _isValid ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: _isValid
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isValid ? 'Valid query' : 'Invalid query',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isValid
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),

              // Run button
              FilledButton.icon(
                onPressed: _canExecute ? _executeQuery : null,
                icon: widget.isExecuting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 20),
                label: Text(widget.isExecuting ? 'Running...' : 'Run Query'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
