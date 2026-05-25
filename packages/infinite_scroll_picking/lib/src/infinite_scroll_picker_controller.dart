// lib/src/infinite_scroll_picker_controller.dart

// ignore_for_file: comment_references

part of 'library.dart';

/// A handle for imperatively controlling an [InfiniteScrollPicker].
///
/// Pass an instance to [InfiniteScrollPicker.controller] to drive the picker
/// from outside its widget subtree — e.g. from a Cubit, a parent widget, or
/// a test.
///
/// The controller must be attached to a single picker at a time. Attaching
/// the same controller to two pickers simultaneously is a programming error
/// and will trigger an assert in debug builds.
///
/// Extends [ChangeNotifier] so consumers can `addListener` to observe
/// selection changes without wiring up the `onItemSelected` callback.
///
/// Example:
/// ```dart
/// final controller = InfiniteScrollPickerController();
///
/// InfiniteScrollPicker<String, String>(
///   controller: controller,
///   config: ...,
///   ...
/// );
///
/// // Later, from anywhere:
/// controller.reset();
/// await controller.reset(duration: const Duration(milliseconds: 400));
/// await controller.animateToIndex(5);
/// final i = controller.currentIndex;
/// ```
///
/// Dispose the controller when you are done with it:
/// ```dart
/// @override
/// void dispose() {
///   controller.dispose();
///   super.dispose();
/// }
/// ```
class InfiniteScrollPickerController extends ChangeNotifier {
  _InfiniteScrollPickerControllerBinding? _binding;

  bool get _isAttached => _binding != null;

  /// The currently selected real index (in `[0, items.length)`), or `null`
  /// if the controller is not attached to a picker.
  int? get currentIndex => _binding?.currentIndex();

  /// Reset the picker to its current config's `startingIndex`.
  ///
  /// "Current config" means whatever the picker most recently rebuilt with —
  /// not the config that was passed when the controller was created.
  ///
  /// If [duration] is null (the default), the picker snaps instantly. Pass
  /// a non-null [duration] to animate using [curve] (default
  /// [Curves.easeInOut]). When animating, returns a [Future] that completes
  /// when the animation finishes; when snapping, returns an
  /// already-completed future.
  Future<void> reset({Duration? duration, Curve curve = Curves.easeInOut}) {
    _assertAttached('reset');
    return _binding!.reset(duration: duration, curve: curve);
  }

  /// Jump to [realIndex] without animation.
  ///
  /// [realIndex] is interpreted modulo `items.length`, so values outside
  /// `[0, items.length)` are wrapped — passing `-1` lands on the last item,
  /// passing `items.length` lands on the first.
  void jumpToIndex(int realIndex) {
    _assertAttached('jumpToIndex');
    _binding!.jumpToIndex(realIndex);
  }

  /// Animate to [realIndex] over [duration] using [curve].
  ///
  /// [realIndex] is interpreted modulo `items.length` (see [jumpToIndex]).
  /// The animation takes the shortest wrap-around path to the target.
  Future<void> animateToIndex(
    int realIndex, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    _assertAttached('animateToIndex');
    return _binding!.animateToIndex(realIndex, duration, curve);
  }

  // ── Internal binding ──────────────────────────────────────────────────────

  void _attach(_InfiniteScrollPickerControllerBinding binding) {
    assert(
      _binding == null,
      'InfiniteScrollPickerController is already attached to a picker. '
      'A controller can only drive one picker at a time.',
    );
    _binding = binding;
  }

  void _detach(_InfiniteScrollPickerControllerBinding binding) {
    if (identical(_binding, binding)) {
      _binding = null;
    }
  }

  void _assertAttached(String method) {
    assert(
      _isAttached,
      'InfiniteScrollPickerController.$method() called before the controller '
      'was attached to an InfiniteScrollPicker, or after the picker was '
      'disposed.',
    );
  }

  /// Notify listeners — called by the picker's state when the selection
  /// commits, so consumers can `addListener` to observe selection without
  /// wiring up the `onItemSelected` callback.
  void _notifySelectionChanged() {
    notifyListeners();
  }
}

/// Internal contract between [InfiniteScrollPickerController] and the
/// picker's state. Kept private so the public controller stays a clean
/// API surface.
abstract interface class _InfiniteScrollPickerControllerBinding {
  int currentIndex();
  Future<void> reset({Duration? duration, Curve curve});
  void jumpToIndex(int realIndex);
  Future<void> animateToIndex(int realIndex, Duration duration, Curve curve);
}
