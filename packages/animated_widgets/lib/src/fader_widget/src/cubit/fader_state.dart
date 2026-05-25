// packages/animated_widgets/lib/src/fader/fader_state.dart

part of 'fader_cubit.dart';

/// Immutable state emitted by [FaderCubit].
///
/// [current] is the string the widget should fade in. [isAnimating] is true
/// while a fade is in-flight. [queue] is a read-only snapshot of strings
/// waiting their turn, in FIFO order.
class FaderState {
  const FaderState({
    required this.current,
    required this.isAnimating,
    required this.queue,
  });

  /// The string currently shown / fading in. Null before the first push.
  final String? current;

  /// True while the widget is mid-fade for [current].
  final bool isAnimating;

  /// Read-only snapshot of strings waiting their turn (FIFO).
  final List<String> queue;

  FaderState copyWith({
    String? current,
    bool? isAnimating,
    List<String>? queue,
  }) {
    return FaderState(
      current: current ?? this.current,
      isAnimating: isAnimating ?? this.isAnimating,
      queue: queue ?? this.queue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaderState &&
          other.current == current &&
          other.isAnimating == isAnimating &&
          _listEquals(other.queue, queue);

  @override
  int get hashCode =>
      Object.hash(current, isAnimating, Object.hashAll(queue));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
