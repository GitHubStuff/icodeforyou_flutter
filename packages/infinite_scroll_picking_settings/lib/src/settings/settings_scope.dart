// infinite_scroll_picking_settings/lib/src/settings/settings_scope.dart

// ignore_for_file: always_use_package_imports

import 'package:flutter/widgets.dart';

import '../picker_visual_settings/picker_visual_settings.dart';
import 'settings_holder.dart';

/// Provides a [SettingsHolder] to descendant widgets and rebuilds dependents
/// when the holder's value changes.
///
/// Place this once near the root of the app (typically just under
/// `MaterialApp`), wrapping the [SettingsHolder] returned by
/// `SettingsLoader.load`:
///
/// ```dart
/// final holder = await SettingsLoader.load(repository: repo);
/// runApp(SettingsScope(holder: holder, child: const MyApp()));
/// ```
///
/// Descendants read the holder two ways:
///
/// - [SettingsScope.of] — returns the holder without subscribing. Use inside
///   callbacks or when only the holder identity is needed.
/// - [SettingsScope.watch] — returns the current [PickerVisualSettings] and
///   subscribes the caller to rebuilds. Use in `build` methods that need to
///   react to setting changes.
class SettingsScope extends InheritedNotifier<SettingsHolder> {
  /// Creates a scope providing [holder] to [child] and its descendants.
  const SettingsScope({
    required SettingsHolder holder,
    required super.child,
    super.key,
  }) : super(notifier: holder);

  /// Returns the [SettingsHolder] from the nearest enclosing [SettingsScope]
  /// without subscribing the calling widget to rebuilds.
  ///
  /// Throws [FlutterError] if no [SettingsScope] is found in the ancestor
  /// chain — settings access without a scope is a wiring bug.
  static SettingsHolder of(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<SettingsScope>();
    final scope = element?.widget as SettingsScope?;
    final holder = scope?.notifier;
    if (holder == null) {
      throw FlutterError(
        'SettingsScope.of() called with a context that does not contain a '
        'SettingsScope.\n'
        'Wrap your app (typically just under MaterialApp) with a '
        'SettingsScope before reading settings:\n'
        '  SettingsScope(holder: holder, child: const MyApp())',
      );
    }
    return holder;
  }

  /// Returns the current [PickerVisualSettings] from the nearest enclosing
  /// [SettingsScope] and subscribes the calling widget to rebuilds.
  ///
  /// Throws [FlutterError] if no [SettingsScope] is found in the ancestor
  /// chain — settings access without a scope is a wiring bug.
  static PickerVisualSettings watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    final holder = scope?.notifier;
    if (holder == null) {
      throw FlutterError(
        'SettingsScope.watch() called with a context that does not contain '
        'a SettingsScope.\n'
        'Wrap your app (typically just under MaterialApp) with a '
        'SettingsScope before reading settings:\n'
        '  SettingsScope(holder: holder, child: const MyApp())',
      );
    }
    return holder.value;
  }
}
