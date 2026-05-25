// lib/src/infinite_scroll_wheel_config.dart

// ignore_for_file: comment_references, public_member_api_docs

part of 'library.dart';

/// Visual and behavioral configuration for the infinite scroll wheel inside
/// an [InfiniteScrollPicker].
///
/// Controls wheel dimensions, the 3D perspective effect, the selection
/// dividers, and how the wheel reports selection changes upstream.
@immutable
class InfiniteScrollWheelConfig {
  const InfiniteScrollWheelConfig({
    this.itemExtent = 24.0,
    this.dividerThickness = 1.0,
    this.dividerInset = 4.0,
    this.wheelWidth = 56.0,
    this.wheelHeight = 48.0,
    this.perspectiveDiameter = 1.2,
    this.magnification = 1.25,
    this.wheelBorderRadius = 8.0,
    this.showBorder = true,
    this.selectionDebounce = Duration.zero,
  }) : assert(
         wheelHeight >= itemExtent * 1.1,
         'wheelHeight ($wheelHeight) must be at least 1.1x itemExtent '
         '($itemExtent) to leave room for the selection band and fade.',
       ),
       assert(
         magnification >= 1.0,
         'magnification ($magnification) must be >= 1.0',
       ),
       assert(
         perspectiveDiameter > 0,
         'perspectiveDiameter ($perspectiveDiameter) must be > 0',
       ),
       assert(
         dividerThickness >= 0,
         'dividerThickness ($dividerThickness) must be >= 0',
       ),
       assert(dividerInset >= 0, 'dividerInset ($dividerInset) must be >= 0');

  /// Height of a single item slot inside the wheel.
  final double itemExtent;

  /// Thickness of the top and bottom selection band lines.
  final double dividerThickness;

  /// Horizontal inset of the selection band lines from the wheel edges.
  final double dividerInset;

  /// Width of the wheel column.
  final double wheelWidth;

  /// Total height of the wheel (must accommodate the magnified center item
  /// plus fade gradient at top and bottom).
  final double wheelHeight;

  /// `ListWheelScrollView.diameterRatio` — controls the 3D perspective.
  /// Larger values make the wheel appear flatter; smaller values make it
  /// appear more curved.
  final double perspectiveDiameter;

  /// Scale factor applied to the centered (selected) item.
  final double magnification;

  /// Corner radius of the wheel's container.
  final double wheelBorderRadius;

  /// Whether to draw a border around the wheel container.
  final bool showBorder;

  /// Debounce window for the picker's `onItemSelected` callback.
  ///
  /// Defaults to [Duration.zero], which fires the callback synchronously on
  /// every tick (matching `ListWheelScrollView`'s native cadence). Set to a
  /// non-zero duration to coalesce rapid scroll changes — useful when the
  /// consumer performs expensive work in the callback.
  final Duration selectionDebounce;

  /// Returns a copy with the given fields replaced.
  ///
  /// Useful when settings UI needs to nudge a single field without
  /// reassembling the whole config — common during slider drag previews
  /// where the cubit holds a working copy of the wheel config and emits
  /// new states by replacing one value at a time.
  InfiniteScrollWheelConfig copyWith({
    double? itemExtent,
    double? dividerThickness,
    double? dividerInset,
    double? wheelWidth,
    double? wheelHeight,
    double? perspectiveDiameter,
    double? magnification,
    double? wheelBorderRadius,
    bool? showBorder,
    Duration? selectionDebounce,
  }) {
    return InfiniteScrollWheelConfig(
      itemExtent: itemExtent ?? this.itemExtent,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerInset: dividerInset ?? this.dividerInset,
      wheelWidth: wheelWidth ?? this.wheelWidth,
      wheelHeight: wheelHeight ?? this.wheelHeight,
      perspectiveDiameter: perspectiveDiameter ?? this.perspectiveDiameter,
      magnification: magnification ?? this.magnification,
      wheelBorderRadius: wheelBorderRadius ?? this.wheelBorderRadius,
      showBorder: showBorder ?? this.showBorder,
      selectionDebounce: selectionDebounce ?? this.selectionDebounce,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InfiniteScrollWheelConfig &&
          runtimeType == other.runtimeType &&
          itemExtent == other.itemExtent &&
          dividerThickness == other.dividerThickness &&
          dividerInset == other.dividerInset &&
          wheelWidth == other.wheelWidth &&
          wheelHeight == other.wheelHeight &&
          perspectiveDiameter == other.perspectiveDiameter &&
          magnification == other.magnification &&
          wheelBorderRadius == other.wheelBorderRadius &&
          showBorder == other.showBorder &&
          selectionDebounce == other.selectionDebounce;

  @override
  int get hashCode => Object.hash(
    itemExtent,
    dividerThickness,
    dividerInset,
    wheelWidth,
    wheelHeight,
    perspectiveDiameter,
    magnification,
    wheelBorderRadius,
    showBorder,
    selectionDebounce,
  );
}
