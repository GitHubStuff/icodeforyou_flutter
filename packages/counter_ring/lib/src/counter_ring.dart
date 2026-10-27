// packages/counter_ring/lib/src/counter_ring.dart

import 'package:counter_ring/counter_ring.dart'
    show CounterRingCubit, CounterRingState, RangeProgressRing;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A circular progress ring driven by a [CounterRingCubit].
///
/// Renders a [RangeProgressRing] spanning the cubit's `start` and `finish`
/// values, filled to its `currentValue`, with [centerBuilder] (or a default
/// numeric readout) in the middle. The widget rebuilds on every state
/// emission and provides [ringCubit] to its subtree via [BlocProvider].
///
/// Callbacks fire from a [BlocConsumer] listener whenever the state's
/// `currentValue` **or** `status` changes:
///
/// * [onValueChanged] is called with the new `currentValue` on each such
///   change — including status-only transitions such as start and stop,
///   where the value is unchanged.
/// * [onFinish] is called with the `finish` value once, on the emission
///   that transitions the status to finished.
///
/// The widget does not own the cubit; the caller is responsible for
/// closing it.
///
/// ```dart
/// final cubit = CounterRingCubit(start: 0, finish: 60, step: 1);
///
/// CounterRing(
///   ringCubit: cubit,
///   onFinish: (_) => debugPrint('Done'),
///   centerBuilder: (context, state) => Text('${state.currentValue}s'),
/// );
/// ```
class CounterRing extends StatelessWidget {
  /// Creates a ring bound to [ringCubit].
  ///
  /// [size] and [strokeWidth] are forwarded to [RangeProgressRing];
  /// [color] and [backgroundColor] are forwarded as-is, so `null` leaves
  /// the ring's own defaults in effect.
  const CounterRing({
    required this.ringCubit,
    this.onValueChanged,
    this.onFinish,
    this.size = 120,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.centerBuilder,
    super.key,
  });

  /// The cubit whose state drives the ring. Not owned by this widget.
  final CounterRingCubit ringCubit;

  /// Called with the current value whenever `currentValue` or `status`
  /// changes. See the class documentation for exact semantics.
  final ValueChanged<double>? onValueChanged;

  /// Called once with the finish value when the cubit reaches it.
  final ValueChanged<double>? onFinish;

  /// Diameter of the ring in logical pixels.
  final double size;

  /// Thickness of the ring's stroke in logical pixels.
  final double strokeWidth;

  /// Colour of the filled portion of the ring. `null` uses the
  /// [RangeProgressRing] default.
  final Color? color;

  /// Colour of the unfilled portion of the ring. `null` uses the
  /// [RangeProgressRing] default.
  final Color? backgroundColor;

  /// Builds the centre content. Defaults to the current value as text.
  ///
  /// The default readout prints whole numbers without a decimal point
  /// and other values to one decimal place, styled with
  /// `textTheme.headlineMedium`.
  final Widget Function(BuildContext context, CounterRingState state)?
  centerBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterRingCubit>.value(
      value: ringCubit,
      child: BlocConsumer<CounterRingCubit, CounterRingState>(
        listenWhen: (previous, current) =>
            previous.currentValue != current.currentValue ||
            previous.status != current.status,
        listener: _notify,
        builder: (context, state) {
          return RangeProgressRing(
            startValue: state.start,
            finishValue: state.finish,
            currentValue: state.currentValue,
            size: size,
            strokeWidth: strokeWidth,
            color: color,
            backgroundColor: backgroundColor,
            child:
                centerBuilder?.call(context, state) ??
                _DefaultCenter(state: state),
          );
        },
      ),
    );
  }

  void _notify(BuildContext context, CounterRingState state) {
    onValueChanged?.call(state.currentValue);
    if (state.isFinished) onFinish?.call(state.finish);
  }
}

/// Default centre readout: the current value as text.
///
/// Whole numbers render without a decimal point (`40`); anything else
/// renders to one decimal place (`12.5`).
class _DefaultCenter extends StatelessWidget {
  const _DefaultCenter({required this.state});

  final CounterRingState state;

  @override
  Widget build(BuildContext context) {
    final text = state.currentValue == state.currentValue.roundToDouble()
        ? state.currentValue.toInt().toString()
        : state.currentValue.toStringAsFixed(1);
    return Text(text, style: Theme.of(context).textTheme.headlineMedium);
  }
}
