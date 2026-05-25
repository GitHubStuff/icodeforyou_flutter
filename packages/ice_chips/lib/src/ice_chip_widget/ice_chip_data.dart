// packages/ice_chips_tray/lib/src/ice_chip_data.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter/foundation.dart' show immutable;

/// Data Transfer Object for a single chip in an [IceChipsTray].
///
/// A boundary type between domain models (e.g. database records) and the
/// tray's render layer. The tray and its Cubit operate exclusively on
/// [IceChipData] — they have no knowledge of where the data originated.
///
/// Callers are responsible for translating their domain types into
/// [IceChipData] instances before passing them to the tray.
@immutable
class IceChipData {
  const IceChipData({
    required this.id,
    required this.label,
    required this.colorInt,
  });

  /// Stable unique identifier — used as the selection key in
  /// [IceChipsTrayCubit] and as the [Dismissible] key in edit modes.
  final int id;

  /// Display text for the chip.
  final String label;

  /// Background color as a packed ARGB integer.
  final int colorInt;

  IceChipData copyWith({
    int? id,
    String? label,
    int? colorInt,
  }) {
    return IceChipData(
      id: id ?? this.id,
      label: label ?? this.label,
      colorInt: colorInt ?? this.colorInt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IceChipData &&
          other.id == id &&
          other.label == label &&
          other.colorInt == colorInt;

  @override
  int get hashCode => Object.hash(id, label, colorInt);

  @override
  String toString() =>
      'IceChipData(id: $id, label: "$label", colorInt: $colorInt)';
}
