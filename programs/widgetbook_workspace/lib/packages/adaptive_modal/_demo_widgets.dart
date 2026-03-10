// lib/packages/adaptive_modal/_demo_widgets.dart
// ---------------------------------------------------------------------------
// _demo_widgets.dart — StatefulWidget demos for adaptive_modal use cases.
//
// Each demo owns its own controller lifecycle — initState,
// didChangeDependencies, dispose — so the widgetbook use-case functions stay
// as simple one-liners.
// ---------------------------------------------------------------------------
part of 'adaptive_modal.usecase.dart';

// ---------------------------------------------------------------------------
// Shared modal content
// ---------------------------------------------------------------------------

/// Simple selectable list used as modal content across all demos.
/// onConfirm is optional — demos that don't need a return value omit it.
class _ModalContent extends StatefulWidget {
  const _ModalContent({
    required this.title,
    this.onConfirm,
  });

  final String title;
  final void Function(String value)? onConfirm;

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  String? _selected;

  static const _items = [
    'Option Alpha',
    'Option Beta',
    'Option Gamma',
    'Option Delta',
    'Option Epsilon',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 48, 48, 16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _items[index];
              final isSelected = item == _selected;
              return ListTile(
                title: Text(item),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : const Icon(Icons.chevron_right, size: 18),
                onTap: () => setState(() => _selected = item),
              );
            },
          ),
        ),
        if (widget.onConfirm != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selected != null
                  ? () => widget.onConfirm!(_selected!)
                  : null,
              child: const Text('Confirm'),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _DefaultModalDemo
// ---------------------------------------------------------------------------

class _DefaultModalDemo extends StatefulWidget {
  const _DefaultModalDemo();

  @override
  State<_DefaultModalDemo> createState() => _DefaultModalDemoState();
}

class _DefaultModalDemoState extends State<_DefaultModalDemo> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  late final AdaptiveModalController<void> _modal;

  @override
  void initState() {
    super.initState();
    _modal = AdaptiveModalController<void>(
      anchorKey: _anchorKey,
      child: const _ModalContent(title: 'Default Modal'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modal.attach(context);
  }

  @override
  void dispose() {
    _modal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        key: _anchorKey,
        onPressed: () => _modal.show(context),
        child: const Text('Open Default Modal'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CustomIconModalDemo
// ---------------------------------------------------------------------------

class _CustomIconModalDemo extends StatefulWidget {
  const _CustomIconModalDemo();

  @override
  State<_CustomIconModalDemo> createState() => _CustomIconModalDemoState();
}

class _CustomIconModalDemoState extends State<_CustomIconModalDemo> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  late final AdaptiveModalController<void> _modal;

  @override
  void initState() {
    super.initState();
    _modal = AdaptiveModalController<void>(
      anchorKey: _anchorKey,
      child: const _ModalContent(title: 'Custom Icon Modal'),
      config: const AdaptiveModalConfig(
        closeIcon: Icon(Icons.arrow_back_ios_new, size: 18),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modal.attach(context);
  }

  @override
  void dispose() {
    _modal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        key: _anchorKey,
        onPressed: () => _modal.show(context),
        child: const Text('Open Custom Icon Modal'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _NoBarrierModalDemo
// ---------------------------------------------------------------------------

class _NoBarrierModalDemo extends StatefulWidget {
  const _NoBarrierModalDemo();

  @override
  State<_NoBarrierModalDemo> createState() => _NoBarrierModalDemoState();
}

class _NoBarrierModalDemoState extends State<_NoBarrierModalDemo> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  late final AdaptiveModalController<void> _modal;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _modal = AdaptiveModalController<void>(
      anchorKey: _anchorKey,
      child: const _ModalContent(title: 'No Barrier Modal'),
      config: const AdaptiveModalConfig(barrierDismissible: false),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modal.attach(context);
  }

  @override
  void dispose() {
    _modal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Background counter: $_counter',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This button stays interactive while the modal is open.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text('Tap me — I work behind the modal'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: _anchorKey,
            onPressed: () => _modal.show(context),
            child: const Text('Open No Barrier Modal'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ReturnValueModalDemo
// ---------------------------------------------------------------------------

class _ReturnValueModalDemo extends StatefulWidget {
  const _ReturnValueModalDemo();

  @override
  State<_ReturnValueModalDemo> createState() => _ReturnValueModalDemoState();
}

class _ReturnValueModalDemoState extends State<_ReturnValueModalDemo> {
  final GlobalKey<State<StatefulWidget>> _anchorKey = GlobalKey();
  late final AdaptiveModalController<String> _modal;
  String? _lastResult;

  @override
  void initState() {
    super.initState();
    _modal = AdaptiveModalController<String>(
      anchorKey: _anchorKey,
      child: _ModalContent(
        title: 'Select an Option',
        onConfirm: (value) => _modal.resolve(value),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modal.attach(context);
  }

  @override
  void dispose() {
    _modal.dispose();
    super.dispose();
  }

  Future<void> _showModal() async {
    final result = await _modal.show(context);
    if (!mounted) return;
    setState(() => _lastResult = result ?? '(dismissed)');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            key: _anchorKey,
            onPressed: _showModal,
            child: const Text('Open — Select and Confirm'),
          ),
          const SizedBox(height: 24),
          if (_lastResult != null) ...[
            Text(
              'Last result:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              _lastResult!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ],
      ),
    );
  }
}
