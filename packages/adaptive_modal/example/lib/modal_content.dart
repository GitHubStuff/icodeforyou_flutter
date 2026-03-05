// example/lib/modal_content.dart
// ---------------------------------------------------------------------------
// modal_content.dart — sample content widget rendered inside the modal.
//
// Demonstrates that the modal child is a plain Flutter widget with no
// knowledge of the modal itself. The close button and sizing are owned
// entirely by the package.
//
// onConfirm receives the selected item string and is wired to
// controller.resolve() in main.dart — the content widget never touches
// the controller directly.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ModalContent
// ---------------------------------------------------------------------------

/// Sample content rendered inside each modal in the example app.
///
/// [onConfirm] is called with the selected item label when the Confirm button
/// is tapped. The caller wires this to [AdaptiveModalController.resolve].
class ModalContent extends StatefulWidget {
  const ModalContent({
    super.key,
    required this.label,
    required this.onConfirm,
  });

  final String label;

  /// Called with the selected item when the Confirm button is tapped.
  final void Function(String value) onConfirm;

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(label: widget.label),
        Expanded(
          child: _ItemList(
            selected: _selected,
            onSelected: (item) => setState(() => _selected = item),
          ),
        ),
        _Footer(
          enabled: _selected != null,
          onConfirm: () {
            if (_selected != null) widget.onConfirm(_selected!);
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 48, 16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ItemList
// ---------------------------------------------------------------------------

class _ItemList extends StatelessWidget {
  const _ItemList({required this.selected, required this.onSelected});

  final String? selected;
  final void Function(String item) onSelected;

  static const _items = [
    'Review order details',
    'Update shipping address',
    'Apply promo code',
    'Select payment method',
    'Confirm delivery window',
    'Add gift message',
    'View item breakdown',
    'Check stock availability',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items[index];
        final isSelected = item == selected;
        return ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(item, style: Theme.of(context).textTheme.bodyMedium),
          trailing: isSelected
              ? Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary)
              : const Icon(Icons.chevron_right, size: 18),
          onTap: () => onSelected(item),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _Footer
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({required this.enabled, required this.onConfirm});

  final bool enabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FilledButton(
        onPressed: enabled ? onConfirm : null,
        child: const Text('Confirm'),
      ),
    );
  }
}
