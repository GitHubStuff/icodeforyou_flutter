// packages/animated_widgets/lib/src/crossfade_widgets/crossfade_widgets_cubit.dart
import 'package:custom_widgets/custom_widgets.dart' show DirectionalController;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Translates a [DirectionalController]'s value into the discrete active
/// child index for a cross-fade across [length] children.
///
/// The step grid is fixed: integer marks from `0` to `length - 1`, step `1`.
/// The cubit owns those bounds (derived from [length]) so the slider config
/// cannot drift out of sync with the child count.
///
/// Requires [length] >= 2 — a single child has nothing to cross-fade to, and
/// the caller is expected to short-circuit that case before constructing this
/// cubit (a one-element grid would have `min == max` and fail [StepGrid]'s
/// assert).
///
/// Does **not** own the controller — the caller constructs and disposes it;
/// this cubit only subscribes and tears its subscription down in [close].
class CrossFadeWidgetsCubit extends Cubit<int> {
  CrossFadeWidgetsCubit({
    required DirectionalController controller,
    required this.length,
    this.onIndexChanged,
  }) : assert(length >= 2, 'length ($length) must be >= 2 to cross-fade'),
       _controller = controller,
       super(controller.value.round().clamp(0, length - 1)) {
    _controller.addListener(_syncFromController);
  }

  final DirectionalController _controller;

  /// Number of children. The grid runs `0 .. length - 1`.
  final int length;

  /// Invoked with the new index every time the active child changes.
  ///
  /// Fired from [onChange], so it runs exactly once per real transition and
  /// never during the build of the consuming widget. The initial index is not
  /// reported — only subsequent changes — since the host already knows the
  /// starting index from the controller's initial value.
  final void Function(int index)? onIndexChanged;

  /// Lower grid bound. Always `0`.
  double get min => 0;

  /// Upper grid bound. The last valid child index.
  double get max => (length - 1).toDouble();

  /// Fixed step size. Integer marks only.
  double get step => 1;

  void _syncFromController() =>
      emit(_controller.value.round().clamp(0, length - 1));

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    if (change.currentState != change.nextState) {
      onIndexChanged?.call(change.nextState);
    }
  }

  @override
  Future<void> close() {
    _controller.removeListener(_syncFromController);
    return super.close();
  }
}
