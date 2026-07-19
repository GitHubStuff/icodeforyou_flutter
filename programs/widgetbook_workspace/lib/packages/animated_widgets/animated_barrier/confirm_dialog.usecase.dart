// widgetbook_workspace/lib/packages/animated_barrier/confirm_dialog.usecase.dart

// ignore_for_file: comment_references

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, FadeBarrier, PopoverHandle;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Realistic "confirm action" pattern: barrier is non-dismissible
/// (`barrierDismissible: false`), and the child carries its own Confirm /
/// Cancel buttons that drive [PopoverHandle.dismiss] explicitly. This is
/// where the imperative handle pays off — the caller owns the lifecycle.
@widgetbook.UseCase(name: 'Confirm dialog', type: AnimatedBarrier)
Widget confirmDialogAnimatedBarrierUseCase(BuildContext context) {
  return const _ConfirmHost();
}

class _ConfirmHost extends StatefulWidget {
  const _ConfirmHost();

  @override
  State<_ConfirmHost> createState() => _ConfirmHostState();
}

class _ConfirmHostState extends State<_ConfirmHost> {
  String _lastResult = '—';

  void _setResult(String value) {
    if (!mounted) return;
    setState(() => _lastResult = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (innerContext) => FilledButton(
                onPressed: () => _open(innerContext),
                child: const Text('Delete record…'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Last result: $_lastResult'),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    late final PopoverHandle handle;
    handle = AnimatedBarrier(
      barrierDismissible: false,
      barrierAnimation: const FadeBarrier(),
      childSize: const Size(320, 200),
      child: _ConfirmCard(
        onCancel: () =>
            handle.dismiss(onComplete: () => _setResult('cancelled')),
        onConfirm: () =>
            handle.dismiss(onComplete: () => _setResult('confirmed')),
      ),
    ).show(context);
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return BarrierDemoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete this record?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text('This action cannot be undone.'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: onConfirm,
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
