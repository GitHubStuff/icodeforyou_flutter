// lib/src/counted_text_field/_counted_text_field_state.dart

part of 'counted_text_field.dart';

class _CountedTextFieldState extends State<CountedTextField> {
  final _controller = TextEditingController();
  var _count = 0;
  var _messageOpacity = 0.0;
  var _showMessage = false;

  bool get _isOverLimit => _count >= widget.maxLength;

  Color _activeBorderColor() =>
      _isOverLimit ? widget.errorBorderColor : widget.borderColor;

  TextDirection _resolvedDirection(BuildContext context) =>
      widget.textDirection ?? Directionality.of(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.length > widget.maxLength) {
      final truncated = value.substring(0, widget.maxLength);
      _controller.value = _controller.value.copyWith(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
      setState(() => _count = widget.maxLength);
      widget.onChanged(truncated);
      _triggerMessage();
      return;
    }
    setState(() => _count = value.length);
    widget.onChanged(value);
  }

  void _onClear() {
    _controller.clear();
    setState(() => _count = 0);
    widget.onChanged('');
  }

  void _triggerMessage() {
    setState(() {
      _showMessage = true;
      _messageOpacity = 1.0;
    });

    Future.delayed(Duration(milliseconds: widget.durationMs), () {
      if (!mounted) return;
      setState(() => _messageOpacity = 0.0);

      Future.delayed(Duration(milliseconds: widget.fadeMs), () {
        if (!mounted) return;
        setState(() => _showMessage = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _activeBorderColor();
    final direction = _resolvedDirection(context);
    final isRtl = direction == TextDirection.rtl;

    return Directionality(
      textDirection: direction,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildField(borderColor),
          _buildBadge(context, borderColor, isRtl: isRtl),
          if (widget.caption != null)
            _buildCaption(context, isRtl: isRtl),
          if (_showMessage)
            _buildFloatingMessage(context, isRtl: isRtl),
        ],
      ),
    );
  }

  Widget _buildField(Color borderColor) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                style: theme.textTheme.bodyMedium,
                textDirection: widget.textDirection,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _onClear,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: widget.clearWidget,
            ),
          ),
        ],
      ),
    );
  }
}
