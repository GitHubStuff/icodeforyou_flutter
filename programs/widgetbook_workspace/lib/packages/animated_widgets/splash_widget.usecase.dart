// packages/animated_widgets/lib/src/splash_widget/splash_widget.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

enum _SplashTransition {
  fade('Fade', AnimatedSwitcher.defaultTransitionBuilder),
  scale('Scale', _scale),
  slide('Slide', _slide),
  rotation('Rotation', _rotation);

  const _SplashTransition(this.label, this.builder);

  final String label;
  final AnimatedSwitcherTransitionBuilder builder;

  static Widget _scale(Widget child, Animation<double> animation) =>
      ScaleTransition(scale: animation, child: child);

  static Widget _slide(Widget child, Animation<double> animation) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );

  static Widget _rotation(Widget child, Animation<double> animation) =>
      RotationTransition(turns: animation, child: child);
}

@UseCase(name: 'Default', type: SplashWidget)
Widget splashWidgetUseCase(BuildContext context) {
  final displayMs = context.knobs.int.slider(
    label: 'Display Duration (ms)',
    initialValue: 2000,
    min: 500,
    max: 5000,
  );

  final transitionMs = context.knobs.int.slider(
    label: 'Transition Duration (ms)',
    initialValue: 400,
    min: 100,
    max: 2000,
  );

  final transition = context.knobs.object.dropdown<_SplashTransition>(
    label: 'Transition',
    options: _SplashTransition.values,
    initialOption: _SplashTransition.fade,
    labelBuilder: (value) => value.label,
  );

  return Center(
    child: SplashWidget(
      key: ValueKey('$displayMs-$transitionMs-${transition.name}'),
      displayDuration: Duration(milliseconds: displayMs),
      transitionDuration: Duration(milliseconds: transitionMs),
      transitionBuilder: transition.builder,
      onDisplayComplete: () => debugPrint('SplashWidget: display complete'),
      child: Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Splash',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  );
}
