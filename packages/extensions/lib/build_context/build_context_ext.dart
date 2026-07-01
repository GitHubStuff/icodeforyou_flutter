import 'package:extensions/enum/enum.dart' show WindowSizeCategory;
import 'package:flutter/widgets.dart';

/// Convenience accessors on [BuildContext] for keyboard state, render-box
/// geometry, and Material window-size resolution.
extension BuildContextExt on BuildContext {
  /// Whether the on-screen keyboard is currently insetting the view.
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Dismisses the on-screen keyboard when this context holds focus but is not
  /// the primary focus; otherwise does nothing.
  void hideKeyboard() {
    final focus = FocusScope.of(this);
    if (!focus.hasPrimaryFocus) focus.unfocus();
  }

  /// The bounds of this context's render box in its own coordinate space, or
  /// `null` when no [RenderBox] is attached.
  Rect? widgetBounds() {
    final box = findRenderObject();
    return box is RenderBox ? box.semanticBounds : null;
  }

  /// The global offset of this context's render-box origin, or `null` when no
  /// [RenderBox] is attached.
  Offset? widgetGlobalOffset() {
    final box = findRenderObject();
    return box is RenderBox ? box.localToGlobal(Offset.zero) : null;
  }

  /// The [WindowSizeCategory] for the current layout width.
  ///
  /// Resolution selects the first category whose [WindowSizeCategory.upperBound]
  /// strictly exceeds the available width; the widest category uses
  /// [double.infinity], so every width resolves to exactly one category.
  WindowSizeCategory get windowSizeCategory {
    final width = MediaQuery.sizeOf(this).width;
    return WindowSizeCategory.values.firstWhere((c) => width < c.upperBound);
  }
}
