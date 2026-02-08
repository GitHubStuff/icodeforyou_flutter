// widgetbook_demo_widgets v2.0
part of 'animated_checkbox_widgetbook.dart';
// animation_curves_demo_widget.dart v2.3
// Duration changes don't restore removed curves, reload button restores all

enum CheckmarkState { notDrawn, drawing, drawn, dissolving }

class _AnimationCurvesDemo extends StatefulWidget {
  const _AnimationCurvesDemo();

  @override
  State<_AnimationCurvesDemo> createState() => _AnimationCurvesDemoState();
}

class _AnimationCurvesDemoState extends State<_AnimationCurvesDemo> {
  double _duration = 2.0;

  // Master list of all available curves
  static const List<Curve> _allCurves = [
    // Basic smooth curves
    Curves.linear,
    Curves.ease,
    Curves.decelerate,
    Curves.fastOutSlowIn,
    Curves.slowMiddle,

    // Ease In family
    Curves.easeIn,
    Curves.easeInSine,
    Curves.easeInQuad,
    Curves.easeInCubic,
    Curves.easeInQuart,
    Curves.easeInQuint,
    Curves.easeInExpo,
    Curves.easeInCirc,

    // Ease Out family
    Curves.easeOut,
    Curves.easeOutSine,
    Curves.easeOutQuad,
    Curves.easeOutCubic,
    Curves.easeOutQuart,
    Curves.easeOutQuint,
    Curves.easeOutExpo,
    Curves.easeOutCirc,

    // Ease In-Out family
    Curves.easeInOut,
    Curves.easeInOutSine,
    Curves.easeInOutQuad,
    Curves.easeInOutCubic,
    Curves.easeInOutQuart,
    Curves.easeInOutQuint,
    Curves.easeInOutExpo,
    Curves.easeInOutCirc,

    // Bounce-back curves (at bottom)
    Curves.easeInBack,
    Curves.easeOutBack,
    Curves.easeInOutBack,
    Curves.bounceIn,
    Curves.bounceOut,
    Curves.bounceInOut,
    Curves.elasticIn,
    Curves.elasticOut,
    Curves.elasticInOut,
  ];

  late List<Curve> _curves;
  late Map<Curve, CheckmarkState> _checkmarkStates;
  late Set<Curve> _removedCurves; // Track curves that were removed

  static const Map<Curve, String> _curveNames = {
    // Basic smooth curves
    Curves.linear: 'linear',
    Curves.ease: 'ease',
    Curves.decelerate: 'decelerate',
    Curves.fastOutSlowIn: 'fastOutSlowIn',
    Curves.slowMiddle: 'slowMiddle',

    // Ease In family
    Curves.easeIn: 'easeIn',
    Curves.easeInSine: 'easeInSine',
    Curves.easeInQuad: 'easeInQuad',
    Curves.easeInCubic: 'easeInCubic',
    Curves.easeInQuart: 'easeInQuart',
    Curves.easeInQuint: 'easeInQuint',
    Curves.easeInExpo: 'easeInExpo',
    Curves.easeInCirc: 'easeInCirc',

    // Ease Out family
    Curves.easeOut: 'easeOut',
    Curves.easeOutSine: 'easeOutSine',
    Curves.easeOutQuad: 'easeOutQuad',
    Curves.easeOutCubic: 'easeOutCubic',
    Curves.easeOutQuart: 'easeOutQuart',
    Curves.easeOutQuint: 'easeOutQuint',
    Curves.easeOutExpo: 'easeOutExpo',
    Curves.easeOutCirc: 'easeOutCirc',

    // Ease In-Out family
    Curves.easeInOut: 'easeInOut',
    Curves.easeInOutSine: 'easeInOutSine',
    Curves.easeInOutQuad: 'easeInOutQuad',
    Curves.easeInOutCubic: 'easeInOutCubic',
    Curves.easeInOutQuart: 'easeInOutQuart',
    Curves.easeInOutQuint: 'easeInOutQuint',
    Curves.easeInOutExpo: 'easeInOutExpo',
    Curves.easeInOutCirc: 'easeInOutCirc',

    // Bounce-back curves
    Curves.easeInBack: 'easeInBack',
    Curves.easeOutBack: 'easeOutBack',
    Curves.easeInOutBack: 'easeInOutBack',
    Curves.bounceIn: 'bounceIn',
    Curves.bounceOut: 'bounceOut',
    Curves.bounceInOut: 'bounceInOut',
    Curves.elasticIn: 'elasticIn',
    Curves.elasticOut: 'elasticOut',
    Curves.elasticInOut: 'elasticInOut',
  };

