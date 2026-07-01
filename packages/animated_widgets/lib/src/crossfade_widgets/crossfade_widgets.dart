// packages/animated_widgets/lib/src/crossfade_widgets/crossfade_widgets.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalController, DirectionalSliderAndButtons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/theme_manager.dart' show CrossFadeTheme;

import 'crossfade_axis.dart';
import 'crossfade_widgets_cubit.dart' show CrossFadeWidgetsCubit;

class CrossFadeWidgets extends StatelessWidget {
  const CrossFadeWidgets({
    required this.children,
    super.key,
    this.buttonSize,
    this.duration,
    this.direction = CrossFadeAxis.left,
    this.onIndexChanged,
  });

  final List<Widget> children;

  /// Buttons size resolves from [CrossFadeTheme].
  final double? buttonSize;

  /// Cross-fade duration. When null, resolves from [CrossFadeTheme].
  final Duration? duration;

  final CrossFadeAxis direction;

  /// Invoked with the index of the child now being displayed, each time the
  /// active child changes. Not called for the initial child.
  final void Function(int index)? onIndexChanged;

  @override
  Widget build(BuildContext context) {
    // Nothing to fade to/from with fewer than two children: show the only
    // child (or nothing) without a slider, controller, or cubit.
    if (children.length < 2) {
      return children.isEmpty ? const SizedBox.shrink() : children.first;
    }

    return _StepperCrossFade(
      duration: duration ?? CrossFadeTheme.of(context).crossFadeDuration,
      direction: direction,
      onIndexChanged: onIndexChanged,
      buttonSize: buttonSize,
      children: children,
    );
  }
}

/// Stateful interior used only when there are >= 2 children. Owns the
/// [DirectionalController] lifecycle and provides the cubit.
class _StepperCrossFade extends StatefulWidget {
  const _StepperCrossFade({
    required this.children,
    required this.duration,
    required this.direction,
    required this.onIndexChanged,
    this.buttonSize,
  });

  final List<Widget> children;
  final Duration duration;
  final CrossFadeAxis direction;
  final void Function(int index)? onIndexChanged;
  final double? buttonSize;

  @override
  State<_StepperCrossFade> createState() => _StepperCrossFadeState();
}

class _StepperCrossFadeState extends State<_StepperCrossFade> {
  late final DirectionalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DirectionalController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CrossFadeWidgetsCubit(
        controller: _controller,
        length: widget.children.length,
        onIndexChanged: widget.onIndexChanged,
      ),
      child: _StepperCrossFadeBody(
        controller: _controller,
        duration: widget.duration,
        direction: widget.direction,
        buttonSize: widget.buttonSize,
        children: widget.children,
      ),
    );
  }
}

class _StepperCrossFadeBody extends StatelessWidget {
  const _StepperCrossFadeBody({
    required this.controller,
    required this.children,
    required this.duration,
    required this.direction,
    required this.buttonSize,
  });

  final DirectionalController controller;
  final List<Widget> children;
  final Duration duration;
  final CrossFadeAxis direction;
  final double? buttonSize;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CrossFadeWidgetsCubit>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<CrossFadeWidgetsCubit, int>(
          builder: (context, index) {
            return AnimatedSwitcher(
              duration: duration,
              child: KeyedSubtree(
                key: ValueKey(index),
                child: children[index],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        DirectionalSliderAndButtons(
          controller: controller,
          buttonSize: buttonSize ?? CrossFadeTheme.of(context).buttonSize,
          min: cubit.min,
          max: cubit.max,
          step: cubit.step,
        ),
      ],
    );
  }
}
