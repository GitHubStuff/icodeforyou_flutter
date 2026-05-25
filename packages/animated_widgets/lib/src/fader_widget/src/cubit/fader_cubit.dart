// packages/animated_widgets/lib/src/fader/fader_cubit.dart

// ignore_for_file: comment_references

import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'fader_state.dart';

/// FIFO traffic controller for fading strings through a [FaderWidget].
///
/// The cubit owns all decisions; the widget only renders [FaderState.current]
/// and reports its animation lifecycle via [fadeStarted] and [fadeComplete].
/// The cubit never infers animation state on its own — `isAnimating` is driven
/// solely by the widget's signals.
///
/// Flow:
///   * [push] hands the cubit a string.
///       - Idle (not animating, queue empty): emit it as [FaderState.current].
///       - Otherwise: append to the FIFO queue.
///   * Widget sees a new [FaderState.current], calls [fadeStarted].
///   * Widget finishes the fade, calls [fadeComplete]; the cubit pulls the next
///     queued string (FIFO) and emits it, or goes idle if the queue is empty.
class FaderCubit extends Cubit<FaderState> {
  FaderCubit()
    : super(
        const FaderState(
          current: null,
          isAnimating: false,
          queue: <String>[],
        ),
      );

  // Pending strings awaiting their turn. Private so callers cannot mutate the
  // queue; the state exposes only a read-only snapshot.
  final Queue<String> _queue = Queue<String>();

  /// Hand the cubit a string. Emits it now if a fade is idle, else queues FIFO.
  void push(String text) {
    // Queue only while a fade is genuinely in flight. Having something already
    // on screen is NOT a reason to queue — an idle field must accept the next
    // string immediately, otherwise the queue can only ever drain on a fade
    // completion that never comes (deadlock).
    if (state.isAnimating) {
      _queue.add(text);
      _syncQueue();
      return;
    }
    _emitCurrent(text);
  }

  /// Widget reports a fade has begun. The cubit records it; nothing else.
  void fadeStarted() {
    if (!state.isAnimating) emit(state.copyWith(isAnimating: true));
  }

  /// Widget reports a fade has finished. Advance the FIFO queue.
  void fadeComplete() {
    if (_queue.isEmpty) {
      emit(state.copyWith(isAnimating: false));
      return;
    }
    _emitCurrent(_queue.removeFirst());
  }

  /// Drop every queued string. Leaves the on-screen string untouched.
  void clear() {
    _queue.clear();
    _syncQueue();
  }

  // Emit a string for the widget to fade in. isAnimating is left to the
  // widget's fadeStarted signal — the cubit does not assert it here.
  void _emitCurrent(String text) {
    emit(
      state.copyWith(
        current: text,
        isAnimating: false,
        queue: List<String>.unmodifiable(_queue),
      ),
    );
  }

  void _syncQueue() {
    emit(state.copyWith(queue: List<String>.unmodifiable(_queue)));
  }
}
