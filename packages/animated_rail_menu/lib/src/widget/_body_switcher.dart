// lib/src/widget/_body_switcher.dart

part of '_internal.dart';

/// Animates between pages when the active [RailMenuCubit] index changes.
class _BodySwitcher extends StatelessWidget {
  const _BodySwitcher({
    required this.entries,
    required this.transitionDuration,
  });

  final List<RailMenuEntry> entries;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RailMenuCubit, RailMenuState>(
      builder: (context, state) {
        if (transitionDuration == Duration.zero) {
          return SizedBox.expand(child: entries[state.activeIndex].page);
        }
        return AnimatedSwitcher(
          duration: transitionDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              _buildTransition(state.transition, animation, child),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.topLeft,
            children: [...previousChildren, ?currentChild],
          ),
          child: SizedBox.expand(
            key: ValueKey(state.activeIndex),
            child: entries[state.activeIndex].page,
          ),
        );
      },
    );
  }

  Widget _buildTransition(
    RailTransition transition,
    Animation<double> animation,
    Widget child,
  ) {
    switch (transition) {
      case RailTransition.crossFade:
        return FadeTransition(opacity: animation, child: child);
      case RailTransition.slideLeft:
        return _slide(const Offset(-1, 0), animation, child);
      case RailTransition.slideRight:
        return _slide(const Offset(1, 0), animation, child);
      case RailTransition.slideUp:
        return _slide(const Offset(0, -1), animation, child);
      case RailTransition.slideDown:
        return _slide(const Offset(0, 1), animation, child);
      case RailTransition.scale:
        return ScaleTransition(scale: animation, child: child);
      // coverage:ignore-start
      case RailTransition.slideDirectional:
        return FadeTransition(opacity: animation, child: child);
      // coverage:ignore-end
    }
  }

  Widget _slide(Offset begin, Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}
