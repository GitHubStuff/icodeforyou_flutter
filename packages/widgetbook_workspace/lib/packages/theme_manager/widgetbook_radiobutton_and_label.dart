// radiobutton_and_label.stories.dart
// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart' show RadiobuttonAndLabel;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

enum Priority { low, medium, high, critical }

@widgetbook.UseCase(name: 'Basic String Options', type: RadiobuttonAndLabel)
Widget basicStringRadioButtons(BuildContext context) {
  return _StatefulRadioDemo<String>(
    title: 'Select your favorite color',
    options: ['Red', 'Green', 'Blue', 'Yellow'],
    initialValue: context.knobs.object.dropdown(
      label: 'Initial Selection',
      options: ['Red', 'Green', 'Blue', 'Yellow'],
      initialOption: 'Red',
    ),
    labelBuilder: (value) => Text(value),
  );
}

@widgetbook.UseCase(name: 'Integer Values', type: RadiobuttonAndLabel)
Widget integerRadioButtons(BuildContext context) {
  return _StatefulRadioDemo<int>(
    title: 'Select a number',
    options: [1, 2, 3, 4, 5],
    initialValue: context.knobs.object.dropdown(
      label: 'Initial Selection',
      options: [1, 2, 3, 4, 5],
      initialOption: 1,
    ),
    labelBuilder: (value) => Text('Number $value'),
  );
}

@widgetbook.UseCase(name: 'Enum Options', type: RadiobuttonAndLabel)
Widget enumRadioButtons(BuildContext context) {
  return _StatefulRadioDemo<Priority>(
    title: 'Select task priority',
    options: Priority.values,
    initialValue: context.knobs.object.dropdown(
      label: 'Initial Selection',
      options: Priority.values,
      initialOption: Priority.low,
    ),
    labelBuilder: (priority) {
      final icons = {
        Priority.low: Icons.low_priority,
        Priority.medium: Icons.priority_high,
        Priority.high: Icons.warning,
        Priority.critical: Icons.error,
      };
      final colors = {
        Priority.low: Colors.green,
        Priority.medium: Colors.orange,
        Priority.high: Colors.red,
        Priority.critical: Colors.purple,
      };

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[priority], color: colors[priority], size: 20),
          const SizedBox(width: 8),
          Text(
            priority.name.toUpperCase(),
            style: TextStyle(
              color: colors[priority],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    },
  );
}

@widgetbook.UseCase(name: 'Rich Labels', type: RadiobuttonAndLabel)
Widget richLabelRadioButtons(BuildContext context) {
  final showSubtitles = context.knobs.boolean(
    label: 'Show Subtitles',
    initialValue: true,
  );

  final showIcons = context.knobs.boolean(
    label: 'Show Icons',
    initialValue: true,
  );

  return _StatefulRadioDemo<String>(
    title: 'Select your subscription plan',
    options: ['basic', 'premium', 'enterprise'],
    initialValue: 'basic',
    labelBuilder: (value) {
      final configs = {
        'basic': {
          'title': 'Basic Plan',
          'subtitle': '\$9.99/month',
          'icon': Icons.person,
        },
        'premium': {
          'title': 'Premium Plan',
          'subtitle': '\$19.99/month',
          'icon': Icons.star,
        },
        'enterprise': {
          'title': 'Enterprise Plan',
          'subtitle': '\$49.99/month',
          'icon': Icons.business,
        },
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcons) ...[
                Icon(configs[value]!['icon'] as IconData, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                configs[value]!['title'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (showSubtitles) ...[
            const SizedBox(height: 4),
            Text(
              configs[value]!['subtitle'] as String,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      );
    },
  );
}

@widgetbook.UseCase(name: 'Layout Variations', type: RadiobuttonAndLabel)
Widget layoutVariations(BuildContext context) {
  final isHorizontal = context.knobs.boolean(
    label: 'Horizontal Layout',
    initialValue: false,
  );

  final showDividers = context.knobs.boolean(
    label: 'Show Dividers',
    initialValue: false,
  );

  return _StatefulRadioDemo<String>(
    title: 'Select payment method',
    options: ['Credit Card', 'PayPal', 'Bank Transfer', 'Cryptocurrency'],
    initialValue: 'Credit Card',
    isHorizontal: isHorizontal,
    showDividers: showDividers,
    labelBuilder: (value) => Text(value),
  );
}

@widgetbook.UseCase(name: 'Disabled State', type: RadiobuttonAndLabel)
Widget disabledRadioButtons(BuildContext context) {
  final enableAll = context.knobs.boolean(
    label: 'Enable All Options',
    initialValue: false,
  );

  return _StatefulRadioDemo<String>(
    title: 'Select delivery option',
    options: ['Standard', 'Express', 'Overnight', 'Same Day'],
    initialValue: 'Standard',
    disabledOptions: enableAll ? <String>{} : {'Express', 'Same Day'},
    labelBuilder: (value) {
      final isDisabled = !enableAll && {'Express', 'Same Day'}.contains(value);
      return Row(
        children: [
          Text(value, style: TextStyle(color: isDisabled ? Colors.grey : null)),
          if (isDisabled) ...[
            const SizedBox(width: 8),
            Icon(Icons.lock, size: 16, color: Colors.grey[600]),
          ],
        ],
      );
    },
  );
}

// Helper widget to manage state for the demos
class _StatefulRadioDemo<T> extends StatefulWidget {
  const _StatefulRadioDemo({
    required this.title,
    required this.options,
    required this.initialValue,
    required this.labelBuilder,
    this.isHorizontal = false,
    this.showDividers = false,
    this.disabledOptions = const <Never>{},
  });

  final String title;
  final List<T> options;
  final T initialValue;
  final Widget Function(T) labelBuilder;
  final bool isHorizontal;
  final bool showDividers;
  final Set<T> disabledOptions;

  @override
  State<_StatefulRadioDemo<T>> createState() => _StatefulRadioDemoState<T>();
}

class _StatefulRadioDemoState<T> extends State<_StatefulRadioDemo<T>> {
  late T selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(_StatefulRadioDemo<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      selectedValue = widget.initialValue;
    }
  }

  void _handleRadioChange(T? value) {
    if (value != null && !widget.disabledOptions.contains(value)) {
      setState(() {
        selectedValue = value;
      });
    }
  }

  // Empty callback for disabled items to prevent debug service errors
  void _noOpCallback(T? value) {
    // Intentionally empty - prevents null callback issues
  }

  @override
  Widget build(BuildContext context) {
    final radioButtons = widget.options.map((option) {
      final isDisabled = widget.disabledOptions.contains(option);

      return RadiobuttonAndLabel<T>(
        value: option,
        label: widget.labelBuilder(option),
        // Use empty callback instead of null to prevent debug errors
        onChanged: isDisabled ? _noOpCallback : _handleRadioChange,
      );
    }).toList();

    Widget radioGroup = RadioGroup<T>(
      groupValue: selectedValue,
      onChanged: _handleRadioChange,
      child: widget.isHorizontal
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: radioButtons
                    .expand(
                      (radio) => [
                        radio,
                        if (widget.showDividers && radio != radioButtons.last)
                          const VerticalDivider(width: 20),
                      ],
                    )
                    .toList(),
              ),
            )
          : Column(
              children: radioButtons
                  .expand(
                    (radio) => [
                      radio,
                      if (widget.showDividers && radio != radioButtons.last)
                        const Divider(height: 1),
                    ],
                  )
                  .toList(),
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: radioGroup,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Value:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedValue.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
