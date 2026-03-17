// lib/src/tag_color_field/_tag_color_field_state.dart

part of 'tag_color_field.dart';

class _TagColorFieldState extends State<TagColorField> {
  late final Set<int> _excluded;
  late Color _current;
  late int _switcherKey;

  @override
  void initState() {
    super.initState();
    _excluded = Set<int>.from(widget.skipColors);
    _current = _generateColor();
    _switcherKey = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged(_current.toARGB32());
    });
  }

  @override
  void didUpdateWidget(TagColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _excluded.addAll(widget.skipColors);
  }

  Color _generateColor() {
    Color candidate;
    do {
      candidate = RandomColorGenerator.generate();
    } while (_excluded.contains(candidate.toARGB32()));
    return candidate;
  }

  void _onRefresh() {
    _excluded.add(_current.toARGB32());
    final next = _generateColor();
    setState(() {
      _current = next;
      _switcherKey++;
    });
    widget.onChanged(_current.toARGB32());
  }

  Color _borderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(child: _buildSwatch(context)),
          GestureDetector(
            onTap: _onRefresh,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: widget.refresh,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatch(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor(context), width: 3),
      ),
      child: AnimatedSwitcher(
        duration: widget.fadeTime,
        child: ColoredBox(
          key: ValueKey<int>(_switcherKey),
          color: _current,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
