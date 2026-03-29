// animated_widgets/lib/src/contextual_reveal/contextual_position.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart'
    show ContextualReveal;

/// Controls how the [ContextualReveal] doubleChild is presented.
enum ContextualPosition {
  /// The child is displayed adjacent to the parent as an interactive overlay.
  popover,

  /// The child is displayed as a full-screen modal dialog.
  modal,

  /// The child is displayed as a modal bottom sheet.
  bottomSheet,

  /// The child is pushed onto the navigation stack.
  push,
}
