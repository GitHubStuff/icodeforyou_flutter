// infinite_scroll_picking_settings/lib/src/picker_visual_settings/picker_visual_settings.dart

// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:freezed_annotation/freezed_annotation.dart';

import '../wheel_settings/wheel_settings.dart';

part 'picker_visual_settings.freezed.dart';
part 'picker_visual_settings.g.dart';

/// The persistable visual configuration for an `InfiniteScrollPicker`.
///
/// Carries everything that defines how a picker *looks* and *behaves* —
/// frame paddings, frame corner radius, the embedded [WheelSettings], and
/// the [startingIndex] to land on. It does **not** carry `items` or
/// `pickerId`; those are runtime concerns owned by the consumer and have
/// no business in a JSON-serialized preference.
///
/// This is the type that round-trips through user-preferences storage. A
/// mapper in this package converts an instance of this class plus
/// runtime-only `items` and `pickerId` into an
/// `InfiniteScrollPickerConfig<T, K>` for the picker package to consume.
@freezed
abstract class PickerVisualSettings with _$PickerVisualSettings {
  @Assert('startingIndex >= 0', 'startingIndex must be >= 0')
  @Assert('frameBorderRadius >= 0', 'frameBorderRadius must be >= 0')
  @Assert(
    'frameHorizontalPadding >= 0',
    'frameHorizontalPadding must be >= 0',
  )
  @Assert('frameVerticalPadding >= 0', 'frameVerticalPadding must be >= 0')
  const factory PickerVisualSettings({
    /// Visual and behavioral configuration for the wheel itself.
    @Default(WheelSettings()) WheelSettings wheel,

    /// Index in the consumer-supplied `items` list to land on when the
    /// picker first builds. Bounds-checked against `items.length` by the
    /// mapper at runtime, since `items` doesn't live here.
    @Default(0) int startingIndex,

    /// Corner radius of the outer frame surrounding the label and wheel.
    @Default(8.0) double frameBorderRadius,

    /// Horizontal padding inside the outer frame.
    @Default(12.0) double frameHorizontalPadding,

    /// Vertical padding inside the outer frame.
    @Default(6.0) double frameVerticalPadding,
  }) = _PickerVisualSettings;

  /// Creates a [PickerVisualSettings] from a JSON map.
  factory PickerVisualSettings.fromJson(Map<String, dynamic> json) =>
      _$PickerVisualSettingsFromJson(json);
}
