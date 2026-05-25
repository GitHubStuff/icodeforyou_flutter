// lib/src/infinite_scroll_picker.dart

// ignore_for_file: avoid_positional_boolean_parameters, public_member_api_docs

part of 'library.dart';

/// An Apple-style infinite scrolling picker.
///
/// Displays a [label] alongside a wheel that cycles through
/// `config.items` indefinitely in either direction. The currently selected
/// item is reported through [onItemSelected], optionally debounced via
/// `config.wheelConfig.selectionDebounce`.
///
/// Type parameters:
/// * [T] — the item type contained in `config.items`.
/// * [K] — the type of `config.pickerId`, returned through [onItemSelected]
///   so a single handler can disambiguate between multiple pickers. Use
///   `String` for casual identifiers, or an enum for type-safe routing.
///
/// Example:
/// ```dart
/// InfiniteScrollPicker<String, String>(
///   label: const Text('Pick one'),
///   config: InfiniteScrollPickerConfig<String, String>(
///     items: const ['🍎', '🍌', '🍇'],
///     pickerId: 'fruit',
///     startingIndex: 0,
///   ),
///   itemBuilder: (item, isSelected) => Text(
///     item,
///     style: TextStyle(
///       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
///     ),
///   ),
///   onItemSelected: (id, item) => debugPrint('$id picked $item'),
/// );
/// ```
class InfiniteScrollPicker<T, K> extends StatefulWidget {
  const InfiniteScrollPicker({
    required this.config,
    required this.label,
    required this.itemBuilder,
    required this.onItemSelected,
    this.controller,
    super.key,
  });

  /// Layout, items, and visual configuration.
  final InfiniteScrollPickerConfig<T, K> config;

  /// Widget shown to the left of the wheel — typically a [Text].
  final Widget label;

  /// Builds the visual for a given item. The `isSelected` flag is `true`
  /// for the currently centered item and `false` otherwise.
  final Widget Function(T item, bool isSelected) itemBuilder;

  /// Called when the centered item changes. The first argument is
  /// `config.pickerId`; the second is the newly centered item. Debounced
  /// per `config.wheelConfig.selectionDebounce` (default: no debounce).
  final void Function(K pickerId, T item) onItemSelected;

  /// Optional imperative handle. If null, the picker creates and owns one
  /// internally. If non-null, the caller is responsible for disposing it.
  final InfiniteScrollPickerController? controller;

  @override
  State<InfiniteScrollPicker<T, K>> createState() =>
      _InfiniteScrollPickerState<T, K>();
}

class _InfiniteScrollPickerState<T, K> extends State<InfiniteScrollPicker<T, K>>
    implements _InfiniteScrollPickerControllerBinding {
  late FixedExtentScrollController _scrollController;
  late ValueNotifier<int> _selectedIndex;
  Timer? _debounceTimer;

  /// True when the picker created its own controller and must dispose it.
  bool _ownsController = false;
  late InfiniteScrollPickerController _controller;

  InfiniteScrollPickerConfig<T, K> get _config => widget.config;
  InfiniteScrollWheelConfig get _wheelConfig => _config.wheelConfig;

  @override
  void initState() {
    super.initState();
    _selectedIndex = ValueNotifier<int>(_config.startingIndex);
    _scrollController = FixedExtentScrollController(
      initialItem: _config.initialWheelOffset,
    );
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(InfiniteScrollPicker<T, K> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Swap controllers if the consumer changed which one they're passing in.
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController(widget.controller);
    }

    // If the items list or starting index changed, rebuild the wheel's
    // controller and reset the selection. Comparing by identity first is
    // a cheap fast-path for the common case where nothing changed.
    final itemsChanged =
        !identical(oldWidget.config.items, widget.config.items) &&
        !_listEquals(oldWidget.config.items, widget.config.items);
    final startChanged =
        oldWidget.config.startingIndex != widget.config.startingIndex;

    if (itemsChanged || startChanged) {
      _scrollController.dispose();
      _scrollController = FixedExtentScrollController(
        initialItem: _config.initialWheelOffset,
      );
      _selectedIndex.value = _config.startingIndex;
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _detachController();
    if (_ownsController) {
      _controller.dispose();
    }
    _scrollController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  // ── Controller wiring ─────────────────────────────────────────────────────

  void _attachController(InfiniteScrollPickerController? external) {
    if (external != null) {
      _controller = external;
      _ownsController = false;
    } else {
      _controller = InfiniteScrollPickerController();
      _ownsController = true;
    }
    _controller._attach(this);
  }

  void _detachController() {
    _controller._detach(this);
  }

  // ── Wheel callback ────────────────────────────────────────────────────────

  void _onSelectedItemChanged(int rawIndex) {
    final realIndex = rawIndex % _config.items.length;
    if (_selectedIndex.value == realIndex) return;
    _selectedIndex.value = realIndex;

    final debounce = _wheelConfig.selectionDebounce;
    if (debounce == Duration.zero) {
      _commitSelection(realIndex);
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounce, () => _commitSelection(realIndex));
    }
  }

  void _commitSelection(int realIndex) {
    if (!mounted) return;
    widget.onItemSelected(_config.pickerId, _config.items[realIndex]);
    _controller._notifySelectionChanged();
  }

  // ── _InfiniteScrollPickerControllerBinding ────────────────────────────────

  @override
  int currentIndex() => _selectedIndex.value;

  @override
  Future<void> reset({Duration? duration, Curve curve = Curves.easeInOut}) {
    if (duration == null) {
      jumpToIndex(_config.startingIndex);
      return Future.value();
    }
    return animateToIndex(_config.startingIndex, duration, curve);
  }

  @override
  void jumpToIndex(int realIndex) {
    final target = _targetOffset(realIndex);
    _scrollController.jumpToItem(target);
  }

  @override
  Future<void> animateToIndex(int realIndex, Duration duration, Curve curve) {
    final target = _targetOffset(realIndex);
    return _scrollController.animateToItem(
      target,
      duration: duration,
      curve: curve,
    );
  }

  /// Compute the absolute wheel offset that lands on [realIndex] via the
  /// shortest wrap-around path from the current offset.
  int _targetOffset(int realIndex) {
    final length = _config.items.length;
    final wrapped = realIndex % length;
    final current = _scrollController.selectedItem;
    final currentReal = current % length;
    var delta = wrapped - currentReal;
    // Take the shorter wrap direction.
    if (delta > length / 2) {
      delta -= length;
    } else if (delta < -length / 2) {
      delta += length;
    }
    return current + delta;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(_config.frameBorderRadius),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _config.frameHorizontalPadding,
          vertical: _config.frameVerticalPadding,
        ),
        child: Row(
          children: [
            Expanded(child: widget.label),
            InfiniteScrollWheel<T>(
              scrollController: _scrollController,
              items: _config.items,
              wheelConfig: _wheelConfig,
              itemBuilder: widget.itemBuilder,
              onSelectedItemChanged: _onSelectedItemChanged,
              selectedIndexListenable: _selectedIndex,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static bool _listEquals<E>(List<E> a, List<E> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
