// widgetbook_workspace/lib/packages/animated_barrier/imperative_control.usecase.dart

// ignore_for_file: comment_references

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, PopoverHandle, SlideFromBottomBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Exposes the full [PopoverHandle] lifecycle: imperative show / dismiss,
/// a delayed auto-dismiss, idempotent re-dismiss, and onComplete callbacks
/// streamed to an on-screen event log.
///
/// The dismiss controls live *inside* the popover card so they remain
/// tappable while the barrier is up — without that, every dismiss button
/// would be buried under its own barrier. The page hosts only show + the
/// pre-show scheduling actions (which fire after the barrier is in place).
@widgetbook.UseCase(name: 'Imperative control', type: AnimatedBarrier)
Widget imperativeControlAnimatedBarrierUseCase(BuildContext context) {
  return const _ControlPanel();
}

class _ControlPanel extends StatefulWidget {
  const _ControlPanel();

  @override
  State<_ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<_ControlPanel> {
  PopoverHandle? _handle;
  Timer? _autoDismissTimer;
  final List<String> _log = [];

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _handle?.dismiss();
    super.dispose();
  }

  void _logEvent(String message) {
    if (!mounted) return;
    setState(() {
      final stamp = DateTime.now().toIso8601String().substring(11, 23);
      _log.insert(0, '$stamp  $message');
    });
  }

  void _show(BuildContext context) {
    _logEvent('show() called');
    _handle = AnimatedBarrier(
      barrierAnimation: const SlideFromBottomBarrier(
        duration: Duration(milliseconds: 400),
      ),
      childSize: const Size(300, 220),
      child: _InPopoverControls(
        onDismiss: _dismiss,
        onDismissTwice: _dismissTwice,
      ),
    ).show(context, onComplete: () => _logEvent('entrance animation done'));
  }

  void _dismiss() {
    _logEvent('dismiss() called');
    _handle?.dismiss(onComplete: () => _logEvent('exit animation done'));
  }

  void _dismissTwice() {
    _logEvent('dismiss() called (1st)');
    _handle?.dismiss(onComplete: () => _logEvent('1st onComplete'));
    _logEvent('dismiss() called (2nd, should be a no-op-ish)');
    _handle?.dismiss(onComplete: () => _logEvent('2nd onComplete (immediate)'));
  }

  void _showThenAutoDismissIn(BuildContext context, Duration delay) {
    _show(context);
    _logEvent('auto-dismiss scheduled in ${delay.inMilliseconds}ms');
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(delay, _dismiss);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Builder(
                  builder: (innerContext) => FilledButton(
                    onPressed: () => _show(innerContext),
                    child: const Text('show()'),
                  ),
                ),
                Builder(
                  builder: (innerContext) => OutlinedButton(
                    onPressed: () => _showThenAutoDismissIn(
                      innerContext,
                      const Duration(seconds: 2),
                    ),
                    child: const Text('show() + auto-dismiss in 2s'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Dismiss controls live inside the popover (otherwise the '
              'barrier would cover them).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Event log', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(
                  _log[i],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InPopoverControls extends StatelessWidget {
  const _InPopoverControls({
    required this.onDismiss,
    required this.onDismissTwice,
  });

  final VoidCallback onDismiss;
  final VoidCallback onDismissTwice;

  @override
  Widget build(BuildContext context) {
    return BarrierDemoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imperative popover',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Drive the handle from inside the modal.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: onDismiss,
                child: const Text('dismiss()'),
              ),
              OutlinedButton(
                onPressed: onDismissTwice,
                child: const Text('dismiss() ×2'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
