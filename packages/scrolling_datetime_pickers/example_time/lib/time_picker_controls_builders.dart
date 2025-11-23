// example/lib/time_picker_controls_builders.dart

part of 'time_picker_controls.dart';

extension on _TimePickerControlsState {
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildColorTile(String title, Color color, Function(Color) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
        ),
      ),
      onTap: () => onChanged(_cycleColor(color)),
    );
  }

  Color _cycleColor(Color current) {
    // Background colors
    if (current == const Color(0xFF000033)) return Colors.black;
    if (current == Colors.black) return Colors.blue[900]!;
    if (current == Colors.blue[900]) return const Color(0xFF000033);

    // Text colors
    if (current == Colors.white) return Colors.yellow;
    if (current == Colors.yellow) return Colors.cyan;
    if (current == Colors.cyan) return Colors.white;

    // Divider colors
    if (current == const Color(0xFFE0E0E0)) return Colors.white;
    if (current == Colors.white && current == widget.dividerColor) {
      return Colors.blue;
    }
    if (current == Colors.blue) return Colors.red;
    if (current == Colors.red) return const Color(0xFFE0E0E0);

    return const Color(0xFF000033);
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    int divisions,
    Function(double) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEffectRow() {
    final effectValue = widget.useGlowEffect
        ? 'glow'
        : (widget.useBlurEffect ? 'blur' : 'none');

    return Column(
      children: [
        ListTile(
          title: const Text('None'),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: effectValue == 'none',
              onChanged: (_) {
                widget.onGlowEffectChanged(false);
                widget.onBlurEffectChanged(false);
              },
              shape: const CircleBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Glow'),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: effectValue == 'glow',
              onChanged: (_) {
                widget.onGlowEffectChanged(true);
                widget.onBlurEffectChanged(false);
              },
              shape: const CircleBorder(),
            ),
          ),
        ),
        ListTile(
          title: const Text('Blur'),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: effectValue == 'blur',
              onChanged: (_) {
                widget.onGlowEffectChanged(false);
                widget.onBlurEffectChanged(true);
              },
              shape: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeControls() {
    return ListTile(
      title: Text(
          'Width: ${widget.portraitWidth.toInt()} | Height: ${widget.portraitHeight.toInt()}'),
      subtitle: Column(
        children: [
          Row(
            children: [
              const Text('W:'),
              Expanded(
                child: Slider(
                  value: widget.portraitWidth,
                  min: 150.0,
                  max: 350.0,
                  onChanged: widget.onPortraitWidthChanged,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('H:'),
              Expanded(
                child: Slider(
                  value: widget.portraitHeight,
                  min: 150.0,
                  max: 300.0,
                  onChanged: widget.onPortraitHeightChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
