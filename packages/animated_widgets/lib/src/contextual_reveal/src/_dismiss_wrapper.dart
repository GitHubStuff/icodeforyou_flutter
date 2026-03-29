// animated_widgets/lib/src/contextual_reveal/_dismiss_wrapper.dart

part of 'contextual_reveal.dart';

class _DismissWrapper extends StatelessWidget {
  const _DismissWrapper({
    required this.child,
    required this.onDismiss,
  });

  final Widget child;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close),
          ),
          child,
        ],
      );
}
