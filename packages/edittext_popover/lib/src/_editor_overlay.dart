// lib/src/_editor_overlay.dart
import 'dart:async';

import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:edittext_popover/src/_full_screen_editor.dart';
import 'package:edittext_popover/src/_positioned_editor.dart';
import 'package:edittext_popover/src/editor_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main overlay widget that manages the editor popover lifecycle.
/// Handles text controller, focus, and cubit initialization/disposal.
/// Delegates to FullScreenEditor or PositionedEditor based on device type.
/// Returns EditorCompleted or EditorDismissed via Navigator.pop.

class EditorOverlay extends StatefulWidget {
  const EditorOverlay({
    required this.initialText,
    required this.textStyle,
    required this.barrierColor,
    required this.saveWidget,
    required this.cancelWidget,
    required this.targetRect,
    required this.isFullScreen,
    super.key,
  });

  final String initialText;
  final TextStyle textStyle;
  final Color barrierColor;
  final Widget saveWidget;
  final Widget cancelWidget;
  final Rect? targetRect;
  final bool isFullScreen;

  @override
  State<EditorOverlay> createState() => _EditorOverlayState();
}

class _EditorOverlayState extends State<EditorOverlay> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final EditorScreenCubit _cubit;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _cubit = EditorScreenCubit(initialText: widget.initialText);

    _textController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    _cubit.updateText(_textController.text);
  }

  void _onSave() {
    Navigator.of(context).pop(EditorCompleted(text: _textController.text));
  }

  void _onCancel() {
    Navigator.of(context).pop(EditorDismissed(text: _textController.text));
  }

  @override
  void dispose() {
    _textController..removeListener(_onTextChanged)
    ..dispose();
    _focusNode.dispose();
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: ColoredBox(color: widget.barrierColor),
              ),
            ),
            _buildEditor(mediaQuery),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(MediaQueryData mediaQuery) {
    if (widget.isFullScreen) {
      return FullScreenEditor(
        textController: _textController,
        focusNode: _focusNode,
        textStyle: widget.textStyle,
        saveWidget: widget.saveWidget,
        cancelWidget: widget.cancelWidget,
        onSave: _onSave,
        onCancel: _onCancel,
        safeArea: mediaQuery.padding,
        viewInsets: mediaQuery.viewInsets,
      );
    }

    return PositionedEditor(
      textController: _textController,
      focusNode: _focusNode,
      textStyle: widget.textStyle,
      saveWidget: widget.saveWidget,
      cancelWidget: widget.cancelWidget,
      onSave: _onSave,
      onCancel: _onCancel,
      targetRect: widget.targetRect,
      viewInsets: mediaQuery.viewInsets,
    );
  }
}