  @override
  void initState() {
    super.initState();
    _fullReload();
  }

  void _fullReload() {
    // Complete reload - restore all curves and clear everything
    _curves = List.from(_allCurves);
    _removedCurves = <Curve>{};
    _checkmarkStates = {};
    for (final curve in _curves) {
      _checkmarkStates[curve] = CheckmarkState.notDrawn;
    }
  }

  void _clearCheckmarksOnly() {
    // Clear checkmarks but keep removed curves out
    for (final curve in _curves) {
      _checkmarkStates[curve] = CheckmarkState.notDrawn;
    }
  }

  bool get _anyAnimating {
    return _checkmarkStates.values.any(
      (state) =>
          state == CheckmarkState.drawing || state == CheckmarkState.dissolving,
    );
  }

  void _onDurationChanged(double newDuration) {
    setState(() {
      _duration = newDuration;
      // Duration change only clears checkmarks, doesn't restore removed curves
      _clearCheckmarksOnly();
    });
  }

  void _reloadFullList() {
    if (_anyAnimating) return;

    setState(() {
      _fullReload();
    });
  }

  void _toggleCheckmark(Curve curve) {
    if (_anyAnimating) return;

    final currentState = _checkmarkStates[curve]!;

    setState(() {
      switch (currentState) {
        case CheckmarkState.notDrawn:
          _checkmarkStates[curve] = CheckmarkState.drawing;
          break;
        case CheckmarkState.drawn:
          _checkmarkStates[curve] = CheckmarkState.dissolving;
          break;
        case CheckmarkState.drawing:
        case CheckmarkState.dissolving:
          break;
      }
    });
  }

  void _removeCurve(Curve curveToRemove) {
    if (_anyAnimating) return;

    setState(() {
      // Add to removed set and remove from active list
      _removedCurves.add(curveToRemove);
      _curves.remove(curveToRemove);
      _checkmarkStates.remove(curveToRemove);
    });
  }

  void _onAnimationComplete(Curve curve, bool isDrawn) {
    setState(() {
      _checkmarkStates[curve] = isDrawn
          ? CheckmarkState.drawn
          : CheckmarkState.notDrawn;
    });
  }

