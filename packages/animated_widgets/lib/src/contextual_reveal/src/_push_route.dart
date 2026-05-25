// animated_widgets/lib/src/contextual_reveal/_push_route.dart

part of 'contextual_reveal.dart';

class _PushRoute extends StatelessWidget {
  const _PushRoute({
    required this.child,
    required this.backButton,
  });

  final Widget child;
  final Widget? backButton;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: backButton ?? const BackButton(),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(child: child),
      );
}
