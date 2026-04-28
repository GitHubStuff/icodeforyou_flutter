// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:animated_widgets/src/animated_overlay/cubit/cubit.dart'
    show AnimatedOverlayState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class AnimatedOverlayCubit extends Cubit<AnimatedOverlayState> {
  AnimatedOverlayCubit() : super(const AnimatedOverlayState.hidden());

  Timer? _fadeTimer;

  void showOverlay(Widget child) {
    _cancelFade();
    emit(AnimatedOverlayState(child: child, opacity: 1));
  }

  void updateOverlay(Widget child) {
    _cancelFade();
    emit(AnimatedOverlayState(child: child, opacity: 1));
  }

  void removeOverlay() {
    _cancelFade();
    emit(const AnimatedOverlayState.hidden());
  }

  void fadeOverlay({Duration duration = const Duration(milliseconds: 750)}) {
    if (state.child == null) return;
    _cancelFade();
    emit(state.copyWith(opacity: 1));

    // Base on about 60/fps display rate
    const tickRate = Duration(milliseconds: 16);
    final totalMicros = duration.inMicroseconds;
    final startMicros = DateTime.now().microsecondsSinceEpoch;

    _fadeTimer = Timer.periodic(tickRate, (timer) {
      final elapsed = DateTime.now().microsecondsSinceEpoch - startMicros;
      final t = (elapsed / totalMicros).clamp(0.0, 1.0);
      if (t >= 1.0) {
        timer.cancel();
        _fadeTimer = null;
        emit(const AnimatedOverlayState.hidden());
      } else {
        emit(state.copyWith(opacity: 1.0 - t));
      }
    });
  }

  void _cancelFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }

  @override
  Future<void> close() {
    _cancelFade();
    return super.close();
  }
}
