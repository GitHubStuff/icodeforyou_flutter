// packages/custom_widgets/lib/src/shared/suffix_slot.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Horizontal gap between the trailing affordance and the field's outline, so
/// the affordance never paints over the border.
const double _kSuffixGap = 8;

/// A fixed-size, right-inset slot that centres a field's trailing affordance.
///
/// Both `InputField` and `PasswordField` route their suffix through this slot
/// so the trailing glyph lands at the *identical* horizontal inset in every
/// field — independent of whether the affordance carries its own internal
/// padding (an [IconButton]) or none at all (a bare [Icon]). Stacking the two
/// (e.g. email above password) therefore aligns their suffix icons exactly.
///
/// The slot is [kMinInteractiveDimension] square so a centred affordance still
/// occupies a full tap target's worth of space, with [child] centred inside
/// and a trailing [_kSuffixGap] inset from the outline. Fields must pass
/// [constraints] to [InputDecoration.suffixIconConstraints] so the decorator
/// reserves exactly this footprint and never stretches it.
///
/// Centring is what guarantees alignment: a symmetric affordance (icon button,
/// icon) has its glyph at the box centre regardless of its own size, so two
/// different affordances resolve to the same glyph position. A child that
/// wants the whole tap target (e.g. an opaque gesture region) should size
/// itself to [kMinInteractiveDimension]; centring a square that already fills
/// the slot is a no-op.
class SuffixSlot extends StatelessWidget {
  const SuffixSlot({required this.child, super.key});

  /// Constraints a field passes to [InputDecoration.suffixIconConstraints] so
  /// the slot keeps its intended fixed footprint and tap target.
  static const BoxConstraints constraints = BoxConstraints(
    minWidth: kMinInteractiveDimension,
    minHeight: kMinInteractiveDimension,
  );

  /// The trailing affordance, centred within the slot.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _kSuffixGap),
      child: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: Center(child: child),
      ),
    );
  }
}
