// lib/packages/infinite_scroll_picking/lib/src/infinite_scroll_picker.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: InfiniteScrollPicker)
Widget infiniteScrollPickerUseCase(BuildContext context) {
  final dataset = context.knobs.object.dropdown<_Dataset>(
    label: 'dataset',
    options: _Dataset.values,
    initialOption: _Dataset.fruit,
    labelBuilder: (d) => d.label,
  );

  final magnification = context.knobs.double.slider(
    label: 'magnification',
    initialValue: 1.25,
    min: 1.0,
    max: 1.8,
  );

  final showBorder = context.knobs.boolean(
    label: 'showBorder',
    initialValue: true,
  );

  final debounceMs = context.knobs.int.slider(
    label: 'selection debounce (ms)',
    initialValue: 0,
    min: 0,
    max: 800,
  );

  return _PickerShowcase(
    items: dataset.items,
    pickerId: dataset.name,
    magnification: magnification,
    showBorder: showBorder,
    debounce: Duration(milliseconds: debounceMs),
  );
}

enum _Dataset {
  fruit('Fruit', ['🍎', '🍌', '🍇', '🍊', '🍉', '🍓', '🍑', '🥝', '🥭', '🍍']),
  numbers('Numbers 0–19', [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
  ]),
  weekdays('Weekdays', ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);

  const _Dataset(this.label, this.items);

  final String label;
  final List<String> items;
}

class _PickerShowcase extends StatefulWidget {
  const _PickerShowcase({
    required this.items,
    required this.pickerId,
    required this.magnification,
    required this.showBorder,
    required this.debounce,
  });

  final List<String> items;
  final String pickerId;
  final double magnification;
  final bool showBorder;
  final Duration debounce;

  @override
  State<_PickerShowcase> createState() => _PickerShowcaseState();
}

class _PickerShowcaseState extends State<_PickerShowcase> {
  late final InfiniteScrollPickerController _controller;
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _controller = InfiniteScrollPickerController();
    _selected = widget.items.first;
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
          InfiniteScrollPicker<String, String>(
            controller: _controller,
            // Force a fresh State when items change so the wheel reseeds.
            key: ValueKey(widget.pickerId),
            config: InfiniteScrollPickerConfig<String, String>(
              items: widget.items,
              pickerId: widget.pickerId,
              startingIndex: 0,
              wheelConfig: InfiniteScrollWheelConfig(
                magnification: widget.magnification,
                showBorder: widget.showBorder,
                selectionDebounce: widget.debounce,
                wheelWidth: 96,
                wheelHeight: 120,
                itemExtent: 32,
              ),
            ),
            label: const Text(
              'Pick',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            itemBuilder: (item, isSelected) => Center(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            onItemSelected: (_, item) => setState(() => _selected = item),
          ),
          const Gap(24),
          Text('selected: $_selected'),
          const Gap(8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _controller.reset(
                  duration: const Duration(milliseconds: 300),
                ),
                child: const Text('Reset'),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => _controller.animateToIndex(
                  widget.items.length - 1,
                  duration: const Duration(milliseconds: 400),
                ),
                child: const Text('Animate to last'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