  Widget _buildCheckmarkRow(Curve curve) {
    final state = _checkmarkStates[curve]!;
    final curveName = _curveNames[curve]!;

    final isVisible =
        state == CheckmarkState.drawn || state == CheckmarkState.dissolving;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Fixed size container to prevent layout jank
          SizedBox(
            width: 70,
            height: 45,
            child: Center(
              child: state == CheckmarkState.notDrawn
                  ? const SizedBox.shrink()
                  : AnimatedCheckbox(
                      width: 45,
                      strokeColor: Colors.purple,
                      draw:
                          state == CheckmarkState.drawing ||
                          state == CheckmarkState.drawn,
                      curve: curve,
                      duration: Duration(
                        milliseconds: (_duration * 1000).round(),
                      ),
                      onAnimationComplete: (isDrawn) =>
                          _onAnimationComplete(curve, isDrawn),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onDoubleTap: () => _removeCurve(curve),
              child: ElevatedButton(
                onPressed: _anyAnimating ? null : () => _toggleCheckmark(curve),
                child: Text(
                  isVisible ? 'Dissolve $curveName' : 'Draw $curveName',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Animation Curve Variations (${_curves.length} curves)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Double-tap button to remove curve from list',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const Gap(20),

          Column(
            children: [
              Text(
                'Duration: ${_duration.toStringAsFixed(1)}s',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              Slider(
                value: _duration,
                min: 0.5,
                max: 3.0,
                divisions: 10,
                onChanged: _anyAnimating ? null : _onDurationChanged,
                label: '${_duration.toStringAsFixed(1)}s',
              ),
              const Gap(12),
              ElevatedButton(
                onPressed: _anyAnimating ? null : _reloadFullList,
                child: const Text('Reload List'),
              ),
            ],
          ),

          const Gap(20),

          Expanded(
            child: SizedBox(
              width: 500,
              child: ListView.builder(
                itemCount: _curves.length,
                itemBuilder: (context, index) {
                  return _buildCheckmarkRow(_curves[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ***************************************************************************

// Interactive demo widget with custom parameters
class _InteractiveCheckboxDemo extends StatefulWidget {
  const _InteractiveCheckboxDemo();

  @override
  State<_InteractiveCheckboxDemo> createState() =>
      _InteractiveCheckboxDemoState();
}

class _InteractiveCheckboxDemoState extends State<_InteractiveCheckboxDemo> {
  bool _shouldDraw = true;
  String _status = 'Ready';
  bool _isAnimating = false;
  int _shapeIndex = 0;

  final List<({Offset start, Offset mid, Offset finish, String name})> _shapes =
      [
        (
          start: Offset(0.0, 0.5),
          mid: Offset(0.5, 1.0),
          finish: Offset(1.0, 0.0),
          name: 'Default',
        ),
        (
          start: Offset(0.2, 0.5),
          mid: Offset(0.4, 0.8),
          finish: Offset(0.8, 0.2),
          name: 'Compact',
        ),
        (
          start: Offset(0.0, 0.3),
          mid: Offset(0.6, 0.9),
          finish: Offset(1.0, 0.1),
          name: 'Wide',
        ),
        (
          start: Offset(0.0, 0.0),
          mid: Offset(0.5, 0.5),
          finish: Offset(1.0, 1.0),
          name: 'Diagonal',
        ),
      ];

  void _toggleAnimation() {
    if (_isAnimating) return; // Prevent multiple animations

    setState(() {
      _shouldDraw = !_shouldDraw;
      _isAnimating = true;
      _status = _shouldDraw ? 'Drawing...' : 'Dissolving...';
    });
  }

  void _changeShape() {
    if (_isAnimating) return; // Prevent shape change during animation

    setState(() {
      _shapeIndex = (_shapeIndex + 1) % _shapes.length;
    });
  }

  void _onAnimationComplete(bool isDrawn) {
    setState(() {
      _isAnimating = false;
      _status = isDrawn ? 'Draw Complete' : 'Dissolve Complete';
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentShape = _shapes[_shapeIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Interactive Demo with Custom Shapes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(20),
          AnimatedCheckbox(
            width: 150,
            strokeColor: Colors.deepPurple,
            draw: _shouldDraw,
            startOffset: currentShape.start,
            midOffset: currentShape.mid,
            finishOffset: currentShape.finish,
            curve: Curves.easeInQuart,
            duration: const Duration(milliseconds: 1500),
            onAnimationComplete: _onAnimationComplete,
          ),
          const Gap(20),
          Text(
            'Shape: ${currentShape.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Status: $_status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isAnimating) ...[
                ElevatedButton(
                  onPressed: _toggleAnimation,
                  child: Text(_shouldDraw ? 'Start Dissolve' : 'Start Draw'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _changeShape,
                  child: const Text('Change Shape'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _status,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Dissolve demo widget with custom shape
class _DissolveDemo extends StatefulWidget {
  const _DissolveDemo();

  @override
  State<_DissolveDemo> createState() => _DissolveDemoState();
}

class _DissolveDemoState extends State<_DissolveDemo> {
  bool _isDissolving = false;
  String _status = 'Ready to dissolve';

  void _startDissolve() {
    if (_isDissolving) return;

    setState(() {
      _isDissolving = true;
      _status = 'Dissolving...';
    });
  }

  void _onDissolveComplete(bool isDrawn) {
    setState(() {
      _isDissolving = false;
      _status = isDrawn ? 'Drawn' : 'Dissolved';
    });

    // Auto-restart after dissolve completes
    if (!isDrawn) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _status = 'Ready to dissolve';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dissolve Effect with Custom Shape',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(20),
          GestureDetector(
            onTap: _isDissolving ? null : _startDissolve,
            child: AnimatedCheckbox(
              width: 150,
              strokeColor: Colors.deepOrange,
              draw: false, // Always dissolve
              startOffset: const Offset(0.0, 0.3),
              midOffset: const Offset(0.6, 0.9),
              finishOffset: const Offset(1.0, 0.1),
              curve: Curves.easeInQuart,
              duration: const Duration(milliseconds: 2000),
              onAnimationComplete: _onDissolveComplete,
            ),
          ),
          const Gap(20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isDissolving
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Gap(16),
          if (!_isDissolving && _status == 'Ready to dissolve')
            Text(
              'Tap the wide checkmark to see dissolve effect',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
