// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_host/src/animated_overlay/cubit/animated_overlay_cubit.dart' show AnimatedOverlayCubit;
import 'package:overlay_host/src/animated_overlay/cubit/animated_overlay_state.dart' show AnimatedOverlayState;

import 'package:statusbar/statusbar.dart' show StatusBar;

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
          StatusBar.setStatusBarHidden(hidden: state.child != null),
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
