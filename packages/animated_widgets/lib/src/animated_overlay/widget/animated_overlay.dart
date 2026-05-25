// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:animated_widgets/src/animated_overlay/cubit/cubit.dart'
    show AnimatedOverlayCubit, AnimatedOverlayState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;

final class AnimatedOverlay extends StatelessWidget {
  const AnimatedOverlay({
    required this.child,
    super.key,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimatedOverlayCubit, AnimatedOverlayState>(
      listenWhen: (prev, curr) => (prev.child == null) != (curr.child == null),
      listener: (context, state) {
        unawaited(
          StatusBarChameleon.setStatusBarHidden(hidden: state.child != null),
        );
      },
      child: BlocBuilder<AnimatedOverlayCubit, AnimatedOverlayState>(
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ?child,
              if (state.child != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: state.opacity,
                    child: ColoredBox(
                      color: Colors.black,
                      child: Center(child: state.child),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
