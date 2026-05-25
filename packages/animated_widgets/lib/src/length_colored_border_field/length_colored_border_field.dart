// animated_widgets/lib/src/length_colored_border_field/length_colored_border_field.dart

import 'package:animated_widgets/src/length_colored_border_field/color_point_ramp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [TextField] whose border color is driven by current text length,
/// resolved through a [ColorPointRamp].
///
/// When [maxLength] is non-null, a counter pill renders on the top-right
/// edge of the border showing `current/max`, and input is hard-capped at
/// [maxLength] characters. When [maxLength] is null, no counter renders
/// and no cap applies.
///
/// If [controller] is null, the widget creates and disposes its own
/// [TextEditingController]. If [controller] is supplied, the caller owns
/// its lifecycle.
class LengthColoredBorderField extends StatefulWidget {
  /// Creates a [LengthColoredBorderField] driven by [ramp].
  const LengthColoredBorderField({
    required this.ramp,
    this.controller,
    this.style,
    this.maxLength,
    super.key,
  });

  /// The ramp mapping text length to border color.
  final ColorPointRamp ramp;

  /// Optional caller-owned controller. When null, the widget owns one.
  final TextEditingController? controller;

  /// Optional text style forwarded to the inner [TextField].
  final TextStyle? style;

  /// Optional hard cap on input length. When non-null, a counter pill
  /// renders on the top-right of the border and input is limited to this
  /// many characters.
  final int? maxLength;

  @override
  State<LengthColoredBorderField> createState() =>
      _LengthColoredBorderFieldState();
}

class _LengthColoredBorderFieldState extends State<LengthColoredBorderField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  late Color _borderColor;
  late int _length;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _length = _controller.text.length;
    _borderColor = widget.ramp.colorFor(_length);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(LengthColoredBorderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ramp != oldWidget.ramp) {
      final next = widget.ramp.colorFor(_length);
      if (next != _borderColor) {
        setState(() => _borderColor = next);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final nextLength = _controller.text.length;
    final nextColor = widget.ramp.colorFor(nextLength);
    final lengthChanged = nextLength != _length;
    final colorChanged = nextColor != _borderColor;
    if (!lengthChanged && !colorChanged) return;
    setState(() {
      _length = nextLength;
      _borderColor = nextColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = OutlineInputBorder(
      borderSide: BorderSide(color: _borderColor),
    );
    final focused = OutlineInputBorder(
      borderSide: BorderSide(color: _borderColor, width: 2),
    );

    final field = TextField(
      controller: _controller,
      style: widget.style,
      maxLength: widget.maxLength,
      // Hide the default below-field counter; we render our own on the border.
      buildCounter: _hiddenCounter,
      inputFormatters: widget.maxLength == null
          ? null
          : [LengthLimitingTextInputFormatter(widget.maxLength)],
      decoration: InputDecoration(
        border: enabled,
        enabledBorder: enabled,
        focusedBorder: focused,
      ),
    );

    if (widget.maxLength == null) return field;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        field,
        Positioned(
          top: -8,
          right: 12,
          child: _CounterPill(
            length: _length,
            maxLength: widget.maxLength!,
            color: _borderColor,
            background: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }

  Widget? _hiddenCounter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) => null;
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.length,
    required this.maxLength,
    required this.color,
    required this.background,
  });

  final int length;
  final int maxLength;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$length/$maxLength',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
