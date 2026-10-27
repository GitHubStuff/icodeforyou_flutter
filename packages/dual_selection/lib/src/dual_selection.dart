// packages/dual_selection/lib/src/dual_selection.dart

import 'package:flutter/widgets.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

import 'defaults.dart';
import 'dual_selection_enum.dart';

/// A fixed-size, two-button selector.
///
/// [first] and [second] split the header row evenly: each is laid out to
/// exactly `width / 2` by [headerHeight] and is responsible for its own
/// alignment, padding and foreground colours. Tapping one selects it: the
/// widget fires [haptic], reports the new value through
/// [onSelectionChanged], and cross-fades the body from the outgoing child to
/// the incoming one over [fadeDuration].
///
/// The header background is owned by the widget so it can reflect the
/// current selection: the selected slot is painted [selectedHeaderColor]
/// and the other slot [unselectedHeaderColor]. Either may be `null`, in
/// which case that slot paints no background and the content behind the
/// widget shows through. Callers that need theme-awareness pass colours
/// derived from their theme; this package deliberately has no Material
/// dependency and never picks a colour itself.
///
/// [firstChild] and [secondChild] are each laid out to exactly [width] by
/// [bodyHeight], so children that need bounded constraints (pickers,
/// scrollables) work without extra wrapping.
///
/// Tapping the already-selected button is a no-op: no haptic, no callback,
/// no animation.
///
/// The widget is uncontrolled. [selection] seeds the initial state; the
/// widget owns it from then on.
///
/// The content area is [width] wide and `headerHeight + bodyHeight` tall;
/// the border of [borderWidth] is drawn around that area, so the rendered
/// size is larger by `2 * borderWidth` in each dimension.
class DualSelection extends StatefulWidget {
  /// Creates a [DualSelection].
  const DualSelection({
    required this.first,
    required this.second,
    required this.firstChild,
    required this.secondChild,
    required this.borderColor,
    this.selectedHeaderColor,
    this.unselectedHeaderColor,
    this.selection = Defaults.kFirstSelection,
    this.fadeDuration = Defaults.kFadeDuration,
    this.cornerRadius = Defaults.kCornerRadius,
    this.haptic = Defaults.kHaptic,
    this.borderWidth = Defaults.kBorderWidth,
    this.headerHeight = Defaults.kHeaderHeight,
    this.bodyHeight = Defaults.kBodyHeight,
    this.width = Defaults.kWidth,
    this.onSelectionChanged,
    super.key,
  }) : assert(cornerRadius >= 0, 'cornerRadius must not be negative'),
       assert(borderWidth >= 0, 'borderWidth must not be negative'),
       assert(headerHeight > 0, 'headerHeight must be positive'),
       assert(bodyHeight > 0, 'bodyHeight must be positive'),
       assert(width > 0, 'width must be positive');

  /// Content of the left header button. Fills `width / 2` × [headerHeight].
  final Widget first;

  /// Content of the right header button. Fills `width / 2` × [headerHeight].
  final Widget second;

  /// Body shown while [DualSelectionEnum.first] is selected.
  /// Fills [width] × [bodyHeight].
  final Widget firstChild;

  /// Body shown while [DualSelectionEnum.second] is selected.
  /// Fills [width] × [bodyHeight].
  final Widget secondChild;

  /// Colour of the outer border.
  final Color borderColor;

  /// Background painted behind the currently selected header button.
  /// `null` paints nothing.
  final Color? selectedHeaderColor;

  /// Background painted behind the header button that is not selected.
  /// `null` paints nothing.
  final Color? unselectedHeaderColor;

  /// Initial selection. The widget owns the value after first build.
  final DualSelectionEnum selection;

  /// Length of the body cross-fade.
  final Duration fadeDuration;

  /// Radius of the outer border's corners.
  final double cornerRadius;

  /// Haptic fired when the selection changes.
  final HapticIntensity haptic;

  /// Stroke width of the outer border.
  final double borderWidth;

  /// Height of the header row. Each button is this tall.
  final double headerHeight;

  /// Height of the body area.
  final double bodyHeight;

  /// Width of the content area. Each header button is half this wide.
  final double width;

  /// Called with the new value only when the selection actually changes.
  final ValueChanged<DualSelectionEnum>? onSelectionChanged;

  @override
  State<DualSelection> createState() => _DualSelectionState();
}

class _DualSelectionState extends State<DualSelection> {
  late DualSelectionEnum _selection = widget.selection;

  CrossFadeState get _crossFadeState => switch (_selection) {
    DualSelectionEnum.first => CrossFadeState.showFirst,
    DualSelectionEnum.second => CrossFadeState.showSecond,
  };

  /// Inner clip radius so the body corners sit flush inside the border.
  double get _innerRadius =>
      (widget.cornerRadius - widget.borderWidth).clamp(0, double.infinity);

  void _select(DualSelectionEnum selection) {
    if (selection == _selection) return;

    widget.haptic.trigger();
    widget.onSelectionChanged?.call(selection);
    setState(() => _selection = selection);
  }

  /// Background for the header slot representing [selection], or `null`
  /// when the caller supplied no colour for that state.
  Color? _headerColorFor(DualSelectionEnum selection) => selection == _selection
      ? widget.selectedHeaderColor
      : widget.unselectedHeaderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(widget.cornerRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_innerRadius),
          child: SizedBox(
            width: widget.width,
            height: widget.headerHeight + widget.bodyHeight,
            child: Column(
              children: [
                _buildHeader(),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: widget.headerHeight,
      child: Row(
        children: [
          _buildHeaderButton(
            selection: .first,
            child: widget.first,
          ),
          _buildHeaderButton(
            selection: .second,
            child: widget.second,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required DualSelectionEnum selection,
    required Widget child,
  }) {
    final color = _headerColorFor(selection);
    final content = SizedBox.expand(child: child);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(selection),
        child: color == null
            ? content
            : ColoredBox(color: color, child: content),
      ),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: widget.bodyHeight,
      width: widget.width,
      child: AnimatedCrossFade(
        firstChild: _buildBodyChild(widget.firstChild),
        secondChild: _buildBodyChild(widget.secondChild),
        crossFadeState: _crossFadeState,
        duration: widget.fadeDuration,
      ),
    );
  }

  /// Pins a body child to the body's exact size so it receives bounded
  /// constraints inside [AnimatedCrossFade]'s loose stack.
  Widget _buildBodyChild(Widget child) {
    return SizedBox(
      width: widget.width,
      height: widget.bodyHeight,
      child: child,
    );
  }
}
