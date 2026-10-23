// programs/black_velvet/lib/app_dock_navigation/dock_button_sizes.dart
import 'package:flutter/widgets.dart' show Size;

/// Size of Dock/horizontal buttons needs to be tightly controlled
/// to prevent overflows on-layouts. These are the sizes for best use.
/// This not an enum to allow for the user to override if they REALLY need
abstract class DockButtonSize {
  /// Size best for phone/small screen
  static const Size defaultSize = Size(80, 60);

  /// Good option for tablets
  static const Size medium = Size(100, 80);

  /// Option for large monitors/screens
  static const Size large = Size(120, 100);
}
