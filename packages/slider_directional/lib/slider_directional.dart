// packages/slider_directional/lib/slider_directional.dart
// ignore_for_file: comment_references

/// A directional (horizontal or vertical) slider widget that snaps to a
/// configurable step grid, with optional haptic feedback on step crossings.
///
/// Public API:
/// - [Directional]: the slider widget.
/// - [DirectionalController]: holds the current value; pass to [Directional]
///   to drive its state externally without rebuilding the parent widget.
/// - [SliderDirection]: encodes both axis and origin (which end holds the
///   minimum value) in a single value.
/// - [StepGrid]: the immutable grid description (validation, snapping,
///   indexing) used internally by [Directional] and exposed for callers that
///   want to share or precompute grid math.
library;

export 'src/directional.dart' show Directional;
export 'src/directional_controller.dart' show DirectionalController;
export 'src/slider_direction.dart' show SliderDirection;
export 'src/step_grid.dart' show StepGrid;
