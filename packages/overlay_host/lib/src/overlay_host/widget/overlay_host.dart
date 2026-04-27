// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_host/src/overlay_host/cubit/overlay_host_cubit.dart'
    show OverlayHostCubit;
import 'package:statusbar/statusbar.dart' show StatusBar;

final class OverlayHost extends StatelessWidget {
  const OverlayHost({
    required this.child,
    super.key,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OverlayHostCubit, Widget?>(
      listenWhen: (prev, curr) => (prev == null) != (curr == null),
      listener: (context, overlayChild) {
        unawaited(
          StatusBar.setStatusBarHidden(
            hidden: overlayChild != null,
          ),
        );
      },
      child: BlocBuilder<OverlayHostCubit, Widget?>(
        builder: (context, overlayChild) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ?child,

              if (overlayChild != null)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(child: overlayChild),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
