// packages/sincewhen_widgets/lib/src/glossary_edits/cubit/glossary_edit_state.dart
import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter/widgets.dart' show Color;

/// The base state for the glossary editing feature.
///
/// This is a sealed class that represents the different UI states emitted
/// by the glossary edit logic.
sealed class GlossaryEditState extends Equatable {
  /// Initializes the base glossary edit state.
  const GlossaryEditState();
}

/// The initial state before any user interaction occurs.
final class GlossaryEditInitial extends GlossaryEditState {
  /// Creates a [GlossaryEditInitial] state.
  const GlossaryEditInitial();

  @override
  List<Object?> get props => [];
}

/// Indicates that the user has requested to select or change a color.
final class GlossaryEditColorRequest extends GlossaryEditState {
  /// Creates a [GlossaryEditColorRequest] state.
  const GlossaryEditColorRequest();

  @override
  List<Object?> get props => [];
}

/// Represents a state where a list of available colors is provided.
///
/// This state is typically emitted in response to a color selection
/// request, providing the UI with the options to display.
final class GlossaryEditColorList extends GlossaryEditState {
  /// Creates a [GlossaryEditColorList] state with the given [colorList].
  const GlossaryEditColorList(this.colorList);

  /// The list of available colors for the user to choose from.
  final List<Color> colorList;

  @override
  List<Object?> get props => [colorList];
}

/// The state where the user has a chance to create a glossary edit by adding
/// a description and tag name for an glossary item/.
final class GlossaryEditPopover extends GlossaryEditState {
  /// Creates a [GlossaryEditPopover] state to create an glossary item
  const GlossaryEditPopover(this.colorArgb, this.timestamp);

  /// provide the editor the color the user selected from a picker
  final int colorArgb;

  /// Use a unique timestamp as the key in the drift/sql database
  final int timestamp;

  @override
  List<Object?> get props => [colorArgb, timestamp];
}
