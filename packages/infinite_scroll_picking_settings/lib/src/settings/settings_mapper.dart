// infinite_scroll_picking_settings/lib/src/settings/settings_mapper.dart

// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

import '../picker_visual_settings/picker_visual_settings.dart';
import '../wheel_settings/wheel_settings.dart';

/// Conversion between this package's persistable settings types and the
/// runtime config types owned by the `infinite_scroll_picking` package.
///
/// The boundary lives here so neither side has to know about the other:
/// the picker package stays JSON-free, and the settings package stays free
/// of runtime concerns like generic `<T, K>` parameters and `items` lists.
extension WheelSettingsMapper on WheelSettings {
  /// Build the picker package's runtime [InfiniteScrollWheelConfig] from
  /// these settings. Field-for-field copy.
  InfiniteScrollWheelConfig toWheelConfig() {
    return InfiniteScrollWheelConfig(
      itemExtent: itemExtent,
      dividerThickness: dividerThickness,
      dividerInset: dividerInset,
      wheelWidth: wheelWidth,
      wheelHeight: wheelHeight,
      perspectiveDiameter: perspectiveDiameter,
      magnification: magnification,
      wheelBorderRadius: wheelBorderRadius,
      showBorder: showBorder,
      selectionDebounce: selectionDebounce,
    );
  }
}

/// Reverse mapper — useful when seeding settings from an existing runtime
/// config (e.g. when a consumer already has an `InfiniteScrollWheelConfig`
/// hard-coded somewhere and wants it to become the default settings).
extension WheelConfigMapper on InfiniteScrollWheelConfig {
  WheelSettings toWheelSettings() {
    return WheelSettings(
      itemExtent: itemExtent,
      dividerThickness: dividerThickness,
      dividerInset: dividerInset,
      wheelWidth: wheelWidth,
      wheelHeight: wheelHeight,
      perspectiveDiameter: perspectiveDiameter,
      magnification: magnification,
      wheelBorderRadius: wheelBorderRadius,
      showBorder: showBorder,
      selectionDebounce: selectionDebounce,
    );
  }
}

extension PickerVisualSettingsMapper on PickerVisualSettings {
  /// Build a runtime [InfiniteScrollPickerConfig] from these settings plus
  /// the runtime-only [items] and [pickerId].
  ///
  /// The picker config asserts `items` is non-empty and `startingIndex <
  /// items.length` — both are enforced here at the boundary, since the
  /// settings type can't see [items].
  InfiniteScrollPickerConfig<T, K> toPickerConfig<T, K>({
    required List<T> items,
    required K pickerId,
  }) {
    assert(items.isNotEmpty, 'items must not be empty');
    assert(
      startingIndex < items.length,
      'startingIndex ($startingIndex) must be < items.length '
      '(${items.length})',
    );
    return InfiniteScrollPickerConfig<T, K>(
      items: items,
      pickerId: pickerId,
      startingIndex: startingIndex,
      wheelConfig: wheel.toWheelConfig(),
      frameBorderRadius: frameBorderRadius,
      frameHorizontalPadding: frameHorizontalPadding,
      frameVerticalPadding: frameVerticalPadding,
    );
  }
}
