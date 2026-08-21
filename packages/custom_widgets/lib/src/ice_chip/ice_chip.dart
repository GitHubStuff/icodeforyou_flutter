// packages/custom_widgets/lib/src/ice_chip/ice_chip.dart
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';

/// A stadium-shaped, tappable chip built on [FilterChip].
///
/// [IceChip] is a stateless presentation widget: it never tracks selection
/// state itself. Every tap simply fires [onPress], and the underlying
/// [FilterChip] is pinned to `selected: false` with the checkmark hidden, so
/// the chip always renders in a single, predictable visual state.
///
/// The chip's border color is theme-aware and resolved at build time:
/// white in dark mode, black in light mode. Because resolution happens in
/// [build], the chip reacts correctly to live theme changes without any
/// caller involvement.
///
/// Two construction modes are available:
///
///  * [IceChip.new] — supply any [Widget] as the chip's label content.
///  * [IceChip.text] — supply a plain [String]; the chip builds an
///    upper-cased [Text] whose color matches the theme-aware border color.
///
/// Example:
///
/// ```dart
/// // Arbitrary widget content.
/// IceChip(
///   const Icon(Icons.ac_unit),
///   backgroundColor: Colors.lightBlue.shade100,
///   showBorder: true,
///   onPress: () => debugPrint('brrr'),
/// );
///
/// // String content, auto-styled to match the border.
/// IceChip.text(
///   'Vanilla',
///   backgroundColor: Colors.lightBlue.shade100,
///   showBorder: false,
///   onPress: () => debugPrint('tapped'),
/// );
/// ```
class IceChip extends StatelessWidget {
  /// Creates an [IceChip] whose label content is an arbitrary [Widget].
  ///
  /// The positional [child] is declared as `Widget this.child`, which
  /// tightens the nullable field [IceChip.child] to non-nullable for this
  /// constructor: callers cannot pass `null`, and the analyzer enforces it
  /// at compile time.
  ///
  /// The private label field is initialized to `null`, establishing the
  /// class invariant that exactly one of [child] / `_label` is non-null.
  const IceChip(
    Widget this.child, {
    required this.backgroundColor,
    required this.showBorder,
    required this.onPress,
    super.key,
  }) : _label = null;

  /// Creates an [IceChip] from a plain [String] label.
  ///
  /// The [label] is stored, not converted to a [Text] here, because the
  /// text color depends on [BuildContext] (theme brightness) which does not
  /// exist at construction time. Instead, [build] creates the [Text] lazily
  /// with:
  ///
  ///  * the label upper-cased via [String.toUpperCase], and
  ///  * a [TextStyle.color] equal to the theme-aware border color, so text
  ///    and border always match — in both light and dark mode.
  ///
  /// [child] is initialized to `null`, upholding the invariant that exactly
  /// one of [child] / `_label` is non-null.
  const IceChip.text(
    String label, {
    required this.backgroundColor,
    required this.showBorder,
    required this.onPress,
    super.key,
  }) : _label = label,
       child = null;

  /// The widget rendered as the chip's label content.
  ///
  /// Non-null when constructed via [IceChip.new]; `null` when constructed
  /// via [IceChip.text], in which case a themed, upper-cased [Text] built
  /// from `_label` is used instead.
  final Widget? child;

  /// The raw string label supplied to [IceChip.text].
  ///
  /// `null` when constructed via [IceChip.new]. When non-null, [build]
  /// upper-cases it and wraps it in a [Text] colored to match the
  /// theme-aware border color.
  final String? _label;

  /// The fill color of the chip.
  ///
  /// Applied to both [FilterChip.backgroundColor] and
  /// [FilterChip.selectedColor] so the fill is identical regardless of the
  /// underlying chip's internal selected/unselected rendering paths.
  final Color backgroundColor;

  /// Whether the chip draws its theme-aware border.
  ///
  /// When `true`, a 3-logical-pixel border is drawn in white (dark mode) or
  /// black (light mode). When `false`, the border side is painted
  /// [Colors.transparent] — keeping the border *slot* occupied so the chip's
  /// overall size does not shift when toggling visibility.
  final bool showBorder;

  /// Called whenever the chip is tapped.
  ///
  /// The [FilterChip.onSelected] boolean is intentionally discarded: this
  /// widget is stateless and selection-free, so the callback is a plain
  /// [VoidCallback] rather than a `ValueChanged<bool>`.
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      // Prefer the caller-supplied widget; otherwise synthesize a Text from
      // the stored label. The `_label!` is safe by construction: the two
      // constructors guarantee exactly one of child / _label is non-null.
      label:
          child ??
          Text(
            _label!.toUpperCase(),
            style: TextStyle(
              color: backgroundColor.contrastingColor(),
            ),
          ),
      // Adapt FilterChip's ValueChanged<bool> contract to a VoidCallback —
      // the selection value is meaningless for this stateless chip.
      onSelected: (_) => onPress(),
      backgroundColor: backgroundColor,
      // Mirror the background into selectedColor as a belt-and-suspenders
      // guard: even though `selected` is hard-pinned to false, the fill can
      // never diverge if that ever changes.
      selectedColor: backgroundColor,
      // This chip never represents selection state; it is a tap target only.
      selected: false,
      showCheckmark: false,
      // Stadium (pill) silhouette — fully rounded ends at any width.
      shape: const StadiumBorder(),
      side: BorderSide(
        // Transparent (rather than BorderSide.none) preserves the border's
        // layout contribution, so toggling showBorder never resizes the chip.
        color: showBorder ? _borderColor(context) : Colors.transparent,
        width: 3,
      ),
    );
  }

  /// Resolves the theme-aware accent color used for both the border and the
  /// [IceChip.text]-generated label.
  ///
  /// Returns [Colors.white] when the ambient [Theme] brightness is
  /// [Brightness.dark], and [Colors.black] otherwise. Called from [build]
  /// so the color always reflects the *current* theme, including live
  /// light/dark switches.
  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }
}
