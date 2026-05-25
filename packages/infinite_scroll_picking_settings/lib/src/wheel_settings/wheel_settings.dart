// infinite_scroll_picking_settings/lib/src/wheel_settings/wheel_settings.dart

// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

import '../json/duration_json_converter.dart';

part 'wheel_settings.freezed.dart';
part 'wheel_settings.g.dart';

/// Persistable mirror of `InfiniteScrollWheelConfig` from the
/// `infinite_scroll_picking` package.
///
/// Carries identical fields with identical defaults and asserts. The
/// `infinite_scroll_picking` package's wheel config is a plain immutable
/// class with no JSON support; this type adds JSON serialization so it can
/// round-trip through user-preferences storage. A mapper in this package
/// converts between the two at the boundary.
///
/// [Duration] fields round-trip through [DurationJsonConverter] as
/// microseconds.
///
@freezed
@DurationJsonConverter()
abstract class WheelSettings with _$WheelSettings {
  @Assert(
    'wheelHeight >= itemExtent * 1.1',
    'wheelHeight must be at least 1.1x itemExtent to leave room for the '
        'selection band and fade.',
  )
  @Assert('magnification >= 1.0', 'magnification must be >= 1.0')
  @Assert('perspectiveDiameter > 0', 'perspectiveDiameter must be > 0')
  @Assert('dividerThickness >= 0', 'dividerThickness must be >= 0')
  @Assert('dividerInset >= 0', 'dividerInset must be >= 0')
  const factory WheelSettings({
    /// Height of a single item slot inside the wheel.
    @Default(24.0) double itemExtent,

    /// Thickness of the top and bottom selection band lines.
    @Default(1.0) double dividerThickness,

    /// Horizontal inset of the selection band lines from the wheel edges.
    @Default(4.0) double dividerInset,

    /// Width of the wheel column.
    @Default(56.0) double wheelWidth,

    /// Total height of the wheel (must accommodate the magnified center
    /// item plus fade gradient at top and bottom).
    @Default(48.0) double wheelHeight,

    /// `ListWheelScrollView.diameterRatio` — controls the 3D perspective.
    /// Larger values make the wheel appear flatter; smaller values make
    /// it appear more curved.
    @Default(1.2) double perspectiveDiameter,

    /// Scale factor applied to the centered (selected) item.
    @Default(1.25) double magnification,

    /// Corner radius of the wheel's container.
    @Default(8.0) double wheelBorderRadius,

    /// Whether to draw a border around the wheel container.
    @Default(true) bool showBorder,

    /// Debounce window for the picker's `onItemSelected` callback.
    ///
    /// Defaults to [Duration.zero], which fires the callback synchronously
    /// on every tick. Set to a non-zero duration to coalesce rapid scroll
    /// changes — useful when the consumer performs expensive work in the
    /// callback.
    @Default(Duration.zero) Duration selectionDebounce,
  }) = _WheelSettings;

  /// Creates a [WheelSettings] from a JSON map.
  factory WheelSettings.fromJson(Map<String, dynamic> json) =>
      _$WheelSettingsFromJson(json);
}
