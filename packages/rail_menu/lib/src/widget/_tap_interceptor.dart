// packages/rail_menu/lib/src/widget/_tap_interceptor.dart

part of '_internal.dart';

/// Intercepts a tap, dismisses the current route, then invokes [onTap].
///
/// Defers [onTap] to the next frame via [WidgetsBinding.addPostFrameCallback]
/// to ensure the modal is fully off the navigator stack before the
/// caller's action fires.
class _TapInterceptor extends StatelessWidget {
  const _TapInterceptor({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  void _handleTap(BuildContext context) {
    Navigator.of(context).pop();
    if (onTap == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => onTap!());
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _handleTap(context),
        child: child,
      );
}
