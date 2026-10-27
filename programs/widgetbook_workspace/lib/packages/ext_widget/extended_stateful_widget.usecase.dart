// programs/widgetbook_workspace/lib/packages/ext_widget/extended_stateful_widget.usecase.dart

import 'package:ext_widget/ext_widget.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Hook Event Log',
  type: ExtendedStatefulWidget,
)
Widget buildExtendedStatefulWidgetHookEventLogUseCase(BuildContext context) {
  final maxEntries = context.knobs.int.slider(
    label: 'Max log entries',
    initialValue: 20,
    min: 5,
    max: 100,
  );
  final showTimestamps = context.knobs.boolean(
    label: 'Show timestamps',
    initialValue: true,
  );

  return _HookEventLogDemo(
    maxEntries: maxEntries,
    showTimestamps: showTimestamps,
  );
}

@widgetbook.UseCase(
  name: 'Initial Values',
  type: ExtendedStatefulWidget,
)
Widget buildExtendedStatefulWidgetInitialValuesUseCase(BuildContext context) =>
    const _InitialValuesDemo();

/// A log entry produced by one hook invocation.
class _HookEvent {
  const _HookEvent({
    required this.hook,
    required this.detail,
    required this.timestamp,
  });

  final String hook;
  final String detail;
  final DateTime timestamp;
}

/// Renders a scrolling log of every [ExtendedStatefulWidget] hook as it fires.
class _HookEventLogDemo extends StatefulWidget {
  const _HookEventLogDemo({
    required this.maxEntries,
    required this.showTimestamps,
  });

  final int maxEntries;
  final bool showTimestamps;

  @override
  State<_HookEventLogDemo> createState() => _HookEventLogDemoState();
}

class _HookEventLogDemoState extends ExtendedStatefulWidget<_HookEventLogDemo> {
  final List<_HookEvent> _events = <_HookEvent>[];

  void _record(String hook, String detail) {
    if (!mounted) {
      return;
    }
    setState(() {
      _events.insert(
        0,
        _HookEvent(hook: hook, detail: detail, timestamp: DateTime.now()),
      );
      if (_events.length > widget.maxEntries) {
        _events.removeRange(widget.maxEntries, _events.length);
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _record(
      'afterFirstLayout',
      'MediaQuery size: ${size.width.toStringAsFixed(0)} × '
          '${size.height.toStringAsFixed(0)}',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _record('didChangeAppLifecycleState', state.name);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final view = View.of(context);
    _record(
      'didChangeMetrics',
      'physical: ${view.physicalSize.width.toStringAsFixed(0)} × '
          '${view.physicalSize.height.toStringAsFixed(0)} '
          '@ ${view.devicePixelRatio.toStringAsFixed(2)}x',
    );
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _record('didChangePlatformBrightness', brightness.name);
  }

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    _record('reportTextScaleFactor', '${textScaleFactor ?? 'null'}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExtendedStatefulWidget'),
        actions: [
          IconButton(
            tooltip: 'Clear log',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(_events.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Resize the preview for didChangeMetrics. Switch browser tabs or '
              'background the app for didChangeAppLifecycleState. Change the '
              'OS theme for didChangePlatformBrightness and the OS font size '
              'for reportTextScaleFactor.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text('No events yet'))
                : ListView.separated(
                    itemCount: _events.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return ListTile(
                        dense: true,
                        leading: Text(
                          '${_events.length - index}',
                          style: theme.textTheme.labelSmall,
                        ),
                        title: Text(
                          event.hook,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        subtitle: Text(event.detail),
                        trailing: widget.showTimestamps
                            ? Text(
                                _formatTime(event.timestamp),
                                style: theme.textTheme.labelSmall,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    String pad(int value, [int width = 2]) =>
        value.toString().padLeft(width, '0');
    return '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}.'
        '${pad(time.millisecond, 3)}';
  }
}

/// Shows the values the base class hands over during [initState] and after
/// the first frame, without any further interaction.
class _InitialValuesDemo extends StatefulWidget {
  const _InitialValuesDemo();

  @override
  State<_InitialValuesDemo> createState() => _InitialValuesDemoState();
}

class _InitialValuesDemoState
    extends ExtendedStatefulWidget<_InitialValuesDemo> {
  double? _textScaleFactor;
  Size? _firstLayoutSize;

  @override
  void reportTextScaleFactor(double? textScaleFactor) {
    _textScaleFactor = textScaleFactor;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() => _firstLayoutSize = MediaQuery.sizeOf(context));
  }

  @override
  Widget build(BuildContext context) {
    final size = _firstLayoutSize;
    return Scaffold(
      appBar: AppBar(title: const Text('Initial values')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('reportTextScaleFactor (seeded in initState)'),
            subtitle: Text('${_textScaleFactor ?? 'not yet reported'}'),
          ),
          ListTile(
            title: const Text('afterFirstLayout — MediaQuery.sizeOf'),
            subtitle: Text(
              size == null
                  ? 'waiting for first frame'
                  : '${size.width.toStringAsFixed(0)} × '
                        '${size.height.toStringAsFixed(0)}',
            ),
          ),
        ],
      ),
    );
  }
}
