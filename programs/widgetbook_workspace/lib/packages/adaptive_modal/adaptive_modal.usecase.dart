// lib/packages/adaptive_modal/adaptive_modal.usecase.dart

import 'package:adaptive_modal/adaptive_modal.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Shared scaffold
// ---------------------------------------------------------------------------

class _ModalHost extends StatefulWidget {
  const _ModalHost({
    required this.config,
    required this.contentBuilder,
    required this.label,
  });

  final AdaptiveModalConfig config;
  final Widget Function(AdaptiveModalController<void>) contentBuilder;
  final String label;

  @override
  State<_ModalHost> createState() => _ModalHostState();
}

class _ModalHostState extends State<_ModalHost> {
  final GlobalKey _anchorKey = GlobalKey();
  late AdaptiveModalController<void> _controller;

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveModalController<void>(
      anchorKey: _anchorKey,
      config: widget.config,
      child: Builder(builder: (ctx) => widget.contentBuilder(_controller)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.attach(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        key: _anchorKey,
        onPressed: () => _controller.show(context),
        child: Text(widget.label),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared modal content
// ---------------------------------------------------------------------------

Widget _defaultContent(AdaptiveModalController<void> controller) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Modal Content',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text('This is the body of the adaptive modal.'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: controller.hide,
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Use cases
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Default', type: AdaptiveModalController)
Widget adaptiveModalDefault(BuildContext context) {
  return const _ModalHost(
    config: AdaptiveModalConfig(),
    contentBuilder: _defaultContent,
    label: 'Open Modal',
  );
}

@widgetbook.UseCase(name: 'Custom Close Icon', type: AdaptiveModalController)
Widget adaptiveModalCustomIcon(BuildContext context) {
  return const _ModalHost(
    config: AdaptiveModalConfig(
      closeIcon: Icon(Icons.arrow_back_ios_new, size: 18),
    ),
    contentBuilder: _defaultContent,
    label: 'Custom Icon',
  );
}

@widgetbook.UseCase(name: 'No Barrier', type: AdaptiveModalController)
Widget adaptiveModalNoBarrier(BuildContext context) {
  return const _ModalHost(
    config: AdaptiveModalConfig(barrierDismissible: false),
    contentBuilder: _defaultContent,
    label: 'No Barrier',
  );
}

// ---------------------------------------------------------------------------
// Return Value use case — uses String controller
// ---------------------------------------------------------------------------

class _ReturnValueHost extends StatefulWidget {
  const _ReturnValueHost();

  @override
  State<_ReturnValueHost> createState() => _ReturnValueHostState();
}

class _ReturnValueHostState extends State<_ReturnValueHost> {
  final GlobalKey _anchorKey = GlobalKey();
  late AdaptiveModalController<String> _controller;
  String? _result;

  @override
  void initState() {
    super.initState();
    _controller = AdaptiveModalController<String>(
      anchorKey: _anchorKey,
      child: _ReturnValueContent(onConfirm: (v) => _controller.resolve(v)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.attach(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            key: _anchorKey,
            onPressed: () async {
              final result = await _controller.show(context);
              setState(() => _result = result ?? '(dismissed)');
            },
            child: const Text('Open — Return Value'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text('Result: $_result'),
          ],
        ],
      ),
    );
  }
}

class _ReturnValueContent extends StatelessWidget {
  const _ReturnValueContent({required this.onConfirm});

  final void Function(String) onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pick a value',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => onConfirm('Option A'),
            child: const Text('Option A'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => onConfirm('Option B'),
            child: const Text('Option B'),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Return Value', type: AdaptiveModalController)
Widget adaptiveModalReturnValue(BuildContext context) {
  return const _ReturnValueHost();
}
