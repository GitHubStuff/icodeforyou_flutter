// programs/black_velvet/lib/app_shared_navigation/navigation_state.dart

import 'package:flutter/foundation.dart';

/// {@template navigation_state}
/// The navigation shell's state: which destination is selected and
/// whether the rail's buttons are shown.
///
/// [destinationName] is an enum member *name*, not a member: the dock
/// and rail own separate destination enums, so state that must
/// survive swapping between them cannot hold either enum's type. Each
/// screen resolves the name against its own enum, falling back to its
/// own `initial` when the name has no member there.
///
/// [railVisible] is read only by the rail; the dock ignores it, and
/// it persists across dock↔rail swaps so a hidden rail stays hidden
/// through rotation round-trips.
/// {@endtemplate}
@immutable
final class NavigationState {
  /// {@macro navigation_state}
  const NavigationState({
    required this.destinationName,
    this.railVisible = true,
  });

  /// The name of the selected destination enum member.
  final String destinationName;

  /// Whether the rail's buttons are currently shown.
  final bool railVisible;

  /// A copy with the given fields replaced.
  NavigationState copyWith({String? destinationName, bool? railVisible}) =>
      NavigationState(
        destinationName: destinationName ?? this.destinationName,
        railVisible: railVisible ?? this.railVisible,
      );

  @override
  bool operator ==(Object other) =>
      other is NavigationState &&
      other.destinationName == destinationName &&
      other.railVisible == railVisible;

  @override
  int get hashCode => Object.hash(destinationName, railVisible);
}
