// widgetbook/lib/animated_widgets/animated_overlay/animated_overlay.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedOverlay, AnimatedOverlayCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnimatedOverlay)
Widget animatedOverlayUseCase(BuildContext context) {
  final fadeMs = context.knobs.int.slider(
    label: 'Fade duration (ms)',
    initialValue: 750,
    min: 10,
    max: 3000,
  );

  final overlayLabel = context.knobs.string(
    label: 'Overlay label',
    initialValue: 'Overlay Child',
  );

  final swapLabel = context.knobs.string(
    label: 'Switch label',
    initialValue: 'New Child',
  );

  return BlocProvider<AnimatedOverlayCubit>(
    create: (_) => AnimatedOverlayCubit(),
    child: _AnimatedOverlayUseCaseBody(
      fadeDuration: Duration(milliseconds: fadeMs),
      overlayLabel: overlayLabel,
      swapLabel: swapLabel,
    ),
  );
}

class _AnimatedOverlayUseCaseBody extends StatelessWidget {
  const _AnimatedOverlayUseCaseBody({
    required this.fadeDuration,
    required this.overlayLabel,
    required this.swapLabel,
  });

  final Duration fadeDuration;
  final String overlayLabel;
  final String swapLabel;

  Widget _buildOverlayContent(
    BuildContext context, {
    required String label,
    required bool isOverlayChild,
  }) {
    return _OverlayPanel(
      label: label,
      onSwap: () => _swap(context, currentIsOverlayChild: isOverlayChild),
      onFade: () => _fade(context),
    );
  }

  void _show(BuildContext context) {
    context.read<AnimatedOverlayCubit>().showOverlay(
      _buildOverlayContent(context, label: overlayLabel, isOverlayChild: true),
    );
  }

  void _swap(BuildContext context, {required bool currentIsOverlayChild}) {
    final cubit = context.read<AnimatedOverlayCubit>();
    if (currentIsOverlayChild) {
      cubit.updateOverlay(
        _buildOverlayContent(context, label: swapLabel, isOverlayChild: false),
      );
    } else {
      cubit.updateOverlay(
        _buildOverlayContent(
          context,
          label: overlayLabel,
          isOverlayChild: true,
        ),
      );
    }
  }

  void _fade(BuildContext context) {
    context.read<AnimatedOverlayCubit>().fadeOverlay(duration: fadeDuration);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOverlay(
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade100,
        body: Center(
          child: ElevatedButton(
            onPressed: () => _show(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text('SHOW', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayPanel extends StatelessWidget {
  const _OverlayPanel({
    required this.label,
    required this.onSwap,
    required this.onFade,
  });

  final String label;
  final VoidCallback onSwap;
  final VoidCallback onFade;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: onSwap, child: const Text('SWAP')),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: onFade, child: const Text('FADE')),
          ],
        ),
      ],
    );
  }
}
