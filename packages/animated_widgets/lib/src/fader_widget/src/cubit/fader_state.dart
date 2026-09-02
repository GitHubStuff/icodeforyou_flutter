// packages/animated_widgets/lib/src/fader_widget/src/cubit/fader_state.dart

part of 'fader_cubit.dart';

/// Immutable state emitted by [FaderCubit].
///
/// [current] is the string the widget should fade in. [isAnimating] is true
/// while a fade is in-flight. [queue] is a read-only snapshot of strings
/// waiting their turn, in FIFO order.
@immutable
class FaderState {
  /// Creates a new [FaderState] holding the active display and queue data.
  const FaderState({
    required this.current,
    required this.isAnimating,
    required this.queue,
  });

  /// The string currently shown or fading in. Null before the first push.
  final String? current;

  /// True while the widget is mid-fade for the [current] string.
  final bool isAnimating;

  /// Read-only snapshot of strings waiting their turn in FIFO order.
  final List<String> queue;

  /// Creates a copy of this state with the given fields replaced by the
  /// provided new values.
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

  /// Evaluates equality based on [current], [isAnimating], and [queue].
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FaderState &&
          other.current == current &&
          other.isAnimating == isAnimating &&
          _listEquals(other.queue, queue);

  /// Generates a hash code combining [current], [isAnimating], and [queue].
  @override
  int get hashCode => Object.hash(current, isAnimating, Object.hashAll(queue));

  /// Internal helper to evaluate deep equality of two string lists.
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
