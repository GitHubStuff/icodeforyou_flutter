// packages/app_navigation/lib/src/utils/button_list_manager.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;

/// {@template button_manager}
/// Partitions a list of navigation destinations into those that fit on
/// a surface of a given width and those that overflow behind the
/// `more` affordance.
///
/// Rules, applied in order:
///
/// 1. If every [NavSlot.pinned] destination fits and no
///    [NavSlot.overflow] destination exists, the dock is exactly the
///    pinned destinations and `more` is unused.
/// 2. Otherwise `more` is required. It occupies the last dock position
///    and one button-width. Pinned destinations fill the remaining
///    positions in list order; any that do not fit are demoted to the
///    front of the overflow list, ahead of the [NavSlot.overflow]
///    destinations.
///
/// Capacity is the number of whole buttons of [buttonWidth] that fit in
/// [width]. Spacing and centering are presentation concerns and belong
/// to the widget that lays the buttons out.
///
/// The partition is computed once at construction; [fitted] and
/// [overflow] return unmodifiable views.
/// {@endtemplate}
class ButtonListManager<T extends NavButtonProperties> {
  /// {@macro button_manager}
  ///
  /// Throws [UnsupportedError] when [_buttonWidth] is not positive.
  ///
  /// Throws [StateError] when `more` is needed but [buttons] contains
  /// none, when [buttons] contains more than one `more`, or when
  /// [_width] cannot hold even one button while overflow exists.
  ButtonListManager({
    required List<T> buttons,
    required this._width,
    required this._buttonWidth,
  }) : _buttons = List<T>.unmodifiable(buttons) {
    _requirePositiveButtonWidth();
    final partition = _partition();
    _fitted = List<T>.unmodifiable(partition.fitted);
    _overflow = List<T>.unmodifiable(partition.overflow);
  }

  final List<T> _buttons;
  final double _width;
  final double _buttonWidth;

  late final List<T> _fitted;
  late final List<T> _overflow;

  /// Destinations drawn on the surface, in display order. When overflow
  /// exists the last element is the `more` affordance.
  List<T> fitted() => _fitted;

  /// Destinations hidden behind `more`, in display order: demoted pinned
  /// destinations first, then the [NavSlot.overflow] destinations.
  List<T> overflow() => _overflow;

  /// Number of whole buttons that fit in [_width].
  int get _capacity => (_width / _buttonWidth).floor();

  void _requirePositiveButtonWidth() {
    if (_buttonWidth > 0) return;
    throw UnsupportedError(
      'ButtonManager: buttonWidth must be greater than zero, '
      'got $_buttonWidth. Pass the width of a single button, '
      'e.g. DockItems.size.width.',
    );
  }

  _Partition<T> _partition() {
    final pinned = _bySlot(NavSlot.pinned);
    final overflowed = _bySlot(NavSlot.overflow);
    final capacity = _capacity;

    final everythingFits = pinned.length <= capacity && overflowed.isEmpty;
    if (everythingFits) {
      return _Partition<T>(fitted: pinned, overflow: const []);
    }

    final more = _requireSingleMore();
    final room = capacity - 1;
    if (room < 0) {
      throw StateError(
        'ButtonManager: width $_width cannot hold a single button of '
        'width $_buttonWidth, but overflow exists.',
      );
    }

    return _Partition<T>(
      fitted: [...pinned.take(room), more],
      overflow: [...pinned.skip(room), ...overflowed],
    );
  }

  List<T> _bySlot(NavSlot slot) =>
      _buttons.where((button) => button.slot == slot).toList(growable: false);

  T _requireSingleMore() {
    final mores = _bySlot(NavSlot.more);
    return switch (mores.length) {
      1 => mores.single,
      0 => throw StateError(
        'ButtonManager: overflow is required but no button has '
        'NavSlot.more.',
      ),
      _ => throw StateError(
        'ButtonManager: expected exactly one NavSlot.more button, '
        'found ${mores.length}.',
      ),
    };
  }
}

/// Result of a single partition pass.
class _Partition<T> {
  const _Partition({required this.fitted, required this.overflow});

  final List<T> fitted;
  final List<T> overflow;
}
