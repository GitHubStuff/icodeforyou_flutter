// packages/app_navigation/lib/src/utils/button_list_manager.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;

/// {@template button_list_manager}
/// Reorders a list of navigation destinations so that the ones that fit
/// on a surface come first, in list order, followed — when anything did
/// not fit — by the `more` affordance and then every demoted
/// destination, also in list order.
///
/// [organize] returns one list. Reading it left to right:
///
/// ```text
/// [pin][pin][more] | [pin][overflow][overflow][pin]
///  └── dock ──────┘   └──── behind `more` ────────┘
/// ```
///
/// Everything up to and including `more` is drawn on the surface, with
/// `more` as its last button; everything after `more` is reachable only
/// through it. When `more` is absent, the whole list is drawn.
///
/// Rules, applied to `buttons` in list order against `capacity` whole
/// slots of [buttonWidth] inside `edgeSize`:
///
/// 1. [NavSlot.overflow] destinations are always demoted, wherever they
///    sit in the list.
/// 2. [NavSlot.more] may be listed explicitly or omitted. Listed, it
///    marks the point after which every destination is demoted. Omitted,
///    it is treated as if listed last.
/// 3. [NavSlot.pinned] destinations fill the surface until it is full.
///    When one would not fit, `more` is pulled forward into the last
///    slot and that destination and every pinned destination after it
///    are demoted.
/// 4. If nothing was demoted, `more` is not in the result at all.
///
/// Demoted destinations keep their relative list order; pinned and
/// overflow are not regrouped.
/// {@endtemplate}
class ButtonListManager<T extends NavButtonProperties> {
  /// {@macro button_list_manager}
  ///
  /// [more] is the destination drawn as the `more` affordance. It must
  /// have [NavSlot.more]. [buttonWidth] is the width of one button and
  /// must be positive.
  ///
  /// Throws [ArgumentError] when [more] does not have [NavSlot.more] or
  /// when [buttonWidth] is not positive.
  ButtonListManager({required this.more, required this.buttonWidth}) {
    if (more.slot != NavSlot.more) {
      throw ArgumentError.value(
        more,
        'more',
        'must have NavSlot.more, has ${more.slot}',
      );
    }
    if (buttonWidth <= 0) {
      throw ArgumentError.value(
        buttonWidth,
        'buttonWidth',
        'must be greater than zero',
      );
    }
  }

  /// The destination drawn as the `more` affordance.
  final T more;

  /// Width of a single button; every button on the surface shares it.
  final double buttonWidth;

  /// Returns [buttons] reordered for a surface [edgeSize] wide. See the
  /// class documentation for the layout of the result.
  ///
  /// Throws [StateError] when [buttons] is empty, when [edgeSize] cannot
  /// hold a single button, or when [buttons] contains a [NavSlot.more]
  /// destination other than [more].
  List<T> organize(List<T> buttons, double edgeSize) {
    _requireButtons(buttons);
    _requireSingleMore(buttons);

    final capacity = (edgeSize / buttonWidth).floor();
    _requireCapacity(capacity, edgeSize);

    final pinned = _pinnedBeforeMore(buttons);
    final overflowNeeded =
        buttons.length - (buttons.contains(more) ? 1 : 0) > pinned.length ||
        pinned.length > capacity;

    if (!overflowNeeded) return List<T>.unmodifiable(pinned);

    final surface = pinned.take(capacity - 1).toList(growable: false);
    final demoted = buttons.where(
      (button) => button != more && !surface.contains(button),
    );

    return List<T>.unmodifiable([...surface, more, ...demoted]);
  }

  /// Pinned destinations that precede `more` in the list, in list order.
  /// With an implicit `more` that is every pinned destination.
  List<T> _pinnedBeforeMore(List<T> buttons) => buttons
      .takeWhile((button) => button != more)
      .where((button) => button.slot == NavSlot.pinned)
      .toList(growable: false);

  void _requireButtons(List<T> buttons) {
    if (buttons.isNotEmpty) return;
    throw StateError('ButtonListManager: buttons must not be empty.');
  }

  void _requireSingleMore(List<T> buttons) {
    final foreign = buttons.where(
      (button) => button.slot == NavSlot.more && button != more,
    );
    if (foreign.isEmpty) return;
    throw StateError(
      'ButtonListManager: buttons contains a NavSlot.more destination '
      'other than more: ${foreign.join(', ')}.',
    );
  }

  void _requireCapacity(int capacity, double edgeSize) {
    if (capacity >= 1) return;
    throw StateError(
      'ButtonListManager: edgeSize $edgeSize cannot hold a single button '
      'of width $buttonWidth.',
    );
  }
}
