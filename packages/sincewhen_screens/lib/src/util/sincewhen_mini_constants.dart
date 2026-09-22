// packages/sincewhen_screens/lib/src/util/sincewhen_mini_constants.dart

/// {@template since_when_mini_dimensions}
/// Every layout number used by the since-when-mini screen, named.
///
/// The screen targets an iPad mini in landscape (≈1133 × 744 logical
/// pixels). Centralizing the numbers keeps the widgets literal-free and
/// gives a future small-screen variant one place to retune.
/// {@endtemplate}
final class SinceWhenMiniDimensions {
  const SinceWhenMiniDimensions._();

  // ── Screen chrome ────────────────────────────────────────────────

  /// Padding around the entire screen body.
  static const double screenPadding = 16;

  // ── Two-column body ──────────────────────────────────────────────

  /// Horizontal gap between the timestamp and text columns.
  static const double columnGap = 24;

  /// Flex weight of the timestamp (left) column.
  static const int timestampColumnFlex = 2;

  /// Flex weight of the text (right) column.
  static const int textColumnFlex = 3;

  // ── Timestamp column ─────────────────────────────────────────────

  /// Vertical gap between timestamp rows.
  static const double timestampRowGap = 16;

  /// Vertical gap between a row's label and its value.
  static const double labelValueGap = 4;

  // ── Event picker field ───────────────────────────────────────────

  /// Vertical padding inside the event picker field.
  static const double eventFieldVerticalPadding = 8;

  /// Horizontal padding inside the event picker field.
  static const double eventFieldHorizontalPadding = 12;

  /// Corner radius of the event picker field border.
  static const double eventFieldBorderRadius = 4;

  // ── Text column ──────────────────────────────────────────────────

  /// Vertical gap between the text fields.
  static const double textFieldGap = 12;

  /// Minimum visible lines of the content field.
  static const int contentMinLines = 3;

  /// Maximum visible lines of the content field before it scrolls.
  static const int contentMaxLines = 12;

  /// Minimum visible lines of the tldr and metadata fields.
  static const int optionalFieldMinLines = 1;

  /// Maximum visible lines of the tldr and metadata fields before
  /// they scroll.
  static const int optionalFieldMaxLines = 1;

  // ── Action bar ───────────────────────────────────────────────────

  /// Vertical gap between the body and the action bar.
  static const double actionBarTopGap = 12;

  /// Horizontal gap between the Cancel and primary buttons.
  static const double actionBarButtonGap = 16;
}
